import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'cook/cook_providers.dart';
import 'cook/timer_alert_host.dart';
import 'features/backup/backup_notice.dart';
import 'features/web_import/share_listener.dart';
import 'providers.dart';
import 'router.dart';
import 'ui/app_shell.dart' show kTabRoots;
import 'ui/ui.dart';

export 'router.dart' show createRouter;

final _router = createRouter();

class CookNoteApp extends ConsumerWidget {
  const CookNoteApp({super.key, this.router});

  /// Test truyền router từ [createRouter].
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(startupProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final localeCode = ref.watch(localeCodeProvider).value;
    final appRouter = router ?? _router;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      builder: (context, child) => ShareIntentListener(
        router: appRouter,
        child: BackupLifecycleObserver(
          child: TimerAlertHost(
            child: Stack(
              children: [
                Positioned.fill(child: child ?? const SizedBox.shrink()),
                _TimerPillLayer(router: appRouter),
              ],
            ),
          ),
        ),
      ),
      routerConfig: appRouter,
      scaffoldMessengerKey: rootMessengerKey,
      themeMode: themeMode,
      theme: bepbookLightTheme(),
      darkTheme: bepbookDarkTheme(),
      locale: localeCode == null ? null : Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// Điểm nối toàn cục (SCR-24): viên thuốc hẹn giờ đang chạy hiện trên mọi màn NGOÀI Chế độ
/// nấu — trên thanh dưới ở gốc tab, sát đáy ở màn khác. Chạm → Chế độ nấu của hẹn giờ gần
/// nhất. Khi có viên thuốc, thanh thông báo được nâng lên để không che nó (`snackBarLift`).
class _TimerPillLayer extends ConsumerWidget {
  const _TimerPillLayer({required this.router});

  final GoRouter router;

  /// Chiều cao thanh dưới (theme NavigationBar) — viên thuốc nằm trên nó.
  static const _navHeight = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(
      timersProvider.select((s) => s.running.isNotEmpty),
      (_, has) => snackBarLift.value = has ? 56 : 0,
    );
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        String path;
        try {
          path = router.routerDelegate.currentConfiguration.uri.path;
        } catch (_) {
          path = '/';
        }
        if (path.startsWith('/cook/')) return const SizedBox.shrink();
        final onTabRoot = kTabRoots.contains(path);
        return Positioned(
          left: 0,
          right: 0,
          bottom: bottomInset + (onTabRoot ? _navHeight : 0) + 12,
          child: Center(
            child: RunningTimerPill(
              onOpen: (recipeId) => router.push('/cook/$recipeId'),
            ),
          ),
        );
      },
    );
  }
}
