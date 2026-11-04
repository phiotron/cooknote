import 'dart:io';

import 'package:cooknote/src/data/category_repository.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_query.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;
  late AppDatabase db;
  late RecipeRepository repo;
  late CategoryRepository cats;
  late DateTime now;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('cooknote_q_');
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 3, 9);
    repo = RecipeRepository(
      db,
      ImageStore(Directory('${temp.path}/p')),
      clock: () => now,
    );
    cats = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
    temp.deleteSync(recursive: true);
  });

  Future<int> add(
    String name, {
    List<String> ingredients = const [],
    List<String> steps = const [],
    String? notes,
    String? source,
    int rating = 0,
    bool favorite = false,
    int? total,
    int? cook,
    List<int> categoryIds = const [],
    List<String> tags = const [],
  }) {
    now = now.add(const Duration(minutes: 1));
    return repo.save(
      RecipeDraft(
        name: name,
        ingredients: [for (final i in ingredients) RecipeLine(i)],
        steps: [for (final s in steps) RecipeLine(s)],
        notes: notes,
        source: source,
        rating: rating,
        favorite: favorite,
        totalMinutes: total,
        cookMinutes: cook,
        categoryIds: categoryIds,
        tags: tags,
      ),
    );
  }

  Future<List<String>> run(RecipeQuery q) async => [
    for (final r in await repo.search(q)) r.name,
  ];

  group('tìm kiếm không phân biệt dấu (AC-12)', () {
    setUp(() async {
      await add(
        'Phở bò',
        ingredients: ['500 g thịt bò', '1 củ hành tím'],
        steps: ['Ninh xương 3 tiếng'],
        notes: 'Món của bà',
        source: 'Bà ngoại',
      );
      await add(
        'Bánh flan',
        ingredients: ['3 quả trứng', '100 g đường'],
        steps: ['Hấp cách thủy'],
      );
      await add('Pasta', ingredients: ['200 g spaghetti']);
    });

    test('gõ không dấu tìm ra tên có dấu', () async {
      expect(await run(const RecipeQuery(text: 'pho bo')), ['Phở bò']);
      expect(await run(const RecipeQuery(text: 'PHỞ')), ['Phở bò']);
    });

    test('tìm trong nguyên liệu, bước, ghi chú, nguồn', () async {
      expect(await run(const RecipeQuery(text: 'thit bo')), ['Phở bò']);
      expect(await run(const RecipeQuery(text: 'huc cach thuy')), isEmpty);
      expect(await run(const RecipeQuery(text: 'cach thuy')), ['Bánh flan']);
      expect(await run(const RecipeQuery(text: 'mon cua ba')), ['Phở bò']);
      expect(await run(const RecipeQuery(text: 'ngoai')), ['Phở bò']);
    });

    test('nhiều từ phải khớp hết, thứ tự tùy ý', () async {
      expect(await run(const RecipeQuery(text: 'bo pho')), ['Phở bò']);
      expect(await run(const RecipeQuery(text: 'pho pasta')), isEmpty);
    });

    test('ô tìm rỗng hoặc chỉ khoảng trắng trả về tất cả', () async {
      expect((await run(const RecipeQuery(text: '   '))).length, 3);
    });

    test('sửa công thức thì chỉ mục tìm kiếm được cập nhật', () async {
      final id = (await repo.search(const RecipeQuery(text: 'pasta')))
          .single
          .id;
      await repo.save(
        const RecipeDraft(
          name: 'Mì Ý',
          ingredients: [RecipeLine('mì spaghetti')],
        ),
        id: id,
      );
      expect(await run(const RecipeQuery(text: 'pasta')), isEmpty);
      expect(await run(const RecipeQuery(text: 'mi y')), ['Mì Ý']);
    });

    test('công thức trong thùng rác không hiện trong kết quả', () async {
      final id = (await repo.search(const RecipeQuery(text: 'pho'))).single.id;
      await repo.moveToTrash(id);
      expect(await run(const RecipeQuery(text: 'pho')), isEmpty);
    });
  });

  group('lọc kết hợp (AC-13)', () {
    late int main, soup, viet;

    setUp(() async {
      main = await cats.add('Món chính');
      viet = await cats.add('Món Việt', parentId: main);
      soup = await cats.add('Canh');
      await add(
        'Phở',
        rating: 5,
        favorite: true,
        total: 240,
        categoryIds: [viet],
        tags: ['bò', 'Nước dùng'],
        ingredients: ['thịt bò'],
      );
      await add(
        'Canh chua',
        rating: 3,
        total: 30,
        categoryIds: [soup],
        tags: ['chua', 'nuoc dung'],
        ingredients: ['cá lóc', 'dứa'],
      );
      await add(
        'Cơm chiên',
        rating: 4,
        favorite: true,
        total: 20,
        categoryIds: [main],
        ingredients: ['cơm nguội', 'trứng'],
      );
      await add('Chưa đặt thời gian');
    });

    test('danh mục cha gồm cả công thức trong danh mục con', () async {
      expect(
        await run(
          RecipeQuery(
            categoryIds: {main},
            sort: RecipeSort.name,
            ascending: true,
          ),
        ),
        ['Cơm chiên', 'Phở'],
      );
      expect(await run(RecipeQuery(categoryIds: {viet})), ['Phở']);
      expect(
        await run(
          RecipeQuery(
            categoryIds: {viet, soup},
            sort: RecipeSort.name,
            ascending: true,
          ),
        ),
        ['Canh chua', 'Phở'],
      );
    });

    test(
      'thẻ: phải có đủ mọi thẻ chọn, không phân biệt hoa thường và dấu',
      () async {
        expect(
          await run(
            const RecipeQuery(
              tags: {'Nuoc DUNG'},
              sort: RecipeSort.name,
              ascending: true,
            ),
          ),
          ['Canh chua', 'Phở'],
        );
        expect(await run(const RecipeQuery(tags: {'bo', 'nuoc dung'})), [
          'Phở',
        ]);
        expect(await run(const RecipeQuery(tags: {'khong co'})), isEmpty);
      },
    );

    test('số sao tối thiểu, yêu thích, thời gian tối đa', () async {
      expect(
        await run(
          const RecipeQuery(
            minRating: 4,
            sort: RecipeSort.name,
            ascending: true,
          ),
        ),
        ['Cơm chiên', 'Phở'],
      );
      expect(
        await run(
          const RecipeQuery(
            favoriteOnly: true,
            sort: RecipeSort.name,
            ascending: true,
          ),
        ),
        ['Cơm chiên', 'Phở'],
      );
      // Công thức không ghi thời gian không khớp bộ lọc thời gian.
      expect(
        await run(
          const RecipeQuery(
            maxTotalMinutes: 30,
            sort: RecipeSort.name,
            ascending: true,
          ),
        ),
        ['Canh chua', 'Cơm chiên'],
      );
    });

    test('có nguyên liệu X chỉ tìm trong nguyên liệu', () async {
      expect(await run(const RecipeQuery(ingredient: 'TRUNG')), ['Cơm chiên']);
      expect(await run(const RecipeQuery(ingredient: 'ca loc')), ['Canh chua']);
      // "Canh" nằm ở tên chứ không phải nguyên liệu.
      expect(await run(const RecipeQuery(ingredient: 'canh')), isEmpty);
    });

    test('mọi bộ lọc kết hợp với nhau và với ô tìm chữ', () async {
      expect(
        await run(
          RecipeQuery(
            text: 'co',
            categoryIds: {main},
            minRating: 4,
            favoriteOnly: true,
            maxTotalMinutes: 60,
            ingredient: 'com',
          ),
        ),
        ['Cơm chiên'],
      );
      expect(await run(RecipeQuery(categoryIds: {main}, maxTotalMinutes: 30)), [
        'Cơm chiên',
      ]);
      expect(
        await run(RecipeQuery(categoryIds: {soup}, favoriteOnly: true)),
        isEmpty,
      );
    });

    test('isFiltering đúng khi có bộ lọc', () {
      expect(const RecipeQuery().isFiltering, isFalse);
      expect(
        const RecipeQuery(sort: RecipeSort.name, ascending: true).isFiltering,
        isFalse,
      );
      expect(const RecipeQuery(text: 'a').isFiltering, isTrue);
      expect(const RecipeQuery(minRating: 1).isFiltering, isTrue);
      expect(const RecipeQuery(maxTotalMinutes: 10).isFiltering, isTrue);
    });
  });

  group('sắp xếp (AC-13)', () {
    setUp(() async {
      await add('Bánh', rating: 2, cook: 60);
      await add('Ếch rang', rating: 5, cook: 10);
      await add('Cá kho', rating: 5, cook: 90);
      await add('Đậu hũ', rating: 0);
    });

    test('theo tên dùng thứ tự không dấu', () async {
      expect(
        await run(const RecipeQuery(sort: RecipeSort.name, ascending: true)),
        ['Bánh', 'Cá kho', 'Đậu hũ', 'Ếch rang'],
      );
      expect(await run(const RecipeQuery(sort: RecipeSort.name)), [
        'Ếch rang',
        'Đậu hũ',
        'Cá kho',
        'Bánh',
      ]);
    });

    test('theo ngày thêm và ngày sửa, mới nhất trước khi giảm dần', () async {
      expect(await run(const RecipeQuery(sort: RecipeSort.created)), [
        'Đậu hũ',
        'Cá kho',
        'Ếch rang',
        'Bánh',
      ]);
      expect(
        await run(const RecipeQuery(sort: RecipeSort.updated, ascending: true)),
        ['Bánh', 'Ếch rang', 'Cá kho', 'Đậu hũ'],
      );
    });

    test('theo đánh giá, bằng nhau thì theo tên', () async {
      expect(await run(const RecipeQuery(sort: RecipeSort.rating)), [
        'Cá kho',
        'Ếch rang',
        'Bánh',
        'Đậu hũ',
      ]);
    });

    test(
      'theo thời gian nấu, công thức không ghi thời gian xếp cuối',
      () async {
        expect(
          await run(
            const RecipeQuery(sort: RecipeSort.cookTime, ascending: true),
          ),
          ['Ếch rang', 'Bánh', 'Cá kho', 'Đậu hũ'],
        );
        expect(await run(const RecipeQuery(sort: RecipeSort.cookTime)), [
          'Cá kho',
          'Bánh',
          'Ếch rang',
          'Đậu hũ',
        ]);
      },
    );

    test('theo lần nấu gần nhất, chưa nấu xếp cuối', () async {
      final ids = {
        for (final r in await repo.search(const RecipeQuery())) r.name: r.id,
      };
      now = DateTime(2026, 11, 10);
      await repo.markCooked(ids['Bánh']!);
      now = DateTime(2026, 11, 12);
      await repo.markCooked(ids['Cá kho']!);
      final desc = await run(const RecipeQuery(sort: RecipeSort.lastCooked));
      expect(desc.sublist(0, 2), ['Cá kho', 'Bánh']);
      expect(desc.sublist(2), ['Đậu hũ', 'Ếch rang']);
      final asc = await run(
        const RecipeQuery(sort: RecipeSort.lastCooked, ascending: true),
      );
      expect(asc.sublist(0, 2), ['Bánh', 'Cá kho']);
      expect(asc.sublist(2).toSet(), {'Ếch rang', 'Đậu hũ'});
    });
  });

  group('danh mục và thẻ của công thức (AC-10, AC-11)', () {
    test('lưu và đọc lại đúng, thẻ trùng bị gộp', () async {
      final a = await cats.add('A');
      final b = await cats.add('B');
      final id = await add(
        'X',
        categoryIds: [b, a, a],
        tags: ['  Chay ', 'chay', 'CHAY', 'Nồi chiên'],
      );
      final r = (await repo.getRecipe(id))!;
      expect(r.draft.categoryIds, unorderedEquals([a, b]));
      expect(r.draft.tags, ['Chay', 'Nồi chiên']);

      await repo.save(
        r.draft.copyWith(categoryIds: [b], tags: []),
        id: id,
      );
      final r2 = (await repo.getRecipe(id))!;
      expect(r2.draft.categoryIds, [b]);
      expect(r2.draft.tags, isEmpty);
    });

    test('thẻ quá 40 ký tự bị từ chối', () async {
      await expectLater(
        repo.save(RecipeDraft(name: 'X', tags: ['a' * 41])),
        throwsA(isA<RecipeValidationException>()),
      );
    });

    test(
      'gợi ý thẻ theo tiền tố không dấu, nhiều công thức đứng đầu',
      () async {
        await add('1', tags: ['chay', 'nồi chiên']);
        await add('2', tags: ['Chay']);
        await add('3', tags: ['chuẩn bị trước']);
        expect(await repo.suggestTags('ch'), ['chay', 'chuẩn bị trước']);
        expect(await repo.suggestTags('noi'), ['nồi chiên']);
        expect(await repo.suggestTags(''), [
          'chay',
          'chuẩn bị trước',
          'nồi chiên',
        ]);
        expect(await repo.suggestTags('zzz'), isEmpty);
      },
    );

    test('nhân bản giữ danh mục và thẻ', () async {
      final a = await cats.add('A');
      final id = await add('X', categoryIds: [a], tags: ['chay']);
      final copyId = await repo.duplicate(id, copyLabel: 'bản sao');
      final copy = (await repo.getRecipe(copyId))!;
      expect(copy.draft.categoryIds, [a]);
      expect(copy.draft.tags, ['chay']);
    });

    test('xóa hẳn công thức xóa liên kết danh mục, thẻ, lịch sử nấu', () async {
      final a = await cats.add('A');
      final id = await add('X', categoryIds: [a], tags: ['chay']);
      await repo.markCooked(id);
      await repo.moveToTrash(id);
      await repo.deleteForever(id);
      expect(await db.select(db.recipeCategories).get(), isEmpty);
      expect(await db.select(db.recipeTags).get(), isEmpty);
      expect(await db.select(db.cookLog).get(), isEmpty);
    });
  });

  group('đã nấu (AC-15)', () {
    test('ghi ngày nấu, đếm số lần và lần gần nhất', () async {
      final id = await add('X');
      var r = (await repo.getRecipe(id))!;
      expect(r.cookCount, 0);
      expect(r.lastCookedAt, isNull);

      now = DateTime(2026, 11, 5, 18);
      await repo.markCooked(id);
      now = DateTime(2026, 11, 9, 12);
      await repo.markCooked(id);
      r = (await repo.getRecipe(id))!;
      expect(r.cookCount, 2);
      expect(r.lastCookedAt, DateTime(2026, 11, 9, 12));
      expect(await repo.cookHistory(id), [
        DateTime(2026, 11, 9, 12),
        DateTime(2026, 11, 5, 18),
      ]);
    });

    test('nấu không đổi ngày sửa công thức', () async {
      final id = await add('X');
      final before = (await repo.getRecipe(id))!.updatedAt;
      now = now.add(const Duration(days: 3));
      await repo.markCooked(id);
      expect((await repo.getRecipe(id))!.updatedAt, before);
    });

    test('danh sách có số lần nấu và lần gần nhất', () async {
      final id = await add('X');
      await repo.markCooked(id);
      final s = (await repo.search(const RecipeQuery())).single;
      expect(s.cookCount, 1);
      expect(s.lastCookedAt, now);
    });
  });
}
