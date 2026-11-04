import 'dart:io';

import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

void main() {
  late Directory temp;
  late AppDatabase db;
  late ImageStore images;
  late DateTime now;
  late RecipeRepository repo;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('cooknote_repo_');
    db = AppDatabase(NativeDatabase.memory());
    images = ImageStore(Directory('${temp.path}/photos'));
    now = DateTime(2026, 11, 3, 9);
    repo = RecipeRepository(db, images, clock: () => now);
  });

  tearDown(() async {
    await db.close();
    temp.deleteSync(recursive: true);
  });

  Future<String> photo() async {
    final f = File('${temp.path}/src.jpg')..writeAsBytesSync(jpegBytes(40, 30));
    return images.importImage(f.path);
  }

  RecipeDraft draft({String name = 'Phở bò', List<String> photos = const []}) =>
      RecipeDraft(
        name: name,
        servings: 4,
        servingsUnit: 'người',
        prepMinutes: 30,
        cookMinutes: 180,
        totalMinutes: 210,
        source: 'Bà ngoại',
        sourceUrl: 'https://example.com/pho',
        notes: 'Nước dùng ngon hơn khi để qua đêm',
        nutrition: '450 kcal mỗi bát',
        difficulty: Difficulty.hard,
        rating: 5,
        favorite: true,
        ingredients: const [
          RecipeLine('Nước dùng', isHeading: true),
          RecipeLine('2 kg xương bò'),
          RecipeLine('Ăn kèm', isHeading: true),
          RecipeLine('rau thơm'),
        ],
        steps: const [RecipeLine('Chần xương'), RecipeLine('Ninh 3 tiếng')],
        photos: photos,
      );

  group('lưu và đọc (AC-02, AC-04)', () {
    test('lưu đủ mọi trường, đọc lại đúng thứ tự dòng và ảnh', () async {
      final p1 = await photo();
      final p2 = await photo();
      final id = await repo.save(draft(photos: [p1, p2]));

      final r = (await repo.getRecipe(id))!;
      expect(r.draft, draft(photos: [p1, p2]));
      expect(r.coverPhoto, p1);
      expect(r.createdAt, now);
      expect(r.updatedAt, now);
      expect(r.deletedAt, isNull);
    });

    test(
      'thiếu tên, tên chỉ có khoảng trắng hoặc quá 200 ký tự thì không lưu',
      () async {
        for (final bad in ['', '   ', 'a' * 201]) {
          await expectLater(
            repo.save(draft(name: bad)),
            throwsA(isA<RecipeValidationException>()),
          );
        }
        expect(await repo.watchRecipes().first, isEmpty);
        // Đúng 200 ký tự thì được.
        await repo.save(draft(name: 'a' * 200));
      },
    );

    test('tên được bỏ khoảng trắng hai đầu', () async {
      final id = await repo.save(draft(name: '  Bánh flan  '));
      expect((await repo.getRecipe(id))!.draft.name, 'Bánh flan');
    });

    test('tối đa 20 ảnh, đánh giá 0 tới 5', () async {
      final names = List.generate(21, (i) => 'p$i.jpg');
      await expectLater(
        repo.save(draft(photos: names)),
        throwsA(isA<RecipeValidationException>()),
      );
      await expectLater(
        repo.save(draft().copyWith(rating: 6)),
        throwsA(isA<RecipeValidationException>()),
      );
    });

    test('sửa thay toàn bộ dòng, giữ ngày tạo, cập nhật ngày sửa', () async {
      final id = await repo.save(draft());
      now = now.add(const Duration(days: 1));
      await repo.save(
        draft().copyWith(
          name: 'Phở gà',
          ingredients: const [RecipeLine('1 con gà')],
          steps: const [],
        ),
        id: id,
      );
      final r = (await repo.getRecipe(id))!;
      expect(r.draft.name, 'Phở gà');
      expect(r.draft.ingredients, const [RecipeLine('1 con gà')]);
      expect(r.draft.steps, isEmpty);
      expect(r.createdAt, DateTime(2026, 11, 3, 9));
      expect(r.updatedAt, DateTime(2026, 11, 4, 9));
    });

    test(
      'gỡ ảnh khi sửa thì file ảnh bị xóa, ảnh còn giữ thì không (AC-07)',
      () async {
        final keep = await photo();
        final drop = await photo();
        final id = await repo.save(draft(photos: [keep, drop]));
        await repo.save(draft(photos: [keep]), id: id);
        expect(images.file(keep).existsSync(), isTrue);
        expect(images.file(drop).existsSync(), isFalse);
      },
    );

    test('sửa công thức không tồn tại thì báo lỗi', () async {
      await expectLater(repo.save(draft(), id: 99), throwsStateError);
    });

    test('danh sách mới sửa ở trên, có ảnh bìa', () async {
      final p = await photo();
      final a = await repo.save(draft(name: 'A', photos: [p]));
      now = now.add(const Duration(minutes: 1));
      final b = await repo.save(draft(name: 'B'));
      final list = await repo.watchRecipes().first;
      expect(list.map((r) => r.id), [b, a]);
      expect(list.last.coverPhoto, p);
      expect(list.first.coverPhoto, isNull);
    });

    test('đánh dấu yêu thích không đổi ngày sửa', () async {
      final id = await repo.save(draft().copyWith(favorite: false));
      now = now.add(const Duration(days: 1));
      await repo.setFavorite(id, true);
      final r = (await repo.getRecipe(id))!;
      expect(r.draft.favorite, isTrue);
      expect(r.updatedAt, DateTime(2026, 11, 3, 9));
    });
  });

  group('thùng rác (AC-05)', () {
    test('xóa thì vào thùng rác, khôi phục thì về danh sách', () async {
      final id = await repo.save(draft());
      await repo.moveToTrash(id);
      expect(await repo.watchRecipes().first, isEmpty);
      final trash = await repo.watchTrash().first;
      expect(trash.single.id, id);
      expect(trash.single.deletedAt, now);

      await repo.restore(id);
      expect((await repo.watchRecipes().first).single.id, id);
      expect(await repo.watchTrash().first, isEmpty);
    });

    test('giữ 30 ngày rồi mới xóa hẳn cùng ảnh', () async {
      final p = await photo();
      final id = await repo.save(draft(photos: [p]));
      await repo.moveToTrash(id);

      now = now.add(const Duration(days: 29, hours: 23));
      expect(await repo.purgeTrash(), 0);
      expect(await repo.getRecipe(id), isNotNull);

      now = now.add(const Duration(hours: 1));
      expect(await repo.purgeTrash(), 1);
      expect(await repo.getRecipe(id), isNull);
      expect(images.file(p).existsSync(), isFalse);
      expect(await db.select(db.recipeLines).get(), isEmpty);
      expect(await db.select(db.recipePhotos).get(), isEmpty);
    });

    test('xóa vĩnh viễn từ thùng rác xóa cả ảnh', () async {
      final p = await photo();
      final id = await repo.save(draft(photos: [p]));
      await repo.moveToTrash(id);
      await repo.deleteForever(id);
      expect(await repo.getRecipe(id), isNull);
      expect(images.file(p).existsSync(), isFalse);
    });
  });

  test('nhân bản chép mọi trường và ảnh thành file riêng (AC-06)', () async {
    final p = await photo();
    final id = await repo.save(draft(photos: [p]));
    final copyId = await repo.duplicate(id, copyLabel: 'bản sao');

    final copy = (await repo.getRecipe(copyId))!;
    expect(copy.draft.name, 'Phở bò (bản sao)');
    expect(copy.draft.ingredients, draft().ingredients);
    expect(copy.draft.steps, draft().steps);
    final copyPhoto = copy.draft.photos.single;
    expect(copyPhoto, isNot(p));

    // Xóa hẳn bản gốc không làm mất ảnh của bản sao.
    await repo.moveToTrash(id);
    await repo.deleteForever(id);
    expect(images.file(copyPhoto).existsSync(), isTrue);
  });

  test('nhân bản công thức tên dài vẫn không quá 200 ký tự', () async {
    final id = await repo.save(draft(name: 'x' * 200));
    final copyId = await repo.duplicate(id, copyLabel: 'bản sao');
    final name = (await repo.getRecipe(copyId))!.draft.name;
    expect(name.length, lessThanOrEqualTo(200));
    expect(name, endsWith('(bản sao)'));
  });

  test('referencedPhotos gồm ảnh của cả công thức trong thùng rác', () async {
    final a = await photo();
    final b = await photo();
    await repo.save(draft(photos: [a]));
    final trashed = await repo.save(draft(photos: [b]));
    await repo.moveToTrash(trashed);
    expect(await repo.referencedPhotos(), {a, b});
  });
}
