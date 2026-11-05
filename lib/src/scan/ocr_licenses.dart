import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Giấy phép của phần nhận chữ native (S-70): Tesseract4Android, Tesseract,
/// tessdata_fast, Leptonica, libjpeg, libpng, LLVM OpenMP. Các gói Dart đã tự
/// có trong `showLicensePage`; thư viện Gradle/native thì không, nên phải
/// đăng ký tay. Gọi một lần trong `main()` trước `runApp`.
void registerOcrLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(ocrLicensesAsset);
    yield* Stream.fromIterable(parseOcrLicenses(text));
  });
}

const ocrLicensesAsset = 'assets/tessdata/LICENSES-ocr.txt';

/// Tách file giấy phép: mỗi khối mở đầu bằng dòng `=== tên gói|tên gói 2`.
List<LicenseEntry> parseOcrLicenses(String text) {
  final out = <LicenseEntry>[];
  List<String>? packages;
  final body = StringBuffer();

  void flush() {
    final p = packages;
    if (p != null && body.toString().trim().isNotEmpty) {
      out.add(LicenseEntryWithLineBreaks(p, body.toString().trim()));
    }
    body.clear();
  }

  for (final line in text.replaceAll('\r\n', '\n').split('\n')) {
    if (line.startsWith('=== ')) {
      flush();
      packages = line
          .substring(4)
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (packages != null) {
      body.writeln(line);
    }
  }
  flush();
  return out;
}
