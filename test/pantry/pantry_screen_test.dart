import 'package:cooknote/src/data/pantry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

PantryRepository _repo(TestApp app) =>
    PantryRepository(app.db, clock: () => testNow);

Future<void> _openPantry(WidgetTester tester) async {
  await tester.tap(find.text('Tủ bếp').last);
  await settle(tester);
}

void main() {
  testWidgets('tìm trong tủ bếp không dấu, xoá ô tìm', (tester) async {
    final app = await pumpApp(tester, clock: () => testNow);
    await tester.runAsync(() async {
      await _repo(app).add(const PantryDraft(name: 'Hành tây'));
      await _repo(app).add(const PantryDraft(name: 'Sữa tươi'));
    });
    await _openPantry(tester);
    expect(find.text('Hành tây'), findsOneWidget);
    expect(find.text('Sữa tươi'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'hanh');
    await settle(tester);
    expect(find.text('Hành tây'), findsOneWidget);
    expect(find.text('Sữa tươi'), findsNothing);

    await tester.tap(find.byTooltip('Xóa ô tìm'));
    await settle(tester);
    expect(find.text('Sữa tươi'), findsOneWidget);
  });

  testWidgets('cảnh báo khi hạn dùng trước ngày mua', (tester) async {
    final app = await pumpApp(tester, clock: () => testNow);
    await tester.runAsync(
      () => _repo(app).add(
        PantryDraft(
          name: 'Sữa chua',
          purchasedOn: DateTime(2026, 11, 3),
          expiresOn: DateTime(2026, 11, 1),
        ),
      ),
    );
    await _openPantry(tester);
    await tester.tap(find.text('Sữa chua'));
    await settle(tester);
    expect(
      find.text('Hạn dùng trước ngày mua — kiểm tra lại ngày'),
      findsOneWidget,
    );
  });
}
