import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// STUB F0 — SCR-17 · Check before saving. Route `/web/preview`. Nhóm G2 Đưa công thức vào thay RUỘT file này;
/// GIỮ tên lớp và hàm khởi tạo (xem notes/2026-11-05-f0-design-system.md).
/// `extra` của route đi vào [source] (kết quả trích công thức từ trang web).
class ImportPreviewScreen extends StatelessWidget {
  const ImportPreviewScreen({super.key, this.source});

  final Object? source;

  @override
  Widget build(BuildContext context) => StubScreen(
    scr: 'SCR-17',
    title: 'Check before saving',
    group: 'G2 Đưa công thức vào',
    params: {'source': source},
  );
}
