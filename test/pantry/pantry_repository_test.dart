import 'package:cooknote/src/data/pantry_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/v3_test_support.dart';

void main() {
  late V3Env env;

  setUp(() async => env = await V3Env.create(now: DateTime(2026, 11, 5, 20)));
  tearDown(() => env.dispose());

  group('AC-42 tủ bếp: hạn dùng và bộ lọc', () {
    test('tên, số lượng tùy chọn, khu vực, ngày mua, hạn dùng', () async {
      final id = await env.pantry.add(
        PantryDraft(
          name: ' Thịt bò ',
          amount: '500 g',
          purchasedOn: DateTime(2026, 11, 4),
          expiresOn: DateTime(2026, 11, 7),
        ),
      );
      await env.pantry.add(
        const PantryDraft(name: 'rau muống', amount: '1 bó nhỏ'),
      );
      await env.pantry.add(const PantryDraft(name: 'gạo'));
      final items = await env.pantry.getItems();
      final beef = items.firstWhere((i) => i.id == id);
      expect(beef.name, 'Thịt bò');
      expect(beef.amountLabel(), '500 g');
      expect(beef.purchasedOn, DateTime(2026, 11, 4));
      expect(beef.expiresOn, DateTime(2026, 11, 7));
      expect(beef.status, ExpiryStatus.soon);
      final veg = items.firstWhere((i) => i.name == 'rau muống');
      expect(veg.amountLabel(), '1 bó nhỏ');
      expect(
        veg.purchasedOn,
        DateTime(2026, 11, 5),
        reason: 'mặc định hôm nay',
      );
      final rice = items.firstWhere((i) => i.name == 'gạo');
      expect(rice.amountLabel(), '');
      expect(rice.status, ExpiryStatus.none);
      expect(rice.aisleId, isNotNull, reason: 'tự xếp khu vực');

      await env.pantry.update(
        id,
        PantryDraft(name: 'Thịt bò', amount: '300 g', expiresOn: null),
      );
      final edited = (await env.pantry.getItems()).firstWhere(
        (i) => i.id == id,
      );
      expect(edited.amountLabel(), '300 g');
      expect(edited.status, ExpiryStatus.none);
      await env.pantry.delete(id);
      expect((await env.pantry.getItems()).length, 2);
      expect(
        () => env.pantry.add(const PantryDraft(name: '')),
        throwsA(isA<PantryException>()),
      );
    });

    test('Sắp hết hạn (≤ 3 ngày), Hết hạn, lọc theo hai trạng thái', () async {
      Future<void> add(String name, DateTime? exp) =>
          env.pantry.add(PantryDraft(name: name, expiresOn: exp));
      await add('sữa', DateTime(2026, 11, 8)); // còn 3 ngày
      await add('trứng', DateTime(2026, 11, 9)); // còn 4 ngày
      await add('đậu hũ', DateTime(2026, 11, 5)); // hôm nay
      await add('thịt', DateTime(2026, 11, 4)); // hôm qua
      await add('muối', null);

      final all = await env.pantry.getItems();
      expect(all.map((i) => (i.name, i.status)), [
        ('thịt', ExpiryStatus.expired),
        ('đậu hũ', ExpiryStatus.soon),
        ('sữa', ExpiryStatus.soon),
        ('trứng', ExpiryStatus.fresh),
        ('muối', ExpiryStatus.none),
      ]);
      expect(
        (await env.pantry.getItems(filter: PantryFilter.soon))
            .map((i) => i.name),
        ['đậu hũ', 'sữa'],
      );
      expect(
        (await env.pantry.getItems(filter: PantryFilter.expired))
            .map((i) => i.name),
        ['thịt'],
      );
      expect(await env.pantry.watchExpiryCounts().first, (soon: 2, expired: 1));

      // Qua ngày: trạng thái tính lại theo đồng hồ.
      env.now = DateTime(2026, 11, 9, 8);
      expect(
        (await env.pantry.getItems(filter: PantryFilter.expired))
            .map((i) => i.name),
        ['thịt', 'đậu hũ', 'sữa'],
      );
    });
  });

  group('AC-43 Nấu được gì?', () {
    test('xếp theo tỉ lệ, khớp không dấu và số nhiều, bỏ thùng rác', () async {
      final salad = await env.recipe('Salad', [
        '2 tomatoes',
        '1 cucumber',
        '3 eggs',
      ]);
      final bo = await env.recipe('Bò xào', ['300 g thịt bò', '1 củ hành tây']);
      final pho = await env.recipe('Phở', [
        '500 g thịt bò',
        'bánh phở',
        'hành lá',
        'quế',
      ]);
      final trashed = await env.recipe('Bò kho', ['thịt bò']);
      await env.recipes.moveToTrash(trashed);
      await env.recipe('Chè', ['đậu xanh']);
      for (final n in ['TOMATO', 'Cucumbers', 'egg', 'thit bo', 'Hành tây']) {
        await env.pantry.add(PantryDraft(name: n));
      }
      final out = await env.pantry.cookable(ignoreBasics: false);
      // Bò xào và Salad cùng 100%, cùng thiếu 0: theo tên.
      expect(out.map((c) => c.id), [bo, salad, pho]);
      expect(out.first.missingCount, 0);
      expect(out.last.missing, ['bánh phở', 'hành lá', 'quế']);
      expect(out.last.ratio, 0.25);
    });

    test('gia vị cơ bản không tính thiếu khi bật tùy chọn', () async {
      final id = await env.recipe('Thịt kho', [
        '500 g thịt heo',
        'nước mắm',
        '2 muỗng canh đường',
        'tiêu',
        '1 l nước',
      ]);
      await env.pantry.add(const PantryDraft(name: 'thịt heo'));
      final off = await env.pantry.cookable(ignoreBasics: false);
      expect(off.single.missingCount, 4);
      final on = await env.pantry.cookable(ignoreBasics: true);
      expect(on.single.id, id);
      expect(on.single.missingCount, 0);
      expect(on.single.ratio, 1);
    });

    test('tính lại khi tủ bếp đổi', () async {
      await env.recipe('Trứng chiên', ['2 quả trứng', 'hành lá']);
      final stream = env.pantry.watchCookable(ignoreBasics: false);
      final seen = <int>[];
      final sub = stream.listen((l) => seen.add(l.length));
      await pumpEventQueue();
      await env.pantry.add(const PantryDraft(name: 'trứng'));
      await pumpEventQueue();
      await sub.cancel();
      expect(seen.first, 0);
      expect(seen.last, 1);
    });
  });
}
