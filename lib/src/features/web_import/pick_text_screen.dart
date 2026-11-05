import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// STUB F0 — SCR-16 · Pick text. Route `/web/pick`. Nhóm G2 Đưa công thức vào thay RUỘT file này;
/// GIỮ tên lớp và hàm khởi tạo (xem notes/2026-11-05-f0-design-system.md).
class PickTextScreen extends StatelessWidget {
  const PickTextScreen({super.key, this.source});

  final Object? source;

  @override
  Widget build(BuildContext context) => StubScreen(
    scr: 'SCR-16',
    title: 'Pick text',
    group: 'G2 Đưa công thức vào',
    params: {'source': source},
  );
}
