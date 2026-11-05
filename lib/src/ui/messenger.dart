import 'package:flutter/material.dart';

/// ScaffoldMessenger chung, để thanh "Hoàn tác" còn hiện sau khi đóng màn.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Khoảng nâng thanh thông báo (dp) khi viên thuốc hẹn giờ đang hiện, để thanh không che nó
/// (SCR-57). `app.dart` đặt giá trị; mọi hàm hiện thanh trong file này dùng nó.
final snackBarLift = ValueNotifier<double>(0);

EdgeInsets? lifted() => snackBarLift.value > 0
    ? EdgeInsets.fromLTRB(12, 0, 12, 12 + snackBarLift.value)
    : null;

/// Hiện thanh "Đã xóa · Hoàn tác" trong 5 giây (AC-05).
void showUndoSnackBar({
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
}) {
  rootMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        persist: false,
        margin: lifted(),
        action: SnackBarAction(label: undoLabel, onPressed: onUndo),
      ),
    );
}

void showMessage(String message) {
  rootMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), margin: lifted()));
}
