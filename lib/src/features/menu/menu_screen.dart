import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// STUB F0 — SCR-34/35/36 · Menu (week · day · month). Route `/menu`. Nhóm G5 Thực đơn + Tủ bếp thay RUỘT file này;
/// GIỮ tên lớp và hàm khởi tạo (xem notes/2026-11-05-f0-design-system.md).
/// Gốc tab Thực đơn; chế độ xem qua query `?view=week|day|month&date=YYYY-MM-DD`.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) => StubScreen(
    scr: 'SCR-34/35/36',
    title: 'Menu (week · day · month)',
    group: 'G5 Thực đơn + Tủ bếp',
  );
}
