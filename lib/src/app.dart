import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'features/backup/backup_notice.dart';
import 'features/backup/backup_screen.dart';
import 'features/categories/categories_screen.dart';
import 'features/editor/recipe_editor_screen.dart';
import 'features/home/home_screen.dart';
import 'features/recipes/photo_viewer_screen.dart';
import 'features/recipes/recipe_detail_screen.dart';
import 'features/recipes/trash_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/web_import/share_listener.dart';
import 'features/web_import/web_browser_screen.dart';
import 'data/recipe_repository.dart' show RecipeDraft;
import 'providers.dart';
import 'ui/messenger.dart';

/// Mỗi lần gọi tạo router mới; test dùng để mỗi test bắt đầu ở màn chính.
GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'recipe/new',
          builder: (context, state) => RecipeEditorScreen(
            initialDraft: state.extra is RecipeDraft
                ? state.extra as RecipeDraft
                : null,
          ),
        ),
        GoRoute(
          path: 'web',
          builder: (context, state) =>
              WebBrowserScreen(initialUrl: state.uri.queryParameters['url']),
        ),
        GoRoute(
          path: 'recipe/:id',
          builder: (context, state) =>
              RecipeDetailScreen(id: int.parse(state.pathParameters['id']!)),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => RecipeEditorScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: 'photos',
              builder: (context, state) => PhotoViewerScreen(
                id: int.parse(state.pathParameters['id']!),
                initialIndex:
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0,
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'backup',
          builder: (context, state) => const BackupScreen(),
        ),
        GoRoute(
          path: 'categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: 'trash',
          builder: (context, state) => const TrashScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

final _router = createRouter();

const _seedColor = Color(0xFFB5532A);

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
        child: BackupLifecycleObserver(child: child ?? const SizedBox.shrink()),
      ),
      routerConfig: appRouter,
      scaffoldMessengerKey: rootMessengerKey,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      ),
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
