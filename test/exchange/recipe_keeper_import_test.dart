// Mẫu HTML TỔNG HỢP dựng theo mô tả của bộ nhập Tandoor / Vanilla Cookbook.
// CHƯA kiểm chứng với file Recipe Keeper thật.
import 'dart:convert';
import 'dart:typed_data';

import 'package:cooknote/src/exchange/imported_recipe.dart';
import 'package:cooknote/src/exchange/recipe_keeper_import.dart';
import 'package:flutter_test/flutter_test.dart';

import 'exchange_samples.dart';

String recipeDiv(String name, {String? photo, String source = 'Mẹ'}) =>
    '''
<div class="recipe-details">
  <h2 itemprop="name">$name</h2>
  <meta itemprop="recipeCategory" content="Món chính">
  <span itemprop="recipeCourse">Ăn tối</span>
  <span itemprop="recipeYield">4</span>
  <meta itemprop="prepTime" content="PT15M">
  <meta itemprop="cookTime" content="PT1H">
  <span itemprop="recipeSource">$source</span>
  ${photo == null ? '' : '<img class="recipe-photo" src="$photo">'}
  <div itemprop="recipeIngredients">
    <p>Nước sốt:</p>
    <p>2 quả cà chua</p>
    <p>Muối &amp; tiêu</p>
  </div>
  <div itemprop="recipeDirections">
    <p>Thái cà chua.</p>
    <p></p>
    <p>Xào lên.</p>
  </div>
  <div itemprop="recipeNotes"><p>Ngon hơn hôm sau.</p></div>
</div>''';

Uint8List rkZip(List<String> divs, [Map<String, List<int>> extra = const {}]) =>
    zipOf({
      'recipes.html': utf8.encode(
        '<html><body>${divs.join('\n')}</body></html>',
      ),
      ...extra,
    });

void main() {
  test('nhập công thức với ảnh trong images/', () {
    final result = readRecipeKeeperBytes(
      rkZip(
        [recipeDiv('Cà chua xào', photo: 'images/a_1.jpg')],
        {'images/a_1.jpg': fakeJpeg},
      ),
    );
    expect(result.report.imported, 1);
    final r = result.recipes.single;
    expect(r.draft.name, 'Cà chua xào');
    expect(r.draft.servings, 4);
    expect(r.draft.prepMinutes, 15);
    expect(r.draft.cookMinutes, 60);
    expect(r.draft.source, 'Mẹ');
    expect(r.categoryNames, containsAll(['Món chính', 'Ăn tối']));
    expect(r.draft.ingredients.map((l) => l.text), [
      'Nước sốt',
      '2 quả cà chua',
      'Muối & tiêu',
    ]);
    expect(r.draft.ingredients.first.isHeading, isTrue);
    expect(r.draft.steps.map((l) => l.text), ['Thái cà chua.', 'Xào lên.']);
    expect(r.draft.notes, 'Ngon hơn hôm sau.');
    expect(r.photos.single.bytes, fakeJpeg);
  });

  test('nhiều công thức; ảnh thiếu thì bỏ ảnh, không hỏng công thức', () {
    final result = readRecipeKeeperBytes(
      rkZip([
        recipeDiv('A', photo: 'images/missing.jpg'),
        recipeDiv('B'),
        '<div class="recipe-details"><p>không có tên</p></div>',
      ]),
    );
    expect(result.report.imported, 2);
    expect(result.report.skipped, 1);
    expect(result.recipes.every((r) => r.photos.isEmpty), isTrue);
    expect(result.report.reasons, isNotEmpty);
  });

  test('dedupeKey ổn định khi nhập lại', () {
    final bytes = rkZip([recipeDiv('A')]);
    expect(
      readRecipeKeeperBytes(bytes).recipes.single.dedupeKey,
      readRecipeKeeperBytes(bytes).recipes.single.dedupeKey,
    );
  });

  test('file không phải zip hoặc thiếu recipes.html', () {
    expect(
      () => readRecipeKeeperBytes(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<ImportFormatException>()),
    );
    expect(
      () => readRecipeKeeperBytes(zipOf({'x.txt': utf8.encode('x')})),
      throwsA(isA<ImportFormatException>()),
    );
  });
}
