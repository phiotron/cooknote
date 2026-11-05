import 'package:cooknote/src/cooking/ingredient_parser.dart';
import 'package:cooknote/src/data/aisle_repository.dart';
import 'package:cooknote/src/data/pantry_repository.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/data/shopping_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/v3_test_support.dart';

void main() {
  late V3Env env;
  late int list;

  setUp(() async {
    env = await V3Env.create();
    list = (await env.shopping.getLists()).single.id;
  });
  tearDown(() => env.dispose());

  Future<List<String>> labels([int? id]) async => [
    for (final i in await env.shopping.getItems(id ?? list))
      '${i.checked ? 'x ' : ''}${i.label()}',
  ];

  Future<Aisle> aisle(String key) async =>
      (await env.aisles.getAll()).firstWhere((a) => a.key == key);

  group('AC-34 nhiều danh sách, thêm tay, gợi ý, món hay mua', () {
    test('danh sách mặc định theo ngôn ngữ, tạo/đổi tên/xóa/sắp', () async {
      expect((await env.shopping.getLists()).single.name, 'Đi chợ');
      final market = await env.shopping.createList('Chợ');
      final shop = await env.shopping.createList(' Siêu thị ');
      expect((await env.shopping.getLists()).map((l) => l.name), [
        'Đi chợ',
        'Chợ',
        'Siêu thị',
      ]);
      await env.shopping.renameList(market, 'Chợ Bến Thành');
      await env.shopping.reorderLists([shop, market, list]);
      expect((await env.shopping.getLists()).map((l) => l.name), [
        'Siêu thị',
        'Chợ Bến Thành',
        'Đi chợ',
      ]);
      await env.shopping.addText(shop, 'sữa');
      await env.shopping.deleteList(shop);
      expect((await env.shopping.getLists()).length, 2);
      expect(await env.db.select(env.db.shoppingItems).get(), isEmpty);
      expect(
        () => env.shopping.createList('  '),
        throwsA(isA<ShoppingException>()),
      );
    });

    test('mỗi danh sách giữ món riêng', () async {
      final other = await env.shopping.createList('Siêu thị');
      await env.shopping.addText(list, '500 g thịt bò');
      await env.shopping.addText(other, '500 g thịt bò');
      expect(await labels(), ['500 g thịt bò']);
      expect(await labels(other), ['500 g thịt bò']);
      final infos = await env.shopping.getLists();
      expect(infos.map((l) => l.itemCount), [1, 1]);
    });

    test('thêm tay tách số lượng; dòng không số lượng giữ chữ', () async {
      await env.shopping.addText(list, '2-3 củ hành tây');
      await env.shopping.addText(list, 'muối vừa ăn');
      await env.shopping.addText(list, 'sữa tươi, loại không đường');
      final items = await env.shopping.getItems(list);
      final onion = items.firstWhere((i) => i.name == 'hành tây');
      expect(onion.quantity.value, 3, reason: 'khoảng lấy số lớn');
      expect(onion.quantity.unit, IngredientUnit.cu);
      expect(items.map((i) => i.name), containsAll(['muối', 'sữa tươi']));
      expect(
        items.firstWhere((i) => i.name == 'sữa tươi').label(),
        'sữa tươi (loại không đường)',
      );
    });

    test('gõ để gợi ý từ các món đã từng thêm, không dấu', () async {
      await env.shopping.addText(list, 'Thịt bò');
      await env.shopping.addText(list, 'thịt heo');
      await env.shopping.addText(list, 'thịt heo');
      await env.shopping.addText(list, 'bánh tráng');
      final s = await env.shopping.suggest('thit');
      expect(s.map((k) => k.name), ['thịt heo', 'Thịt bò']);
      expect((await env.shopping.suggest('trang')).single.name, 'bánh tráng');
      expect(await env.shopping.suggest('ca'), isEmpty);
      expect(await env.shopping.suggest(''), isEmpty);
    });

    test('Món hay mua: món đã ghim trước, rồi món mua nhiều lần', () async {
      for (var i = 0; i < 3; i++) {
        await env.shopping.addText(list, 'trứng gà');
      }
      await env.shopping.addText(list, 'sữa');
      await env.shopping.addText(list, 'sữa');
      await env.shopping.addText(list, 'nấm');
      await env.shopping.setFavorite('Bánh mì', true);
      await env.shopping.setFavorite('nước mắm', true);
      expect((await env.shopping.frequent()).map((k) => k.name), [
        'Bánh mì',
        'nước mắm',
        'trứng gà',
        'sữa',
      ]);
      await env.shopping.reorderFavorites(['nuoc mam', 'banh mi']);
      await env.shopping.setFavorite('trứng gà', true);
      expect((await env.shopping.frequent()).map((k) => k.name).take(3), [
        'nước mắm',
        'Bánh mì',
        'trứng gà',
      ]);
      await env.shopping.setFavorite('Bánh mì', false);
      expect(
        (await env.shopping.frequent()).map((k) => k.name),
        isNot(contains('Bánh mì')),
      );
    });
  });

  group('AC-35 thêm từ công thức, gộp món trùng', () {
    test('cùng tên cùng loại đơn vị thì gộp, ghi nguồn công thức', () async {
      final pho = await env.recipe('Phở bò', ['200 g thịt bò', '1 củ hành']);
      final bo = await env.recipe('Bò xào', ['300 g Thịt Bò', '2 trái ớt']);
      await env.shopping.addCandidates(
        list,
        await env.shopping.candidatesForRecipe(pho),
      );
      final r = await env.shopping.addCandidates(
        list,
        await env.shopping.candidatesForRecipe(bo),
      );
      expect((r.added, r.merged), (1, 1));
      final items = await env.shopping.getItems(list);
      final beef = items.firstWhere((i) => i.name == 'thịt bò');
      expect(beef.label(), '500 g thịt bò');
      expect(beef.sources.map((s) => (s.recipeId, s.recipeName)), [
        (pho, 'Phở bò'),
        (bo, 'Bò xào'),
      ]);
    });

    test('khác loại đơn vị thì để hai dòng', () async {
      await env.shopping.addText(list, '200 g thịt bò');
      await env.shopping.addText(list, '1 hộp thịt bò');
      await env.shopping.addText(list, '1 kg thịt bò');
      expect(await labels(), ['1.2 kg thịt bò', '1 hộp thịt bò']);
    });

    test('không gộp vào món đã gạch', () async {
      await env.shopping.addText(list, '200 g thịt bò');
      final first = (await env.shopping.getItems(list)).single;
      await env.shopping.setChecked(first.id, true);
      await env.shopping.addText(list, '300 g thịt bò');
      expect(await labels(), ['300 g thịt bò', 'x 200 g thịt bò']);
    });

    test('theo khẩu phần đang chọn', () async {
      final id = await env.recipes.save(
        const RecipeDraft(
          name: 'Bánh',
          servings: 4,
          ingredients: [
            RecipeLine('Cốt bánh', isHeading: true),
            RecipeLine('200 g bột mì'),
            RecipeLine('2 quả trứng'),
            RecipeLine('muối vừa ăn'),
          ],
        ),
      );
      final c = await env.shopping.candidatesForRecipe(id, servings: 6);
      expect(c.map((e) => e.label()), ['300 g bột mì', '3 quả trứng', 'muối']);
      final same = await env.shopping.candidatesForRecipe(id);
      expect(same.first.label(), '200 g bột mì');
    });

    test('mặc định bỏ chọn món đang có trong Tủ bếp', () async {
      await env.pantry.add(const PantryDraft(name: 'Hành tây'));
      await env.pantry.add(const PantryDraft(name: 'egg'));
      final id = await env.recipe('Trứng chiên', [
        '3 large eggs',
        '1 củ hành tây',
        '1 củ hành tím',
        'tiêu',
      ]);
      final c = await env.shopping.candidatesForRecipe(id);
      expect(
        {for (final e in c) e.name: e.selected},
        {
          'large eggs': false,
          'hành tây': false,
          'hành tím': true,
          'tiêu': true,
        },
      );
      final r = await env.shopping.addCandidates(list, c);
      expect(r.added, 2);
      expect((await env.shopping.getItems(list)).map((i) => i.name), [
        'hành tím',
        'tiêu',
      ]);
    });
  });

  group('AC-36 khu vực', () {
    test('8 khu vực mặc định theo ngôn ngữ', () async {
      expect((await env.aisles.getAll()).map((a) => a.name), [
        'Rau củ',
        'Thịt cá',
        'Sữa trứng',
        'Đồ khô',
        'Gia vị',
        'Đông lạnh',
        'Đồ uống',
        'Khác',
      ]);
      final en = await V3Env.create(language: 'en');
      addTearDown(en.dispose);
      expect((await en.aisles.getAll()).first.name, 'Produce');
    });

    test(
      'món tự xếp khu vực theo từ điển, xếp danh sách theo khu vực',
      () async {
        await env.shopping.addText(list, 'nước mắm');
        await env.shopping.addText(list, '500 g thịt bò');
        await env.shopping.addText(list, 'cà chua');
        await env.shopping.addText(list, 'đồ gì đó lạ');
        final items = await env.shopping.getItems(list);
        expect(items.map((i) => i.name), [
          'cà chua',
          'thịt bò',
          'nước mắm',
          'đồ gì đó lạ',
        ]);
        expect(items.first.aisleId, (await aisle('produce')).id);
        expect(items.last.aisleId, (await aisle('other')).id);
      },
    );

    test('chuyển món sang khu vực khác thì lần sau app nhớ', () async {
      await env.shopping.addText(list, 'đậu hũ');
      final item = (await env.shopping.getItems(list)).single;
      expect(item.aisleId, (await aisle('dairy')).id);
      final dry = (await aisle('dry')).id;
      await env.shopping.moveToAisle(item.id, dry);
      await env.shopping.deleteItem(item.id);
      await env.shopping.addText(list, 'Đậu hũ');
      expect((await env.shopping.getItems(list)).single.aisleId, dry);
      // Tủ bếp dùng cùng trí nhớ.
      await env.pantry.add(const PantryDraft(name: 'dau hu'));
      expect((await env.pantry.getItems()).single.aisleId, dry);
    });

    test('thêm, đổi tên, sắp xếp, xóa khu vực', () async {
      final bakery = await env.aisles.add('Tiệm bánh');
      await env.aisles.rename((await aisle('meat')).id, 'Hàng thịt');
      final ids = [for (final a in await env.aisles.getAll()) a.id];
      await env.aisles.reorder([bakery, ...ids.where((i) => i != bakery)]);
      final all = await env.aisles.getAll();
      expect(all.first.name, 'Tiệm bánh');
      expect(all[2].name, 'Hàng thịt');
      expect(all[2].key, 'meat');

      await env.shopping.addText(list, 'thịt gà');
      await env.aisles.delete(all[2].id);
      final item = (await env.shopping.getItems(list)).single;
      expect(item.aisleId, isNull, reason: 'khu vực bị xóa thì không khu vực');
      await env.shopping.addText(list, 'thịt heo');
      expect(
        (await env.shopping.getItems(list))
            .firstWhere((i) => i.name == 'thịt heo')
            .aisleId,
        (await aisle('other')).id,
      );
      expect(() => env.aisles.add(''), throwsA(isA<AisleException>()));
    });
  });

  group('AC-37 gạch, xóa đã gạch, chuyển vào tủ bếp, chia sẻ', () {
    test('món đã gạch xuống cuối, bỏ gạch thì lên lại', () async {
      await env.shopping.addText(list, 'cà chua');
      await env.shopping.addText(list, 'hành lá');
      await env.shopping.addText(list, 'thịt bò');
      final items = await env.shopping.getItems(list);
      await env.shopping.setChecked(items.first.id, true);
      env.now = env.now.add(const Duration(minutes: 1));
      await env.shopping.setChecked(items[1].id, true);
      expect(await labels(), ['thịt bò', 'x cà chua', 'x hành lá']);
      await env.shopping.setChecked(items.first.id, false);
      expect(await labels(), ['cà chua', 'thịt bò', 'x hành lá']);
      expect((await env.shopping.getLists()).single.remaining, 2);
    });

    test('xóa các món đã gạch, có chuyển vào Tủ bếp', () async {
      await env.shopping.addText(list, '500 g thịt bò');
      await env.shopping.addText(list, 'cà chua');
      await env.shopping.addText(list, 'muối');
      final items = await env.shopping.getItems(list);
      for (final i in items.take(2)) {
        await env.shopping.setChecked(i.id, true);
      }
      expect(await env.shopping.clearChecked(list, toPantry: true), 2);
      expect(await labels(), ['muối']);
      final pantry = await env.pantry.getItems();
      expect(pantry.map((p) => p.name), ['cà chua', 'thịt bò']);
      final beef = pantry.firstWhere((p) => p.name == 'thịt bò');
      expect(beef.amountLabel(), '500 g');
      expect(beef.purchasedOn, DateTime(2026, 11, 5));
      expect(beef.aisleId, (await aisle('meat')).id);

      final salt = (await env.shopping.getItems(list)).single;
      await env.shopping.setChecked(salt.id, true);
      expect(await env.shopping.clearChecked(list), 1);
      expect((await env.pantry.getItems()).length, 2);
    });

    test('chia sẻ dạng chữ: món chưa gạch theo khu vực', () async {
      await env.shopping.addText(list, '500 g thịt bò');
      await env.shopping.addText(list, '1,5 kg cà chua');
      await env.shopping.addText(list, 'nước mắm');
      await env.shopping.addText(list, 'bia');
      final beer = (await env.shopping.getItems(list)).last;
      await env.shopping.setChecked(beer.id, true);
      await env.shopping.moveToAisle(
        (await env.shopping.getItems(list))
            .firstWhere((i) => i.name == 'nước mắm')
            .id,
        null,
      );
      expect(
        await env.shopping.exportText(
          list,
          noAisleLabel: 'Khác',
          decimalComma: true,
        ),
        'Đi chợ\n\nRau củ\n- 1,5 kg cà chua\n\nThịt cá\n- 500 g thịt bò\n\n'
        'Khác\n- nước mắm\n',
      );
    });

    test('sửa món bằng dòng chữ mới', () async {
      await env.shopping.addText(list, '500 g thịt bò');
      final item = (await env.shopping.getItems(list)).single;
      await env.shopping.editItem(item.id, '700 g thịt bò xay');
      expect(await labels(), ['700 g thịt bò xay']);
    });
  });
}
