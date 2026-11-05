import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/recipe_repository.dart' show RecipeDraft;
import 'features/backup/backup_screen.dart';
import 'features/categories/categories_screen.dart';
import 'features/cook/cook_screen.dart';
import 'features/editor/recipe_editor_screen.dart';
import 'features/exchange/import_screen.dart';
import 'features/home/home_screen.dart';
import 'features/menu/meal_slots_screen.dart';
import 'features/menu/menu_random_screen.dart';
import 'features/menu/menu_screen.dart';
import 'features/menu/menu_templates_screen.dart';
import 'features/more/about_screen.dart';
import 'features/more/delete_all_screen.dart';
import 'features/more/exchange_hub_screen.dart';
import 'features/more/licenses_screen.dart';
import 'features/more/more_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/pantry/can_cook_screen.dart';
import 'features/pantry/pantry_screen.dart';
import 'features/recipes/photo_viewer_screen.dart';
import 'features/recipes/recipe_detail_screen.dart';
import 'features/recipes/trash_screen.dart';
import 'features/scan/scan_assign_screen.dart';
import 'features/scan/scan_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shopping/aisles_screen.dart';
import 'features/shopping/shopping_screen.dart';
import 'features/web_import/import_preview_screen.dart';
import 'features/web_import/pick_text_screen.dart';
import 'features/web_import/share_in_screen.dart';
import 'features/web_import/web_browser_screen.dart';
import 'ui/app_shell.dart';

/// Bảng route của Bepbook (product.md §4.2). Mọi SCR 00–56 đã có chỗ: màn cũ hoặc STUB
/// trong `lib/src/features/<nhóm>/`. Nhóm G1..G6 chỉ thay RUỘT file của mình, không sửa
/// file này. Bảng đầy đủ + chữ ký stub: notes/2026-11-05-f0-design-system.md.
///
/// Quy ước: 5 tab là `StatefulShellRoute`; màn con của một tab khai `parentNavigatorKey`
/// = navigator gốc để phủ kín (không có thanh dưới) mà vẫn là con của gốc tab (Back về tab).
/// Mỗi lần gọi tạo router mới; test dùng để mỗi test bắt đầu ở màn chính.
GoRouter createRouter() {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  GoRoute full(
    String path,
    Widget Function(BuildContext, GoRouterState) builder, {
    List<RouteBase> routes = const [],
  }) => GoRoute(
    path: path,
    parentNavigatorKey: rootKey,
    builder: builder,
    routes: routes,
  );

  int idOf(GoRouterState s, [String key = 'id']) =>
      int.parse(s.pathParameters[key]!);

  return GoRouter(
    navigatorKey: rootKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          // 1 · Công thức
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  full(
                    'recipe/new',
                    (c, s) => RecipeEditorScreen(
                      initialDraft: s.extra is RecipeDraft
                          ? s.extra as RecipeDraft
                          : null,
                    ),
                  ),
                  full(
                    'recipe/:id',
                    (c, s) => RecipeDetailScreen(id: idOf(s)),
                    routes: [
                      full('edit', (c, s) => RecipeEditorScreen(id: idOf(s))),
                      full(
                        'photos',
                        (c, s) => PhotoViewerScreen(
                          id: idOf(s),
                          initialIndex:
                              int.tryParse(
                                s.uri.queryParameters['index'] ?? '',
                              ) ??
                              0,
                        ),
                      ),
                    ],
                  ),
                  full('categories', (c, s) => const CategoriesScreen()),
                  full('trash', (c, s) => const TrashScreen()),
                  // Đưa công thức vào (G2)
                  full(
                    'web',
                    (c, s) => WebBrowserScreen(
                      initialUrl: s.uri.queryParameters['url'],
                    ),
                  ),
                  // Anh em của 'web' (không lồng) để mở được mà không dựng WebView.
                  full(
                    'web/preview',
                    (c, s) => ImportPreviewScreen(source: s.extra),
                  ),
                  full('web/pick', (c, s) => PickTextScreen(source: s.extra)),
                  full(
                    'share',
                    (c, s) => ShareInScreen(
                      text:
                          s.uri.queryParameters['text'] ??
                          (s.extra is String ? s.extra as String : null),
                    ),
                  ),
                  full(
                    'scan',
                    (c, s) => const ScanScreen(),
                    routes: [
                      full(
                        'assign',
                        (c, s) => ScanAssignScreen(pages: s.extra),
                      ),
                    ],
                  ),
                  full('import', (c, s) => const ImportScreen()),
                  // Hệ thống (G6) — mở từ tab Thêm nhưng khai dưới '/' như bảng cũ
                  full(
                    'backup',
                    (c, s) =>
                        BackupScreen(initialRestorePath: s.extra as String?),
                  ),
                  full('settings', (c, s) => const SettingsScreen()),
                  full('exchange', (c, s) => const ExchangeHubScreen()),
                  full('about', (c, s) => const AboutScreen()),
                  full('licenses', (c, s) => const LicensesScreen()),
                ],
              ),
            ],
          ),
          // 2 · Thực đơn
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const MenuScreen(),
                routes: [
                  full('templates', (c, s) => const MenuTemplatesScreen()),
                  full('random', (c, s) => const MenuRandomScreen()),
                ],
              ),
            ],
          ),
          // 3 · Đi chợ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shopping',
                builder: (context, state) => const ShoppingScreen(),
                routes: [full('aisles', (c, s) => const AislesScreen())],
              ),
            ],
          ),
          // 4 · Tủ bếp
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pantry',
                builder: (context, state) => const PantryScreen(),
                routes: [full('can-cook', (c, s) => const CanCookScreen())],
              ),
            ],
          ),
          // 5 · Thêm
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      // Ngoài khung 5 tab (toàn màn hình)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/cook/:recipeId',
        builder: (context, state) =>
            CookScreen(recipeId: idOf(state, 'recipeId')),
      ),
      GoRoute(
        path: '/settings/meal-slots',
        builder: (context, state) => const MealSlotsScreen(),
      ),
      GoRoute(
        path: '/settings/delete-all',
        builder: (context, state) => const DeleteAllDataScreen(),
      ),
    ],
  );
}
