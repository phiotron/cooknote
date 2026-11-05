/// Giao diện nhận chữ trên máy (F-04, D-003/D-008), tách khỏi nền tảng.
///
/// Android: [AndroidTesseractEngine] (Tesseract4Android qua MethodChannel).
/// iOS (phiên #2): Apple Vision cắm vào bằng một lớp `implements OcrEngine`,
/// có thể dùng lại đúng giao thức kênh và [OcrPage.fromChannelMap].
/// Test và widget test: [FakeOcrEngine].
library;

/// Số trang tối đa một lần quét (AC-23: tối đa 10 ảnh hoặc 10 trang PDF).
const kMaxScanPages = 10;

/// Hộp bao một dòng, toạ độ 0..1 theo ảnh gốc đã xoay thẳng theo EXIF, gốc ở
/// góc trên bên trái (Vision trên iOS dùng gốc dưới trái: phải lật y).
class OcrBox {
  const OcrBox(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  static OcrBox? fromList(Object? value) {
    if (value is! List || value.length < 4) return null;
    final v = value.map((e) => (e as num).toDouble()).toList();
    return OcrBox(v[0], v[1], v[2], v[3]);
  }

  @override
  String toString() => 'OcrBox($left, $top, $right, $bottom)';
}

/// Một dòng chữ nhận được. [confidence] 0..1 do bộ nhận chữ tự đánh giá
/// (Tesseract: độ tin cậy trung bình của dòng); [block] là số khối văn bản
/// trong trang, để màn gán dòng tách cột hay khung nếu muốn.
class OcrLine {
  const OcrLine(this.text, this.confidence, {this.block = 0, this.box});

  final String text;
  final double confidence;
  final int block;
  final OcrBox? box;

  @override
  String toString() => 'OcrLine($text, $confidence)';
}

/// Kết quả một trang. [imageWidth]/[imageHeight] là kích thước ảnh gốc đã
/// xoay thẳng; [engine] ghi phiên bản bộ nhận chữ và dữ liệu (để đo AC-25).
class OcrPage {
  const OcrPage({
    required this.lines,
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.elapsed = Duration.zero,
    this.engine = '',
  });

  final List<OcrLine> lines;
  final int imageWidth;
  final int imageHeight;
  final Duration elapsed;
  final String engine;

  /// Chữ của cả trang, mỗi dòng một hàng (để sao chép hay đo độ chính xác).
  String get text => lines.map((l) => l.text).join('\n');

  /// Đọc kết quả kênh `com.phiotron.cooknote/ocr`, phương thức `recognize`
  /// (giao thức: `android_tesseract_engine.dart`).
  factory OcrPage.fromChannelMap(Map<Object?, Object?> map) {
    final raw = map['lines'] as List<Object?>? ?? const [];
    return OcrPage(
      lines: [
        for (final item in raw.cast<Map<Object?, Object?>>())
          OcrLine(
            item['text'] as String? ?? '',
            ((item['confidence'] as num?) ?? 0).toDouble().clamp(0.0, 1.0),
            block: (item['block'] as num?)?.toInt() ?? 0,
            box: OcrBox.fromList(item['box']),
          ),
      ],
      imageWidth: (map['width'] as num?)?.toInt() ?? 0,
      imageHeight: (map['height'] as num?)?.toInt() ?? 0,
      elapsed: Duration(milliseconds: (map['elapsedMs'] as num?)?.toInt() ?? 0),
      engine: map['engine'] as String? ?? '',
    );
  }
}

/// Các trang PDF đã vẽ ra file ảnh. [pageCount] là tổng số trang của file
/// (có thể lớn hơn số ảnh nếu vượt [kMaxScanPages]).
class PdfPages {
  const PdfPages(this.imagePaths, this.pageCount);

  final List<String> imagePaths;
  final int pageCount;

  bool get truncated => pageCount > imagePaths.length;
}

/// Tuỳ chọn nhận chữ. [languages] theo cú pháp Tesseract (`vie+eng`);
/// [pageSegMode] là psm của Tesseract (3 tự động, 6 một khối, 11 chữ thưa),
/// bộ nhận chữ khác được phép bỏ qua.
class OcrOptions {
  const OcrOptions({this.languages = 'vie+eng', this.pageSegMode = 3});

  final String languages;
  final int pageSegMode;
}

/// Mã lỗi chung cho mọi nền tảng (Android gửi đúng các chuỗi này).
abstract final class OcrErrorCode {
  static const cancelled = 'cancelled';
  static const imageUnreadable = 'image_unreadable';
  static const imageTooLarge = 'image_too_large';
  static const pdfUnreadable = 'pdf_unreadable';
  static const pdfProtected = 'pdf_protected';
  static const initFailed = 'init_failed';
  static const invalidArgs = 'invalid_args';
  static const unavailable = 'unavailable';
  static const failed = 'ocr_failed';
}

class OcrException implements Exception {
  const OcrException(this.code, [this.message]);

  /// Một giá trị trong [OcrErrorCode].
  final String code;
  final String? message;

  bool get isCancelled => code == OcrErrorCode.cancelled;

  @override
  String toString() =>
      'OcrException($code${message == null ? '' : ': $message'})';
}

/// Bộ nhận chữ trên máy. Mọi lời gọi chạy tuần tự theo thứ tự gọi; lỗi ném
/// [OcrException]. Không gửi ảnh hay chữ ra khỏi máy.
abstract interface class OcrEngine {
  /// Nhận chữ một file ảnh (JPEG/PNG/WebP; HEIC tuỳ hệ điều hành).
  Future<OcrPage> recognize(
    String imagePath, {
    OcrOptions options = const OcrOptions(),
  });

  /// Vẽ tối đa [maxPages] trang đầu của file PDF ra file ảnh tạm để
  /// [recognize]. File ảnh bị xoá ở lần gọi [renderPdf] sau: muốn giữ làm
  /// ảnh công thức thì chép đi trước.
  Future<PdfPages> renderPdf(String pdfPath, {int maxPages = kMaxScanPages});

  /// Chuẩn bị trước (chép dữ liệu ngôn ngữ, khởi tạo) để trang đầu nhanh hơn;
  /// gọi khi mở màn quét. Không bắt buộc.
  Future<void> warmUp();

  /// Huỷ lời gọi đang chạy và mọi lời gọi đã xếp hàng trước đó (chúng ném
  /// [OcrException] mã [OcrErrorCode.cancelled]).
  Future<void> cancel();

  /// Giải phóng bộ nhớ của bộ nhận chữ (vài chục MB); gọi khi rời màn quét.
  /// Gọi lại [recognize] sau đó vẫn được (tự khởi tạo lại).
  Future<void> dispose();
}
