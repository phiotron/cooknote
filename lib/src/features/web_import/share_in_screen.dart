import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// STUB F0 — SCR-18 · Incoming share. Route `/share`. Nhóm G2 Đưa công thức vào thay RUỘT file này;
/// GIỮ tên lớp và hàm khởi tạo (xem notes/2026-11-05-f0-design-system.md).
/// Query `?text=` hoặc `extra` (String) đi vào [text].
class ShareInScreen extends StatelessWidget {
  const ShareInScreen({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => StubScreen(
    scr: 'SCR-18',
    title: 'Incoming share',
    group: 'G2 Đưa công thức vào',
    params: {'text': text},
  );
}
