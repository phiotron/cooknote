import 'dart:io';

import 'package:cooknote/src/data/category_repository.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CategoryRepository(db);
  });

  tearDown(() => db.close());

  Future<List<String>> names() async => [
    for (final c in await repo.watchAll().first) c.name,
  ];

  group('danh mục lồng nhau (AC-10)', () {
    test('lồng tối đa 3 cấp, cấp thứ 4 bị từ chối', () async {
      final a = await repo.add('Món chính');
      final b = await repo.add('Món Việt', parentId: a);
      final c = await repo.add('Món bún', parentId: b);
      await expectLater(
        repo.add('Quá sâu', parentId: c),
        throwsA(
          isA<CategoryException>().having(
            (e) => e.problem,
            'problem',
            CategoryProblem.tooDeep,
          ),
        ),
      );
      final all = await repo.watchAll().first;
      expect(all.map((e) => e.depth), [1, 2, 3]);
    });

    test('tên rỗng bị từ chối, tên quá 50 ký tự bị từ chối', () async {
      for (final bad in ['', '   ', 'a' * 51]) {
        await expectLater(repo.add(bad), throwsA(isA<CategoryException>()));
      }
      await repo.add('a' * 50);
    });

    test('cha không tồn tại thì báo lỗi', () async {
      await expectLater(
        repo.add('Con', parentId: 999),
        throwsA(isA<CategoryException>()),
      );
    });

    test('đổi tên', () async {
      final a = await repo.add('Cũ');
      await repo.rename(a, '  Mới ');
      expect(await names(), ['Mới']);
      await expectLater(repo.rename(a, ''), throwsA(isA<CategoryException>()));
    });

    test('sắp xếp lại được giữ sau khi mở lại, theo từng cấp', () async {
      final a = await repo.add('A');
      final b = await repo.add('B');
      final c = await repo.add('C');
      final a1 = await repo.add('A1', parentId: a);
      final a2 = await repo.add('A2', parentId: a);
      expect(await names(), ['A', 'A1', 'A2', 'B', 'C']);

      await repo.reorder(null, [c, a, b]);
      await repo.reorder(a, [a2, a1]);
      expect(await names(), ['C', 'A', 'A2', 'A1', 'B']);
    });

    test('xóa danh mục xóa luôn danh mục con, không xóa công thức', () async {
      final temp = Directory.systemTemp.createTempSync('cooknote_cat_');
      addTearDown(() => temp.deleteSync(recursive: true));
      final recipes = RecipeRepository(
        db,
        ImageStore(Directory('${temp.path}/p')),
      );
      final a = await repo.add('A');
      final a1 = await repo.add('A1', parentId: a);
      final b = await repo.add('B');
      final id = await recipes.save(
        RecipeDraft(name: 'Món', categoryIds: [a1, b]),
      );

      await repo.delete(a);
      expect(await names(), ['B']);
      final r = (await recipes.getRecipe(id))!;
      expect(r.draft.name, 'Món');
      expect(r.draft.categoryIds, [b]);
    });

    test('descendantIds gồm chính nó và mọi cấp con', () async {
      final a = await repo.add('A');
      final a1 = await repo.add('A1', parentId: a);
      final a11 = await repo.add('A11', parentId: a1);
      final b = await repo.add('B');
      final all = await repo.watchAll().first;
      expect(descendantIds(all, a), {a, a1, a11});
      expect(descendantIds(all, b), {b});
    });
  });

  group('danh mục mặc định (AC-10)', () {
    test('tiếng Việt và tiếng Anh, chỉ tạo một lần', () async {
      expect(await repo.seedDefaults('vi'), isTrue);
      expect(await names(), [
        'Món chính',
        'Món phụ',
        'Canh/Súp',
        'Tráng miệng',
        'Đồ uống',
        'Bánh',
      ]);
      // Người dùng xóa hết rồi mở app lần nữa: không tạo lại.
      for (final c in await repo.watchAll().first) {
        await repo.delete(c.id);
      }
      expect(await repo.seedDefaults('vi'), isFalse);
      expect(await names(), isEmpty);
    });

    test('ngôn ngữ khác tiếng Việt dùng tên tiếng Anh', () async {
      await repo.seedDefaults('en');
      expect((await names()).first, 'Main dishes');
      expect((await names()).length, 6);
    });
  });
}
