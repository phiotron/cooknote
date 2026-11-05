import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// Một công thức nguồn của bảng "Thêm vào đi chợ" (SCR-32).
class ShoppingSourceRecipe {
  const ShoppingSourceRecipe(this.recipeId, {this.servings, this.onlyLineIds});

  final int recipeId;

  /// Khẩu phần cần mua; null = khẩu phần đang xem (recipeViewProvider) hoặc gốc.
  final double? servings;

  /// Chỉ các dòng nguyên liệu này (id `recipe_lines`); null = tất cả.
  /// "Nấu được gì?" (SCR-45) truyền các dòng còn thiếu.
  final Set<int>? onlyLineIds;
}

/// ĐIỂM NỐI CỐ ĐỊNH (F0): chi tiết công thức → "Thêm vào đi chợ" (SCR-32) cho một công
/// thức ở khẩu phần đang xem. G1 gọi hàm này; G4 thay ruột (giữ chữ ký).
Future<void> showAddToShoppingSheet(BuildContext context, int recipeId) =>
    showAddIngredientsToShoppingSheet(
      context,
      recipes: [ShoppingSourceRecipe(recipeId)],
    );

/// ĐIỂM NỐI CỐ ĐỊNH (F0): dạng tổng quát cho nhiều công thức — Thực đơn theo khoảng ngày
/// (SCR-41) và "Nấu được gì?" (SCR-45, chỉ món thiếu). G5 gọi; G4 làm ruột.
Future<void> showAddIngredientsToShoppingSheet(
  BuildContext context, {
  required List<ShoppingSourceRecipe> recipes,
}) => showBepSheet<void>(
  context,
  builder: (_) => StubScreen(
    scr: 'SCR-32',
    title: 'Add ingredients to shopping',
    group: 'G4 Đi chợ',
    showAppBar: false,
    params: {'recipes': recipes.map((r) => r.recipeId).toList()},
  ),
);
