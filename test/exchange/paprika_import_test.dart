import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/exchange/imported_recipe.dart';
import 'package:cooknote/src/exchange/paprika_import.dart';
import 'package:flutter_test/flutter_test.dart';

import 'exchange_samples.dart';

void main() {
  test('nhập đủ trường một công thức Paprika (AC-44)', () {
    final file = paprikaFile({
      'Pho.paprikarecipe': gz(paprikaRecipe(photoData: base64Encode(fakeJpeg))),
    });
    final result = readPaprikaBytes(file);
    expect(result.report.imported, 1);
    expect(result.report.skipped, 0);
    final r = result.recipes.single;
    final d = r.draft;
    expect(d.name, 'Phở bò');
    expect(d.servings, 4);
    expect(d.servingsUnit, 'phần');
    expect(d.prepMinutes, 20);
    expect(d.cookMinutes, 190);
    expect(d.totalMinutes, isNull);
    expect(d.source, 'Bà ngoại');
    expect(d.sourceUrl, 'https://example.com/pho');
    expect(d.notes, 'Ăn nóng.');
    expect(d.nutrition, '450 kcal');
    expect(d.difficulty, Difficulty.medium);
    expect(d.rating, 4);
    expect(d.ingredients, [
      const RecipeLine('Nước dùng', isHeading: true),
      const RecipeLine('1 kg xương bò'),
      const RecipeLine('200 g bánh phở'),
    ]);
    expect(d.steps, [
      const RecipeLine('Hầm xương 3 giờ.'),
      const RecipeLine('Chan nước dùng vào tô.'),
    ]);
    expect(r.categoryNames, ['Món nước', 'Món chính']);
    expect(r.sourceUid, 'UID-0001');
    expect(r.createdAt, DateTime(2020, 5, 17, 8, 30));
    expect(r.dedupeKey, isNotEmpty);
    expect(r.photos.single.bytes, fakeJpeg);
  });

  test('nhiều công thức, thêm ảnh trong photos[]', () {
    final file = paprikaFile({
      'a.paprikarecipe': gz(paprikaRecipe(name: 'A', uid: '1')),
      'b.paprikarecipe': gz(
        paprikaRecipe(
          name: 'B',
          uid: '2',
          photos: [
            {
              'name': 'x',
              'filename': 'x.png',
              'data': base64Encode(fakePng),
              'hash': 'h',
            },
          ],
        ),
      ),
    });
    final result = readPaprikaBytes(file);
    expect(result.recipes.map((r) => r.draft.name), ['A', 'B']);
    expect(result.recipes[1].photos.single.name, 'x.png');
    expect(result.recipes[1].photos.single.bytes, fakePng);
  });

  test('một công thức hỏng giữa file không làm hỏng cả file', () {
    final file = paprikaFile({
      'a.paprikarecipe': gz(paprikaRecipe(name: 'A', uid: '1')),
      'bad.paprikarecipe': [1, 2, 3, 4, 5],
      'noname.paprikarecipe': gz(paprikaRecipe(name: '  ', uid: '3')),
      'c.paprikarecipe': gz(paprikaRecipe(name: 'C', uid: '4')),
    });
    final result = readPaprikaBytes(file);
    expect(result.report.imported, 2);
    expect(result.report.skipped, 2);
    expect(result.report.reasons, hasLength(2));
    expect(result.recipes.map((r) => r.draft.name), ['A', 'C']);
  });

  test('ảnh base64 hỏng: vẫn nhập công thức, bỏ ảnh, ghi lý do', () {
    final file = paprikaFile({
      'a.paprikarecipe': gz(paprikaRecipe(photoData: '@@@không-phải-base64')),
      'b.paprikarecipe': gz(
        paprikaRecipe(
          name: 'B',
          uid: '2',
          photoData: base64Encode([1, 2, 3, 4, 5, 6]), // không phải JPEG/PNG
        ),
      ),
    });
    final result = readPaprikaBytes(file);
    expect(result.report.imported, 2);
    expect(result.recipes.every((r) => r.photos.isEmpty), isTrue);
    expect(result.report.reasons, hasLength(2));
  });

  test('nhập lại cùng file cho cùng dedupeKey; khác uid thì khác', () {
    final bytes = paprikaFile({'a.paprikarecipe': gz(paprikaRecipe())});
    final k1 = readPaprikaBytes(bytes).recipes.single.dedupeKey;
    final k2 = readPaprikaBytes(bytes).recipes.single.dedupeKey;
    expect(k1, k2);
    final other = paprikaFile({
      'a.paprikarecipe': gz(paprikaRecipe(uid: 'UID-9')),
    });
    expect(readPaprikaBytes(other).recipes.single.dedupeKey, isNot(k1));
  });

  test('không có uid: khóa là băm của tên chuẩn hóa + nguồn', () {
    Map<String, Object?> noUid(String name) => {
      ...paprikaRecipe(name: name),
      'uid': '',
    };
    ImportedRecipe one(String name) =>
        readPaprikaBytes(paprikaFile({'a.paprikarecipe': gz(noUid(name))}))
            .recipes
            .single;
    expect(one('Phở  Bò').dedupeKey, one('pho bo').dedupeKey);
    expect(one('Phở bò').dedupeKey, isNot(one('Bún bò').dedupeKey));
    expect(one('Phở bò').sourceUid, isNull);
  });

  test('file không phải zip thì ném ImportFormatException', () {
    expect(
      () => readPaprikaBytes(Uint8List.fromList(utf8.encode('xin chào'))),
      throwsA(isA<ImportFormatException>()),
    );
  });

  test('zip không có *.paprikarecipe thì báo rỗng', () {
    final result = readPaprikaBytes(zipOf({'readme.txt': utf8.encode('hi')}));
    expect(result.report.imported, 0);
    expect(result.report.reasons, isNotEmpty);
  });

  test('readPaprikaFile đọc từ đĩa', () {
    final dir = Directory.systemTemp.createTempSync('paprika_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final f = File('${dir.path}/x.paprikarecipes')
      ..writeAsBytesSync(paprikaFile({'a.paprikarecipe': gz(paprikaRecipe())}));
    expect(readPaprikaFile(f).recipes, hasLength(1));
  });

  test('parseMinutes / parseServings', () {
    expect(parseMinutes('1 hr 15 min'), 75);
    expect(parseMinutes('1h30'), 90);
    expect(parseMinutes('45'), 45);
    expect(parseMinutes('PT1H30M'), 90);
    expect(parseMinutes('PT45M'), 45);
    expect(parseMinutes(''), isNull);
    expect(parseMinutes('abc'), isNull);
    expect(parseServings('Serves 4-6 people').$1, 4);
    expect(parseServings('2,5 phần').$1, 2.5);
    expect(parseServings(null).$1, isNull);
  });
}
