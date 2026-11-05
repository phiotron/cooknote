import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'components/bep_navigation_bar.dart';

/// Gốc 5 tab (AC-01): Công thức · Thực đơn · Đi chợ · Tủ bếp · Thêm.
const List<String> kTabRoots = ['/', '/menu', '/shopping', '/pantry', '/more'];

/// Khung ứng dụng: thanh dưới 5 mục + nội dung từng tab (mỗi tab giữ ngăn xếp và vị trí
/// cuộn riêng nhờ StatefulShellRoute). Thanh dưới chỉ hiện ở gốc tab (§4.3): màn con
/// khai `parentNavigatorKey` là navigator gốc nên phủ lên khung và không có thanh này.
///
/// Không dùng Scaffold ngoài: Scaffold của từng tab là "gốc" nên SnackBar nổi trên nút +
/// của tab đó và thanh dưới nằm ngoài nó.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      BepNavItem(
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
        label: l.tabRecipes,
      ),
      BepNavItem(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: l.tabMenu,
      ),
      BepNavItem(
        icon: Icons.shopping_basket_outlined,
        selectedIcon: Icons.shopping_basket_rounded,
        label: l.tabShopping,
      ),
      BepNavItem(
        icon: Icons.kitchen_outlined,
        selectedIcon: Icons.kitchen_rounded,
        label: l.tabPantry,
      ),
      BepNavItem(
        icon: Icons.more_horiz_rounded,
        selectedIcon: Icons.more_horiz_rounded,
        label: l.tabMore,
      ),
    ];
    final index = navigationShell.currentIndex;
    return PopScope(
      // Android Back ở tab khác về tab đầu, rồi mới thoát app.
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Column(
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: navigationShell,
            ),
          ),
          BepNavigationBar(
            items: items,
            selectedIndex: index,
            onSelected: (i) =>
                navigationShell.goBranch(i, initialLocation: i == index),
          ),
        ],
      ),
    );
  }
}
