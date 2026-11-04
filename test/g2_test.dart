import 'package:cooknote/src/data/category_repository.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

RecipeRepository _repo(TestApp app) =>
    RecipeRepository(app.db, app.images, clock: () => testNow);

Future<int> _insert(
  WidgetTester tester,
  TestApp app,
  String name, {
  List<int> categoryIds = const [],
  List<String> tags = const [],
  String? ingredient,
}) async {
  final id = await tester.runAsync(
    () => _repo(app).save(
      RecipeDraft(
        name: name,
        categoryIds: categoryIds,
        tags: tags,
        ingredients: [if (ingredient != null) RecipeLine(ingredient)],
      ),
    ),
  );
  await settle(tester);
  return id!;
}

Future<List<Category>> _categories(WidgetTester tester, TestApp app) async =>
    (await tester.runAsync(() => CategoryRepository(app.db).getAll()))!;

Future<void> _openMore(WidgetTester tester, String item) async {
  await tester.tap(find.text('Thêm').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await settle(tester);
}

void main() {
  testWidgets('tìm không dấu, đếm kết quả, xóa ô tìm (AC-12)', (tester) async {
    final app = await pumpApp(tester);
    await _insert(tester, app, 'Phở bò');
    await _insert(tester, app, 'Bánh flan');
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Bánh flan'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'pho');
    await settle(tester);
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Bánh flan'), findsNothing);
    expect(find.text('1 công thức'), findsOneWidget);

    await tester.tap(find.byTooltip('Xóa ô tìm'));
    await settle(tester);
    expect(find.text('Bánh flan'), findsOneWidget);
    expect(find.text('1 công thức'), findsNothing);
    await disposeApp(tester, app);
  });

  testWidgets('không khớp thì báo và xóa bộ lọc được (AC-13)', (tester) async {
    final app = await pumpApp(tester);
    await _insert(tester, app, 'Phở bò');
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await settle(tester);
    expect(find.text('Không có công thức nào khớp'), findsOneWidget);
    expect(find.text('0 công thức'), findsNothing);

    await tester.tap(find.text('Xóa bộ lọc'));
    await settle(tester);
    expect(find.text('Phở bò'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '',
    );
    await disposeApp(tester, app);
  });

  testWidgets('lọc theo danh mục trong bảng lọc (AC-13)', (tester) async {
    final app = await pumpApp(tester);
    final cats = await _categories(tester, app);
    final main = cats.firstWhere((c) => c.name == 'Món chính');
    final dessert = cats.firstWhere((c) => c.name == 'Tráng miệng');
    await _insert(tester, app, 'Phở bò', categoryIds: [main.id]);
    await _insert(tester, app, 'Bánh flan', categoryIds: [dessert.id]);

    await tester.tap(find.text('Lọc'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Món chính'));
    await settle(tester);
    await tester.tap(find.text('Xong'));
    await settle(tester);

    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Bánh flan'), findsNothing);
    expect(find.text('Lọc (1)'), findsOneWidget);
    expect(find.text('1 công thức'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('sắp xếp theo tên từ menu (AC-13)', (tester) async {
    final app = await pumpApp(tester);
    await _insert(tester, app, 'Bánh flan');
    await _insert(tester, app, 'Ếch rang');
    await _insert(tester, app, 'Cá kho');

    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    // Mặc định: mới sửa trước (công thức thêm sau lên trên).
    expect(y('Cá kho') < y('Ếch rang'), isTrue);

    await tester.tap(find.byTooltip('Sắp xếp'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckedPopupMenuItem<Object>, 'Tên'));
    await settle(tester);
    expect(y('Bánh flan') < y('Cá kho'), isTrue);
    expect(y('Cá kho') < y('Ếch rang'), isTrue);

    await tester.tap(find.byTooltip('Sắp xếp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giảm dần'));
    await settle(tester);
    expect(y('Ếch rang') < y('Cá kho'), isTrue);
    await disposeApp(tester, app);
  });

  testWidgets('chọn xem lưới, được giữ sau khi mở lại app (AC-14)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await _insert(tester, app, 'Phở bò');
    expect(find.byType(GridView), findsNothing);

    await tester.tap(find.byTooltip('Xem dạng lưới'));
    await settle(tester);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byTooltip('Xem dạng dòng'), findsOneWidget);

    // "Mở lại app": cùng cơ sở dữ liệu, cây widget mới.
    await tester.pumpWidget(const SizedBox());
    final again = await pumpApp(tester, db: app.db);
    expect(find.byType(GridView), findsOneWidget);
    final saved = await tester.runAsync(
      () => SettingsRepository(app.db).watchViewMode().first,
    );
    expect(saved, 'grid');
    await disposeApp(tester, again);
  });

  testWidgets('danh mục mặc định, thêm, đổi tên, xóa, giới hạn 3 cấp (AC-10)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await _openMore(tester, 'Danh mục');
    for (final n in [
      'Món chính',
      'Món phụ',
      'Canh/Súp',
      'Tráng miệng',
      'Đồ uống',
      'Bánh',
    ]) {
      expect(find.text(n), findsOneWidget);
    }

    // Thêm danh mục cấp đầu.
    await tester.tap(find.byTooltip('Thêm danh mục'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Món chay');
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Món chay'), findsOneWidget);

    // Thêm tới cấp 3, cấp 4 không có mục "Thêm danh mục con".
    Future<void> addChild(String parent, String child) async {
      final menu = find.descendant(
        of: find.widgetWithText(ListTile, parent),
        matching: find.byType(PopupMenuButton<String>),
      );
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm danh mục con'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), child);
      await tester.tap(find.text('Lưu'));
      await settle(tester);
    }

    await addChild('Món chay', 'Món Việt');
    await addChild('Món Việt', 'Món bún');
    expect(find.text('Món bún'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Món bún'),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Thêm danh mục con'), findsNothing);
    expect(find.text('Đổi tên'), findsOneWidget);
    await tester.tap(find.text('Đổi tên'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Món bún phở');
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Món bún phở'), findsOneWidget);

    // Xóa cha thì con cũng mất.
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Món chay'),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await settle(tester);
    expect(find.text('Món chay'), findsNothing);
    expect(find.text('Món Việt'), findsNothing);
    expect(find.text('Món bún phở'), findsNothing);
    await disposeApp(tester, app);
  });

  testWidgets(
    'chọn danh mục và thẻ khi soạn, xem lại ở màn chi tiết (AC-10, AC-11)',
    (tester) async {
      final app = await pumpApp(tester);
      await _insert(tester, app, 'Cũ', tags: ['chay', 'nồi chiên']);

      await tester.tap(find.byTooltip('Thêm công thức'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tự viết'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Tên'), 'Mới');

      // Danh mục.
      await tester.ensureVisible(find.text('Chọn danh mục'));
      await tester.tap(find.text('Chọn danh mục'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Món chính'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xong'));
      await tester.pumpAndSettle();

      // Thẻ: gõ để gợi ý, chạm gợi ý; gõ thẻ mới kết thúc bằng dấu phẩy.
      final tagField = find.widgetWithText(TextField, 'Thẻ');
      await tester.ensureVisible(tagField);
      await tester.enterText(tagField, 'no');
      await waitUntil(
        tester,
        () =>
            find.widgetWithText(ActionChip, 'nồi chiên').evaluate().isNotEmpty,
      );
      await tester.tap(find.widgetWithText(ActionChip, 'nồi chiên'));
      await tester.pumpAndSettle();
      await tester.enterText(tagField, 'nhanh,');
      await tester.pumpAndSettle();
      // Thẻ gõ dở vẫn được lưu.
      await tester.enterText(tagField, 'cuối tuần');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lưu'));
      await settle(tester);

      expect(find.text('Món chính'), findsOneWidget);
      for (final t in ['nồi chiên', 'nhanh', 'cuối tuần']) {
        expect(find.text(t), findsOneWidget);
      }
      await disposeApp(tester, app);
    },
  );

  testWidgets('đánh dấu đã nấu, hiện số lần và lần gần nhất (AC-15)', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await _insert(tester, app, 'Canh chua');
    await tester.tap(find.text('Canh chua'));
    await settle(tester);
    expect(find.text('Chưa nấu lần nào'), findsOneWidget);

    await tester.tap(find.text('Đánh dấu đã nấu'));
    await settle(tester);
    expect(find.textContaining('Đã nấu 1 lần'), findsOneWidget);
    expect(find.textContaining('Lần gần nhất:'), findsOneWidget);

    await tester.tap(find.text('Đánh dấu đã nấu'));
    await settle(tester);
    expect(find.textContaining('Đã nấu 2 lần'), findsOneWidget);
    await disposeApp(tester, app);
  });
}
