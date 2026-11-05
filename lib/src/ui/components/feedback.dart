import 'package:flutter/material.dart';

import '../messenger.dart';
import '../theme/theme.dart';
import 'bep_button.dart';

/// Thanh thông báo (SCR-57): nền inverseSurface, tối đa 2 dòng, nút hành động tuỳ chọn;
/// nổi phía trên thanh dưới/FAB (Scaffold tự đặt). Dùng `rootMessengerKey` nên còn hiện
/// sau khi đóng màn. Nút "Hoàn tác" 5 giây: dùng `showUndoSnackBar` có sẵn.
void showBepSnackBar(
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 5),
}) {
  rootMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        duration: duration,
        margin: lifted(),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
}

/// Hộp xác nhận (SCR-57). Trả true khi bấm xác nhận, false khi huỷ/đóng.
/// [destructive] đổi nút xác nhận sang màu lỗi và biểu tượng cảnh báo; mặc định nút huỷ
/// đứng trước, nút xác nhận đứng cuối (khớp quy ước Material).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
  IconData? icon,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        icon: icon == null && !destructive
            ? null
            : Icon(
                icon ?? Icons.warning_amber_rounded,
                color: destructive ? cs.error : cs.secondary,
              ),
        title: Text(title),
        content: body == null ? null : SingleChildScrollView(child: Text(body)),
        actionsOverflowButtonSpacing: 4,
        actions: [
          BepButton(
            label: cancelLabel,
            kind: BepButtonKind.text,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          BepButton(
            label: confirmLabel,
            kind: destructive ? BepButtonKind.dangerText : BepButtonKind.text,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

/// Bảng đáy chuẩn (SCR-57): bo 28, có tay nắm, cuộn được, tránh vùng an toàn.
/// [builder] nhận context của bảng. Dùng thay `showModalBottomSheet` để bật cuộn ở chữ 200%.
Future<T?> showBepSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (ctx) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom + BepSpace.s2,
      ),
      child: builder(ctx),
    ),
  ),
);
