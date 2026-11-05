import 'package:flutter/services.dart';

import 'ocr_engine.dart';

/// [OcrEngine] cho Android: Tesseract4Android 4.9.0 (Tesseract 5.5.1, bản
/// openmp), dữ liệu `vie`+`eng` tessdata_fast đóng gói trong
/// `assets/tessdata/`. Mã Kotlin: `android/app/src/main/kotlin/com/phiotron/
/// cooknote/ocr/`.
///
/// Giao thức kênh `com.phiotron.cooknote/ocr` (iOS Vision ở #2 có thể làm
/// đúng giao thức này để dùng chung lớp Dart):
/// - `recognize` {path: String, languages: String, pageSegMode: int} →
///   {lines: [{text: String, confidence: double 0..1, block: int,
///   box: [left, top, right, bottom] 0..1 | null}], width: int, height: int,
///   elapsedMs: int, engine: String}
/// - `renderPdf` {path: String, maxPages: int ≤ 10} →
///   {pages: [String đường dẫn JPEG], pageCount: int}
/// - `warmUp`, `cancel`, `release` → null
/// - Lỗi: `PlatformException.code` là một giá trị của [OcrErrorCode].
class AndroidTesseractEngine implements OcrEngine {
  AndroidTesseractEngine({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.phiotron.cooknote/ocr';

  final MethodChannel _channel;

  @override
  Future<OcrPage> recognize(
    String imagePath, {
    OcrOptions options = const OcrOptions(),
  }) async {
    final map = await _invoke<Map<Object?, Object?>>('recognize', {
      'path': imagePath,
      'languages': options.languages,
      'pageSegMode': options.pageSegMode,
    });
    return OcrPage.fromChannelMap(map ?? const {});
  }

  @override
  Future<PdfPages> renderPdf(
    String pdfPath, {
    int maxPages = kMaxScanPages,
  }) async {
    final map = await _invoke<Map<Object?, Object?>>('renderPdf', {
      'path': pdfPath,
      'maxPages': maxPages.clamp(1, kMaxScanPages),
    });
    final pages = (map?['pages'] as List<Object?>? ?? const []).cast<String>();
    return PdfPages(
      List.unmodifiable(pages),
      (map?['pageCount'] as num?)?.toInt() ?? pages.length,
    );
  }

  @override
  Future<void> warmUp() => _invoke<void>('warmUp');

  @override
  Future<void> cancel() => _invoke<void>('cancel');

  @override
  Future<void> dispose() => _invoke<void>('release');

  Future<T?> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      throw OcrException(e.code, e.message);
    } on MissingPluginException {
      throw const OcrException(
        OcrErrorCode.unavailable,
        'OCR channel not registered',
      );
    }
  }
}
