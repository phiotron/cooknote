import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// ĐIỂM NỐI CỐ ĐỊNH (F0): "Thêm vào thực đơn" (SCR-37). G1 gọi từ chi tiết công thức với
/// [recipeId]; G5 thay ruột (giữ chữ ký). [date] dạng `YYYY-MM-DD` và [slotId] điền sẵn
/// ngày/bữa khi mở từ một ô của lịch; null thì người dùng chọn trong bảng.
Future<void> showAddToMenuSheet(
  BuildContext context,
  int recipeId, {
  String? date,
  int? slotId,
}) => showBepSheet<void>(
  context,
  builder: (_) => StubScreen(
    scr: 'SCR-37',
    title: 'Add to meal',
    group: 'G5 Thực đơn + Tủ bếp',
    showAppBar: false,
    params: {'recipeId': recipeId, 'date': date, 'slotId': slotId},
  ),
);
