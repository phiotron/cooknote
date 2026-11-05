import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// STUB F0 — SCR-23 · Cook mode. Route `/cook/:recipeId`. Nhóm G3 Chế độ nấu thay RUỘT file này;
/// GIỮ tên lớp và hàm khởi tạo (xem notes/2026-11-05-f0-design-system.md).
/// Toàn màn hình, không có thanh dưới; rời đi thì hẹn giờ vẫn chạy.
class CookScreen extends StatelessWidget {
  const CookScreen({super.key, required this.recipeId});

  final int recipeId;

  @override
  Widget build(BuildContext context) => StubScreen(
    scr: 'SCR-23',
    title: 'Cook mode',
    group: 'G3 Chế độ nấu',
    params: {'recipeId': recipeId},
  );
}
