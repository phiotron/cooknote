import 'package:cooknote/src/scan/android_tesseract_engine.dart';
import 'package:cooknote/src/scan/ocr_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Kiểm phần Dart của giao thức kênh (phần Kotlin chỉ thử được trên máy thật).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(AndroidTesseractEngine.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  void handle(Future<Object?> Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) {
      calls.add(call);
      return handler(call);
    });
  }

  tearDown(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('recognize: gửi đúng tham số, đọc dòng + độ tin cậy + hộp', () async {
    handle(
      (call) async => {
        'lines': [
          {
            'text': 'Nguyên liệu',
            'confidence': 0.93,
            'block': 0,
            'box': [0.1, 0.05, 0.6, 0.09],
          },
          {'text': '500 g thịt bò', 'confidence': 1.2, 'block': 1, 'box': null},
        ],
        'width': 3024,
        'height': 4032,
        'elapsedMs': 4210,
        'engine': 'tesseract 5.5.1 (openmp) vie+eng tessdata_fast@87416418',
      },
    );

    final page = await AndroidTesseractEngine().recognize(
      '/data/p1.jpg',
      options: const OcrOptions(pageSegMode: 6),
    );

    expect(calls.single.method, 'recognize');
    expect(calls.single.arguments, {
      'path': '/data/p1.jpg',
      'languages': 'vie+eng',
      'pageSegMode': 6,
    });
    expect(page.lines.map((l) => l.text), ['Nguyên liệu', '500 g thịt bò']);
    expect(page.lines.first.confidence, 0.93);
    expect(page.lines.last.confidence, 1.0); // chặn về 0..1
    expect(page.lines.first.box!.right, 0.6);
    expect(page.lines.last.box, isNull);
    expect(page.lines.last.block, 1);
    expect(page.imageWidth, 3024);
    expect(page.elapsed, const Duration(milliseconds: 4210));
    expect(page.engine, contains('vie+eng'));
  });

  test('renderPdf: chặn maxPages ≤ 10, đọc danh sách trang', () async {
    handle(
      (call) async => {
        'pages': ['/cache/ocr_pdf/page-1.jpg', '/cache/ocr_pdf/page-2.jpg'],
        'pageCount': 2,
      },
    );
    final pdf = await AndroidTesseractEngine().renderPdf(
      '/x.pdf',
      maxPages: 50,
    );
    expect(calls.single.arguments, {'path': '/x.pdf', 'maxPages': 10});
    expect(pdf.imagePaths, hasLength(2));
    expect(pdf.truncated, isFalse);
  });

  test('PlatformException thành OcrException cùng mã', () async {
    handle(
      (call) async =>
          throw PlatformException(code: 'pdf_protected', message: 'pw'),
    );
    await expectLater(
      AndroidTesseractEngine().renderPdf('/x.pdf'),
      throwsA(
        isA<OcrException>().having((e) => e.code, 'code', 'pdf_protected'),
      ),
    );
  });

  test('chưa đăng ký kênh: mã unavailable', () async {
    await expectLater(
      AndroidTesseractEngine().warmUp(),
      throwsA(
        isA<OcrException>().having(
          (e) => e.code,
          'code',
          OcrErrorCode.unavailable,
        ),
      ),
    );
  });

  test('warmUp, cancel, dispose gọi đúng phương thức', () async {
    handle((call) async => null);
    final engine = AndroidTesseractEngine();
    await engine.warmUp();
    await engine.cancel();
    await engine.dispose();
    expect(calls.map((c) => c.method), ['warmUp', 'cancel', 'release']);
  });
}
