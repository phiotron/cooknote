import 'package:flutter/material.dart';

/// Một mục thanh dưới: [icon] (đường nét) và [selectedIcon] (đặc) + nhãn đầy đủ.
class BepNavItem {
  const BepNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Thanh điều hướng dưới 5 mục (AC-01, S-50). Cỡ chữ nhãn bị chặn ở 1.3× như thanh của
/// hệ điều hành và cắt bằng dấu … (không xuống dòng) để 5 nhãn vừa 360 dp ở chữ 200%;
/// biểu tượng vẫn phân biệt, nhãn đầy đủ nằm ở tooltip và ở nhãn đọc màn hình.
class BepNavigationBar extends StatelessWidget {
  const BepNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<BepNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
    maxScaleFactor: 1.3,
    child: NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        for (final i in items)
          NavigationDestination(
            icon: Icon(i.icon),
            selectedIcon: Icon(i.selectedIcon),
            label: i.label,
            tooltip: i.label,
          ),
      ],
    ),
  );
}
