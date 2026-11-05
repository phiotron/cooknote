import 'package:cooknote/src/scan/fake_ocr_engine.dart';
import 'package:cooknote/src/scan/line_classifier.dart';
import 'package:cooknote/src/scan/ocr_engine.dart';
import 'package:cooknote/src/scan/scan_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';

// Chữ mô phỏng đầu ra OCR, tự viết, không chép từ sách thật.
const _page1 = '''
CANH CHUA CÁ
Nguyên liệu:
500 g cá lóc

l quả cà chua''';
const _page2 = '''
2 nhánh me
Cách làm:
1. Nấu me lấy nước chua.
2. Cho cá vào nấu chín.''';

void main() {
  group('scanImages', () {
    test(
      'ghép hai trang, giữ số trang, bỏ dòng trống, gợi ý vai trò',
      () async {
        final engine = FakeOcrEngine.fromText({
          'p1.jpg': _page1,
          'p2.jpg': _page2,
        });
        final progress = <(int, int)>[];

        final result = await scanImages(engine, [
          'p1.jpg',
          'p2.jpg',
        ], onProgress: (done, total) => progress.add((done, total)));

        expect(engine.recognized, ['p1.jpg', 'p2.jpg']);
        expect(progress, [(0, 2), (1, 2), (2, 2)]);
        expect(result.pages, hasLength(2));
        expect(result.lines.map((l) => l.page), [0, 0, 0, 0, 1, 1, 1, 1]);
        expect(result.lines.map((l) => l.suggestion.role), [
          LineRole.title,
          LineRole.heading,
          LineRole.ingredient,
          LineRole.ingredient,
          // Trang 2 tiếp nhóm "Nguyên liệu" của trang 1.
          LineRole.ingredient,
          LineRole.heading,
          LineRole.step,
          LineRole.step,
        ]);
        // Bộ phân loại sửa "l quả" thành "1 quả".
        expect(result.lines[3].suggestion.text, '1 quả cà chua');
        expect(result.lines[3].ocr.text, 'l quả cà chua');
        expect(result.plainText, contains('CANH CHUA CÁ'));
        expect(
          result.plainText,
          '${result.pages[0].text}\n\n${result.pages[1].text}',
        );
      },
    );

    test('dòng tin cậy thấp bị đánh dấu nghi ngờ', () async {
      final engine = FakeOcrEngine(
        pages: {
          'a.jpg': const OcrPage(
            lines: [
              OcrLine('Nguyên liệu', 0.95),
              OcrLine('200 g bột mì', 0.92),
              OcrLine('2 qu& tr~ng', 0.31),
            ],
          ),
        },
      );
      final result = await scanImages(engine, ['a.jpg']);
      expect(result.lines.map((l) => l.isDoubtful), [false, false, true]);
      expect(result.lines.last.ocrConfidence, 0.31);
    });

    test('quá 10 ảnh hoặc không có ảnh: ArgumentError', () async {
      final engine = FakeOcrEngine();
      expect(
        () => scanImages(engine, List.generate(11, (i) => '$i.jpg')),
        throwsArgumentError,
      );
      expect(() => scanImages(engine, const []), throwsArgumentError);
      expect(engine.recognized, isEmpty);
    });

    test('10 ảnh: được', () async {
      final paths = List.generate(kMaxScanPages, (i) => '$i.jpg');
      final engine = FakeOcrEngine.fromText({for (final p in paths) p: 'x $p'});
      final result = await scanImages(engine, paths);
      expect(result.pages, hasLength(kMaxScanPages));
    });

    test('lỗi một trang: ném OcrException với mã', () async {
      final engine = FakeOcrEngine.fromText({'a.jpg': 'A', 'b.jpg': 'B'})
        ..errors['b.jpg'] = OcrErrorCode.imageUnreadable;
      await expectLater(
        scanImages(engine, ['a.jpg', 'b.jpg']),
        throwsA(
          isA<OcrException>().having(
            (e) => e.code,
            'code',
            OcrErrorCode.imageUnreadable,
          ),
        ),
      );
    });

    test('huỷ giữa chừng: ném OcrException cancelled', () async {
      final engine = FakeOcrEngine.fromText({
        'a.jpg': 'A',
        'b.jpg': 'B',
      }, delay: const Duration(milliseconds: 20));
      final future = scanImages(engine, ['a.jpg', 'b.jpg']);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await engine.cancel();
      await expectLater(
        future,
        throwsA(
          isA<OcrException>().having((e) => e.isCancelled, 'cancel', true),
        ),
      );
      expect(engine.cancels, 1);
    });

    test('trang không có chữ nào: kết quả rỗng, không lỗi', () async {
      final engine = FakeOcrEngine(
        pages: {'blank.jpg': const OcrPage(lines: [])},
      );
      final result = await scanImages(engine, ['blank.jpg']);
      expect(result.lines, isEmpty);
      expect(result.plainText, '');
    });
  });

  group('scanPdf', () {
    test('vẽ trang PDF rồi quét; báo file dài hơn 10 trang', () async {
      final paths = List.generate(kMaxScanPages, (i) => 'cache/page-$i.jpg');
      final engine = FakeOcrEngine.fromText({
        for (final p in paths) p: 'Trang $p',
      })..pdfs['book.pdf'] = PdfPages(paths, 14);

      final (pdf, result) = await scanPdf(engine, 'book.pdf');
      expect(pdf.truncated, isTrue);
      expect(pdf.pageCount, 14);
      expect(result.imagePaths, paths);
      expect(result.pages, hasLength(kMaxScanPages));
    });

    test('PDF có mật khẩu: mã pdf_protected', () async {
      final engine = FakeOcrEngine()
        ..errors['x.pdf'] = OcrErrorCode.pdfProtected;
      await expectLater(
        scanPdf(engine, 'x.pdf'),
        throwsA(
          isA<OcrException>().having(
            (e) => e.code,
            'code',
            OcrErrorCode.pdfProtected,
          ),
        ),
      );
    });

    test('PDF không có trang: pdf_unreadable', () async {
      final engine = FakeOcrEngine()..pdfs['e.pdf'] = const PdfPages([], 0);
      await expectLater(
        scanPdf(engine, 'e.pdf'),
        throwsA(
          isA<OcrException>().having(
            (e) => e.code,
            'code',
            OcrErrorCode.pdfUnreadable,
          ),
        ),
      );
    });
  });
}
