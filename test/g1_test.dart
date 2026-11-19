import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

RecipeRepository _repo(TestApp app) =>
    RecipeRepository(app.db, app.images, clock: () => testNow);

Future<int> _insert(
  WidgetTester tester,
  TestApp app,
  String name, {
  double? servings,
  List<RecipeLine> ingredients = const [],
}) async {
  final id = await tester.runAsync(
    () => _repo(app).save(
      RecipeDraft(
        name: name,
        servings: servings,
        ingredients: ingredients,
      ),
    ),
  );
  await settle(tester);
  return id!;
}

void main() {
  testWidgets('chọn nhiều công thức, xóa vào thùng rác, hoàn tác (AC-06)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await _insert(tester, app, 'Phở bò');
    await _insert(tester, app, 'Bánh flan');

    await tester.longPress(find.text('Phở bò'));
    await settle(tester);
    expect(find.text('Đã chọn 1'), findsOneWidget);

    await tester.tap(find.text('Chọn tất cả'));
    await settle(tester);
    expect(find.text('Đã chọn 2'), findsOneWidget);

    await tester.tap(find.text('Xóa vào thùng rác'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(TextButton, 'Xóa vào thùng rác'),
    );
    await settle(tester);
    expect(find.text('Chưa có công thức nào'), findsOneWidget);

    await tester.tap(find.text('Hoàn tác'));
    await settle(tester);
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Bánh flan'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('dọn sạch thùng rác (AC-05)', (tester) async {
    final app = await pumpApp(tester);
    final a = await _insert(tester, app, 'Phở bò');
    final b = await _insert(tester, app, 'Bánh flan');
    await tester.runAsync(() => _repo(app).moveToTrash(a));
    await settle(tester);
    await tester.runAsync(() => _repo(app).moveToTrash(b));
    await settle(tester);

    await tester.tap(find.text('Thêm').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thùng rác'));
    await settle(tester);
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Bánh flan'), findsOneWidget);

    await tester.tap(find.text('Dọn thùng rác'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Dọn thùng rác'));
    await settle(tester);
    expect(find.text('Thùng rác trống'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('nhân khẩu phần ở bảng Khẩu phần & đơn vị (AC-32)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    final id = await _insert(
      tester,
      app,
      'Thịt kho',
      servings: 2,
      ingredients: const [RecipeLine('200 g thịt')],
    );

    await tester.tap(find.text('Thịt kho'));
    await settle(tester);
    await tester.ensureVisible(find.byType(ActionChip));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ActionChip));
    await tester.pumpAndSettle();
    expect(find.text('Khẩu phần & đơn vị'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '2×'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '2×'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xong'));
    await settle(tester);

    // Công thức gốc không đổi, chỉ cách đang xem nhân đôi.
    expect(find.textContaining('400 g'), findsOneWidget);
    final saved = await tester.runAsync(() => _repo(app).getRecipe(id));
    expect(saved!.draft.ingredients.single.text, '200 g thịt');
    await disposeApp(tester, app);
  });
}
