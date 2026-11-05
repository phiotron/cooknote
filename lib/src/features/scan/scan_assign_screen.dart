import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// STUB F0 — SCR-21 · Scan: assign lines. Route `/scan/assign`. Nhóm G2 Đưa công thức vào thay RUỘT file này;
/// GIỮ tên lớp và hàm khởi tạo (xem notes/2026-11-05-f0-design-system.md).
/// `extra` của route đi vào [pages]; kiểu thật do G2 quyết (giữ tên tham số).
class ScanAssignScreen extends StatelessWidget {
  const ScanAssignScreen({super.key, this.pages});

  final Object? pages;

  @override
  Widget build(BuildContext context) => StubScreen(
    scr: 'SCR-21',
    title: 'Scan: assign lines',
    group: 'G2 Đưa công thức vào',
    params: {'pages': pages},
  );
}
