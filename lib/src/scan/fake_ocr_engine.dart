import 'dart:async';

import 'ocr_engine.dart';

/// [OcrEngine] giả cho test và widget test: trả chữ định sẵn theo đường dẫn
/// ảnh, ghi lại các lời gọi, giả lập lỗi và huỷ.
class FakeOcrEngine implements OcrEngine {
  FakeOcrEngine({
    Map<String, OcrPage>? pages,
    Map<String, PdfPages>? pdfs,
    this.delay = Duration.zero,
  }) : pages = pages ?? {},
       pdfs = pdfs ?? {};

  /// Mỗi ảnh một chuỗi; mỗi hàng thành một [OcrLine] với [confidence].
  factory FakeOcrEngine.fromText(
    Map<String, String> textByPath, {
    double confidence = 0.9,
    Duration delay = Duration.zero,
  }) => FakeOcrEngine(
    pages: {
      for (final e in textByPath.entries)
        e.key: OcrPage(
          lines: [
            for (final line in e.value.split('\n')) OcrLine(line, confidence),
          ],
          engine: 'fake',
        ),
    },
    delay: delay,
  );

  final Map<String, OcrPage> pages;
  final Map<String, PdfPages> pdfs;

  /// Thời gian giả mỗi trang (để thử huỷ giữa chừng).
  final Duration delay;

  /// Ảnh có trong đây ném [OcrException] với mã tương ứng.
  final Map<String, String> errors = {};

  final List<String> recognized = [];
  int warmUps = 0;
  int cancels = 0;
  int disposes = 0;

  var _epoch = 0;

  @override
  Future<OcrPage> recognize(
    String imagePath, {
    OcrOptions options = const OcrOptions(),
  }) async {
    final epoch = _epoch;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (epoch != _epoch) throw const OcrException(OcrErrorCode.cancelled);
    final code = errors[imagePath];
    if (code != null) throw OcrException(code);
    recognized.add(imagePath);
    final page = pages[imagePath];
    if (page == null) throw const OcrException(OcrErrorCode.imageUnreadable);
    return page;
  }

  @override
  Future<PdfPages> renderPdf(
    String pdfPath, {
    int maxPages = kMaxScanPages,
  }) async {
    final code = errors[pdfPath];
    if (code != null) throw OcrException(code);
    final pdf = pdfs[pdfPath];
    if (pdf == null) throw const OcrException(OcrErrorCode.pdfUnreadable);
    return PdfPages(pdf.imagePaths.take(maxPages).toList(), pdf.pageCount);
  }

  @override
  Future<void> warmUp() async => warmUps++;

  @override
  Future<void> cancel() async {
    cancels++;
    _epoch++;
  }

  @override
  Future<void> dispose() async => disposes++;
}
