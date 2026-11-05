import 'package:cooknote/src/cook/cook_providers.dart';
import 'package:cooknote/src/cook/platform_services.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:cooknote/src/features/home/home_screen.dart';
import 'package:cooknote/src/features/menu/add_to_menu_sheet.dart';
import 'package:cooknote/src/features/shopping/add_to_shopping_sheet.dart';
import 'package:cooknote/src/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

/// Thông báo giả: không gọi plugin.
class _NoNotifications implements TimerNotifications {
  @override
  Future<bool> isEnabled() async => false;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String channelName,
    required String channelDescription,
  }) async {}
  @override
  Future<void> cancel(int id) async {}
}

Future<void> _go(WidgetTester tester, String path) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(path);
  await tester.pumpAndSettle();
}

final _overrides = [
  timerNotificationsProvider.overrideWithValue(_NoNotifications()),
];

void main() {
  testWidgets('5 tab: mỗi tab vào được màn của nó, thanh dưới đổi mục chọn', (
    tester,
  ) async {
    final app = await pumpApp(tester, overrides: _overrides);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Chưa có công thức nào'), findsOneWidget);

    await tester.tap(find.text('Thực đơn'));
    await tester.pumpAndSettle();
    expect(find.text('SCR-34/35/36'), findsOneWidget);

    await tester.tap(find.text('Đi chợ'));
    await tester.pumpAndSettle();
    expect(find.text('SCR-27'), findsOneWidget);

    await tester.tap(find.text('Tủ bếp'));
    await tester.pumpAndSettle();
    expect(find.text('SCR-43'), findsOneWidget);

    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    expect(find.text('Sao lưu'), findsWidgets);

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      4,
    );
    await tester.tap(find.text('Công thức'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có công thức nào'), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('mỗi tab giữ trạng thái (cây của tab khác không bị gỡ)', (
    tester,
  ) async {
    final app = await pumpApp(tester, overrides: _overrides);
    await tester.tap(find.text('Đi chợ'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
    await disposeApp(tester, app);
  });

  testWidgets('Back hệ thống ở tab khác về tab Công thức', (tester) async {
    final app = await pumpApp(tester, overrides: _overrides);
    await tester.tap(find.text('Tủ bếp'));
    await tester.pumpAndSettle();
    expect(find.text('SCR-43'), findsOneWidget);
    await systemBack(tester);
    expect(find.text('Chưa có công thức nào'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    await disposeApp(tester, app);
  });

  group('mọi route của product.md §4.2 đã khai', () {
    // (đường dẫn, chữ có trên màn, có thanh dưới không)
    const routes = <(String, String, bool)>[
      ('/menu', 'SCR-34/35/36', true),
      ('/shopping', 'SCR-27', true),
      ('/pantry', 'SCR-43', true),
      ('/more', 'Sao lưu', true),
      ('/onboarding', 'SCR-01', false),
      ('/web/preview', 'SCR-17', false),
      ('/web/pick', 'SCR-16', false),
      ('/share?text=abc', 'SCR-18', false),
      ('/scan', 'SCR-19/20', false),
      ('/scan/assign', 'SCR-21', false),
      ('/cook/7', 'SCR-23', false),
      ('/menu/templates', 'SCR-39', false),
      ('/menu/random', 'SCR-40', false),
      ('/settings/meal-slots', 'SCR-42', false),
      ('/shopping/aisles', 'SCR-31', false),
      ('/pantry/can-cook', 'SCR-45', false),
      ('/exchange', 'SCR-52', false),
      ('/settings/delete-all', 'SCR-54', false),
      ('/about', 'SCR-55', false),
      ('/licenses', 'SCR-56', false),
    ];
    for (final (path, text, hasNav) in routes) {
      testWidgets('$path → $text, ${hasNav ? 'có' : 'không có'} thanh dưới', (
        tester,
      ) async {
        final app = await pumpApp(tester, overrides: _overrides);
        await _go(tester, path);
        expect(find.text(text), findsWidgets);
        expect(
          find.byType(NavigationBar),
          hasNav ? findsOneWidget : findsNothing,
        );
        await disposeApp(tester, app);
      });
    }

    testWidgets('/cook/:recipeId nhận recipeId; màn cũ vẫn ở đúng route', (
      tester,
    ) async {
      final app = await pumpApp(tester, overrides: _overrides);
      await _go(tester, '/cook/42');
      expect(find.textContaining('recipeId=42'), findsOneWidget);
      for (final (path, nav) in [
        ('/settings', false),
        ('/backup', false),
        ('/categories', false),
        ('/trash', false),
        ('/import', false),
        ('/recipe/new', false),
      ]) {
        await _go(tester, path);
        expect(
          find.byType(NavigationBar),
          nav ? findsOneWidget : findsNothing,
          reason: path,
        );
        expect(tester.takeException(), isNull, reason: path);
      }
      await disposeApp(tester, app);
    });
  });

  testWidgets('điểm nối: showAddToShoppingSheet / showAddToMenuSheet', (
    tester,
  ) async {
    final app = await pumpApp(tester, overrides: _overrides);
    final ctx = tester.element(find.byType(NavigationBar));
    showAddToShoppingSheet(ctx, 5);
    await tester.pumpAndSettle();
    expect(find.text('SCR-32'), findsOneWidget);
    expect(find.textContaining('recipes=[5]'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // đóng bảng
    await tester.pumpAndSettle();
    showAddToMenuSheet(ctx, 9, date: '2026-11-05', slotId: 2);
    await tester.pumpAndSettle();
    expect(find.text('SCR-37'), findsOneWidget);
    expect(find.textContaining('recipeId=9'), findsOneWidget);
    await disposeApp(tester, app);
  });

  group('viên thuốc hẹn giờ toàn cục (SCR-24)', () {
    Future<void> startTimer(WidgetTester tester, {int recipeId = 3}) async {
      final c = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      await c
          .read(timersProvider.notifier)
          .start(
            name: 'Bước 3 · 5 phút',
            recipeId: recipeId,
            recipeName: 'Phở bò',
            seconds: 300,
            notificationTitle: 't',
            notificationBody: 'b',
            channelName: 'c',
            channelDescription: 'd',
          );
      await tester.pump();
    }

    Future<void> cancelAll(WidgetTester tester) async {
      final c = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      for (final t in c.read(timersProvider).running) {
        await c.read(timersProvider.notifier).cancel(t.id);
      }
      await tester.pump();
    }

    testWidgets('hiện trên gốc tab và màn khác, ẩn trong Chế độ nấu', (
      tester,
    ) async {
      final app = await pumpApp(tester, overrides: _overrides);
      expect(find.textContaining('05:00'), findsNothing);
      await startTimer(tester);
      expect(find.text('Bước 3 · 5 phút · 05:00'), findsOneWidget);
      await _go(tester, '/trash');
      expect(find.text('Bước 3 · 5 phút · 05:00'), findsOneWidget);
      await _go(tester, '/cook/3');
      expect(find.text('Bước 3 · 5 phút · 05:00'), findsNothing);
      await cancelAll(tester);
      await disposeApp(tester, app);
    });

    testWidgets('nhiều hẹn giờ: "2 hẹn giờ · mm:ss"; chạm → Chế độ nấu', (
      tester,
    ) async {
      final app = await pumpApp(tester, overrides: _overrides);
      await startTimer(tester, recipeId: 3);
      await startTimer(tester, recipeId: 8);
      expect(find.text('2 hẹn giờ · 05:00'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Đang chạy 2 hẹn giờ')),
        findsOneWidget,
      );
      await tester.tap(find.text('2 hẹn giờ · 05:00'));
      await tester.pumpAndSettle();
      expect(find.textContaining('recipeId=3'), findsOneWidget);
      await cancelAll(tester);
      await disposeApp(tester, app);
    });

    testWidgets('không có hẹn giờ thì không chiếm chỗ', (tester) async {
      final app = await pumpApp(tester, overrides: _overrides);
      expect(find.byIcon(Icons.timer_rounded), findsNothing);
      await disposeApp(tester, app);
    });
  });

  group('theme áp cho cả app', () {
    testWidgets('sáng theo mặc định (hệ thống sáng): màu nền giấy, Lora', (
      tester,
    ) async {
      final app = await pumpApp(tester, overrides: _overrides);
      final ctx = tester.element(find.byType(NavigationBar));
      final t = Theme.of(ctx);
      expect(t.colorScheme.primary, bepbookLightScheme.primary);
      expect(t.scaffoldBackgroundColor, bepbookLightScheme.surface);
      expect(t.textTheme.titleLarge!.fontFamily, kSerifFamily);
      expect(ctx.bep.ribbon, cookNoteColorsLight.ribbon);
      await disposeApp(tester, app);
    });

    testWidgets('công tắc chủ đề tối của Cài đặt đổi sang bảng màu tối', (
      tester,
    ) async {
      final db = memoryDatabase();
      await tester.runAsync(
        () => SettingsRepository(db).setThemeMode(ThemeMode.dark),
      );
      final app = await pumpApp(tester, db: db, overrides: _overrides);
      await settle(tester);
      final ctx = tester.element(find.byType(NavigationBar));
      expect(Theme.of(ctx).colorScheme.primary, bepbookDarkScheme.primary);
      expect(ctx.bep.cookSurface, cookNoteColorsDark.cookSurface);
      await disposeApp(tester, app);
    });

    testWidgets('chữ 200%: 5 tab + màn Công thức không tràn', (tester) async {
      final app = await pumpApp(tester, overrides: _overrides);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final t in ['Thực đơn', 'Đi chợ', 'Tủ bếp', 'Thêm']) {
        await tester.tap(find.byTooltip(t));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: t);
      }
      await disposeApp(tester, app);
    });
  });
}
