import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/ui/linkified_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<int> _insert(WidgetTester tester, TestApp app, String name) async {
  final repo = RecipeRepository(app.db, app.images, clock: () => testNow);
  final id = await tester.runAsync(
    () => repo.save(
      RecipeDraft(
        name: name,
        ingredients: const [RecipeLine('2 quả trứng')],
        steps: const [RecipeLine('Đánh trứng')],
      ),
    ),
  );
  await settle(tester);
  return id!;
}

void main() {
  testWidgets('có 5 mục điều hướng và trạng thái trống (AC-01)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    for (final t in ['Công thức', 'Thực đơn', 'Đi chợ', 'Tủ bếp', 'Thêm']) {
      expect(find.text(t), findsWidgets);
    }
    expect(find.text('Chưa có công thức nào'), findsOneWidget);
    expect(find.byTooltip('Thêm công thức'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('chữ giao diện theo ngôn ngữ đã chọn', (tester) async {
    final app = await pumpApp(tester, localeCode: 'en');
    expect(find.text('No recipes yet'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('thêm công thức tự viết rồi xem lại (AC-01, AC-03, AC-04)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await tester.tap(find.byTooltip('Thêm công thức'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tự viết'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tên'),
      'Bánh flan',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nguyên liệu'),
      'Phần caramel:\n100 g đường\n3 quả trứng',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Các bước'),
      '1. Nấu đường\n2. Hấp 20 phút',
    );
    await tester.tap(find.text('Lưu'));
    await settle(tester);

    // Sang màn xem công thức.
    expect(find.text('Bánh flan'), findsWidgets);
    expect(find.text('Phần caramel'), findsOneWidget);
    expect(find.text('100 g đường'), findsOneWidget);
    expect(find.text('Nấu đường'), findsOneWidget);
    expect(find.text('Hấp 20 phút'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('thiếu tên thì không lưu được (AC-03)', (tester) async {
    final app = await pumpApp(tester);
    await tester.tap(find.byTooltip('Thêm công thức'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tự viết'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Hãy nhập tên'), findsOneWidget);
    expect(find.text('Công thức mới'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('bấm Back khi đã sửa thì hỏi Bỏ thay đổi (AC-03)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await tester.tap(find.byTooltip('Thêm công thức'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tự viết'));
    await tester.pumpAndSettle();

    // Chưa sửa gì thì thoát thẳng.
    await systemBack(tester);
    expect(find.text('Bỏ thay đổi?'), findsNothing);
    expect(find.text('Chưa có công thức nào'), findsOneWidget);

    await tester.tap(find.byTooltip('Thêm công thức'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tự viết'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Tên'), 'Nháp');
    await systemBack(tester);
    expect(find.text('Bỏ thay đổi?'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục sửa'));
    await tester.pumpAndSettle();
    expect(find.text('Công thức mới'), findsOneWidget);

    await systemBack(tester);
    await tester.tap(find.text('Bỏ'));
    await settle(tester);
    expect(find.text('Chưa có công thức nào'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('xóa có xác nhận, hoàn tác, thùng rác (AC-05)', (tester) async {
    final app = await pumpApp(tester);
    final id = await _insert(tester, app, 'Canh chua');
    expect(find.text('Canh chua'), findsOneWidget);

    await tester.tap(find.text('Canh chua'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa công thức này?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await settle(tester);

    expect(find.text('Chưa có công thức nào'), findsOneWidget);
    expect(find.text('Đã xóa công thức'), findsOneWidget);
    await tester.tap(find.text('Hoàn tác'));
    await settle(tester);
    expect(find.text('Canh chua'), findsOneWidget);

    // Xóa lần nữa, rồi khôi phục từ thùng rác.
    await tester.runAsync(
      () => RecipeRepository(app.db, app.images).moveToTrash(id),
    );
    await settle(tester);
    await tester.tap(find.text('Thêm').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thùng rác'));
    await settle(tester);
    expect(find.text('Canh chua'), findsOneWidget);
    await tester.tap(find.byTooltip('Khôi phục'));
    await settle(tester);
    expect(find.text('Thùng rác trống'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('thêm ảnh từ thư viện và camera, gỡ ảnh, giới hạn 20 (AC-07)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await tester.tap(find.byTooltip('Thêm công thức'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tự viết'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Tên'), 'Có ảnh');

    await tester.tap(find.text('Thêm ảnh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Từ thư viện'));
    await tester.pumpAndSettle();
    await waitUntil(
      tester,
      () => find.byTooltip('Gỡ ảnh').evaluate().length == 2,
    );
    expect(app.picker.lastLimit, 20);
    expect(find.text('Ảnh bìa'), findsOneWidget);
    expect(find.byTooltip('Gỡ ảnh'), findsNWidgets(2));

    await tester.tap(find.text('Thêm ảnh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chụp ảnh'));
    await tester.pumpAndSettle();
    await waitUntil(
      tester,
      () => find.byTooltip('Gỡ ảnh').evaluate().length == 3,
    );
    expect(app.picker.cameraCalls, 1);
    expect(find.byTooltip('Gỡ ảnh'), findsNWidgets(3));

    // Gỡ ảnh vừa thêm thì yêu cầu xóa file ngay.
    final all = app.images.directory
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .toSet();
    expect(all.length, 3);
    await tester.tap(find.byTooltip('Gỡ ảnh').first);
    await waitUntil(tester, () => app.images.deleted.length == 1);
    final removedFirst = app.images.deleted.single;
    expect(all, contains(removedFirst));

    // Bỏ thay đổi thì yêu cầu xóa nốt hai ảnh vừa thêm còn lại.
    await systemBack(tester);
    await tester.tap(find.text('Bỏ'));
    await waitUntil(tester, () => app.images.deleted.length == 3);
    expect(app.images.deleted.toSet(), all);
    await disposeApp(tester, app);
  });

  test('nhận ra URL trong chữ và cắt dấu câu cuối (AC-09)', () {
    final parts = splitLinks('Xem https://a.vn/b?c=1, rồi (http://x.com).');
    expect(parts.where((p) => p.isLink).map((p) => p.text), [
      'https://a.vn/b?c=1',
      'http://x.com',
    ]);
    expect(
      parts.map((p) => p.text).join(),
      'Xem https://a.vn/b?c=1, rồi (http://x.com).',
    );
    expect(splitLinks('không có link'), [
      (text: 'không có link', isLink: false),
    ]);
  });
}
