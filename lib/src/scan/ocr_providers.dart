import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'android_tesseract_engine.dart';
import 'ocr_engine.dart';

/// Bộ nhận chữ của nền tảng đang chạy; null khi nền tảng chưa có (màn "+"
/// ẩn mục "Quét ảnh"). Test ghi đè bằng `FakeOcrEngine`.
///
/// iOS (phiên #2): thêm nhánh `TargetPlatform.iOS` trả engine Apple Vision.
final ocrEngineProvider = Provider<OcrEngine?>((ref) {
  final engine = switch (defaultTargetPlatform) {
    TargetPlatform.android when !kIsWeb => AndroidTesseractEngine(),
    _ => null,
  };
  if (engine != null) ref.onDispose(engine.dispose);
  return engine;
});
