import 'line_classifier.dart';
import 'ocr_engine.dart';

/// Một dòng sau quét: chữ OCR + gợi ý vai trò từ [classifyRecipeLines].
///
/// [suggestion] có chữ đã làm sạch và vai trò gợi ý; [ocrConfidence] là độ tin
/// cậy của bộ nhận chữ (chữ đọc đúng không), khác với
/// `suggestion.confidence` (vai trò đoán đúng không).
class ScannedLine {
  const ScannedLine({
    required this.ocr,
    required this.page,
    required this.suggestion,
  });

  final OcrLine ocr;

  /// Chỉ số trang (0..), theo thứ tự ảnh đưa vào.
  final int page;
  final ClassifiedLine suggestion;

  double get ocrConfidence => ocr.confidence;

  /// Dòng nên tô nhạt trên màn gán dòng để người dùng kiểm lại.
  bool get isDoubtful =>
      ocr.confidence < kDoubtfulOcrConfidence ||
      suggestion.confidence < kDoubtfulRoleConfidence;
}

/// Ngưỡng tô nhạt (đề xuất, chỉnh sau khi thử máy thật).
const kDoubtfulOcrConfidence = 0.6;
const kDoubtfulRoleConfidence = 0.5;

class ScanResult {
  const ScanResult({
    required this.imagePaths,
    required this.pages,
    required this.lines,
  });

  /// Ảnh đã quét, cùng thứ tự với [pages].
  final List<String> imagePaths;
  final List<OcrPage> pages;
  final List<ScannedLine> lines;

  /// Toàn bộ chữ nhận được, trang cách nhau một dòng trống (để sao chép, hay
  /// dán vào `test/scan/ocr_samples/` khi đo AC-25).
  String get plainText => pages.map((p) => p.text).join('\n\n');

  Duration get totalElapsed =>
      pages.fold(Duration.zero, (sum, p) => sum + p.elapsed);
}

/// Nhận chữ lần lượt từng ảnh (≤ [kMaxScanPages]) rồi gợi ý vai trò cho mọi
/// dòng như một văn bản liền (công thức có thể vắt qua hai trang sách).
///
/// [onProgress] được gọi trước mỗi trang (done = số trang đã xong) và một
/// lần cuối với done == total. Huỷ bằng `engine.cancel()`: hàm ném
/// [OcrException] mã [OcrErrorCode.cancelled].
Future<ScanResult> scanImages(
  OcrEngine engine,
  List<String> imagePaths, {
  OcrOptions options = const OcrOptions(),
  void Function(int done, int total)? onProgress,
}) async {
  if (imagePaths.isEmpty) {
    throw ArgumentError.value(imagePaths, 'imagePaths', 'must not be empty');
  }
  if (imagePaths.length > kMaxScanPages) {
    throw ArgumentError.value(
      imagePaths.length,
      'imagePaths',
      'at most $kMaxScanPages pages',
    );
  }
  final total = imagePaths.length;
  final pages = <OcrPage>[];
  for (var i = 0; i < total; i++) {
    onProgress?.call(i, total);
    pages.add(await engine.recognize(imagePaths[i], options: options));
  }
  onProgress?.call(total, total);
  return ScanResult(
    imagePaths: List.unmodifiable(imagePaths),
    pages: List.unmodifiable(pages),
    lines: classifyPages(pages),
  );
}

/// Vẽ PDF ra ảnh rồi [scanImages]. Trả cả [PdfPages] để màn quét báo khi file
/// dài hơn [kMaxScanPages] trang (chỉ quét các trang đầu).
Future<(PdfPages, ScanResult)> scanPdf(
  OcrEngine engine,
  String pdfPath, {
  OcrOptions options = const OcrOptions(),
  void Function(int done, int total)? onProgress,
}) async {
  final pdf = await engine.renderPdf(pdfPath);
  if (pdf.imagePaths.isEmpty) {
    throw const OcrException(OcrErrorCode.pdfUnreadable, 'No pages');
  }
  final result = await scanImages(
    engine,
    pdf.imagePaths,
    options: options,
    onProgress: onProgress,
  );
  return (pdf, result);
}

/// Ghép dòng của mọi trang và gợi ý vai trò. Dòng trống bị bỏ.
List<ScannedLine> classifyPages(List<OcrPage> pages) {
  final kept = <(int, OcrLine)>[
    for (var p = 0; p < pages.length; p++)
      for (final line in pages[p].lines)
        if (line.text.trim().isNotEmpty) (p, line),
  ];
  final classified = classifyRecipeLines([for (final k in kept) k.$2.text]);
  // classifyRecipeLines trả đúng một kết quả cho mỗi dòng không trống.
  assert(classified.length == kept.length);
  return [
    for (var i = 0; i < kept.length; i++)
      ScannedLine(ocr: kept[i].$2, page: kept[i].$1, suggestion: classified[i]),
  ];
}
