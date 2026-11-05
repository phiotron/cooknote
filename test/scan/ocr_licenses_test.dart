import 'dart:io';

import 'package:cooknote/src/scan/ocr_licenses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('file giấy phép OCR có đủ mọi thành phần native (S-70)', () {
    final entries = parseOcrLicenses(File(ocrLicensesAsset).readAsStringSync());
    final packages = entries.expand((e) => e.packages).toSet();
    expect(
      packages,
      containsAll([
        'Tesseract4Android',
        'Tesseract OCR',
        'tessdata_fast',
        'Leptonica',
        'libjpeg',
        'libpng',
        'LLVM OpenMP runtime',
      ]),
    );
    final apache = entries.firstWhere(
      (e) => e.packages.contains('Tesseract OCR'),
    );
    final text = apache.paragraphs.map((p) => p.text).join('\n');
    expect(text, contains('Apache License'));
    final jpeg = entries.firstWhere((e) => e.packages.contains('libjpeg'));
    expect(
      jpeg.paragraphs.map((p) => p.text).join('\n'),
      contains('Independent JPEG Group'),
    );
  });

  test('parseOcrLicenses: nhiều gói một khối, bỏ khối rỗng', () {
    final entries = parseOcrLicenses(
      'bỏ qua\n=== A|B\nnội dung 1\n=== C\n\n=== D\nnội dung 2\n',
    );
    expect(entries.map((e) => e.packages.toList()), [
      ['A', 'B'],
      ['D'],
    ]);
  });
}
