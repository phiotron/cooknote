import 'dart:io';
import 'dart:typed_data';

import 'package:cooknote/src/data/image_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../fixtures.dart';

void main() {
  late Directory temp;
  late ImageStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('cooknote_img_');
    store = ImageStore(Directory('${temp.path}/photos'));
  });

  tearDown(() => temp.deleteSync(recursive: true));

  group('processImage (AC-07)', () {
    test('thu nhỏ cạnh dài nhất về 2048 px, giữ tỉ lệ', () {
      final out = img.decodeJpg(processImage(jpegBytes(4000, 1000)))!;
      expect(out.width, 2048);
      expect(out.height, 512);
    });

    test('ảnh nhỏ hơn 2048 px giữ nguyên kích thước', () {
      final out = img.decodeJpg(processImage(jpegBytes(800, 600)))!;
      expect([out.width, out.height], [800, 600]);
    });

    test('xoay theo EXIF rồi bỏ toàn bộ EXIF, kể cả vị trí GPS', () {
      final input = jpegBytes(3000, 1000, orientation: 6, gpsLatitude: 10.77);
      // Ảnh vào thật sự có GPS, để test không đạt một cách vô nghĩa.
      expect(img.decodeJpg(input)!.exif.gpsIfd.hasGPSLatitude, isTrue);

      final out = img.decodeJpg(processImage(input))!;
      expect([out.width, out.height], [683, 2048]);
      expect(out.exif.gpsIfd.hasGPSLatitude, isFalse);
      expect(out.exif.isEmpty, isTrue);
    });

    test('file không phải ảnh thì báo lỗi rõ ràng', () {
      expect(
        () => processImage(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<ImageImportException>()),
      );
    });
  });

  test(
    'importImage chép vào thư mục riêng; xóa file gốc vẫn còn ảnh (AC-07)',
    () async {
      final source = File('${temp.path}/goc.jpg')
        ..writeAsBytesSync(jpegBytes(100, 80));
      final name = await store.importImage(source.path);
      source.deleteSync();

      final copy = store.file(name);
      expect(copy.existsSync(), isTrue);
      expect(copy.parent.path, store.directory.path);
      expect(name, endsWith('.jpg'));
    },
  );

  test('copy tạo file mới độc lập; delete chỉ xóa đúng file đó', () async {
    final source = File('${temp.path}/goc.jpg')
      ..writeAsBytesSync(jpegBytes(50, 50));
    final a = await store.importImage(source.path);
    final b = await store.copy(a);
    expect(b, isNot(a));

    await store.delete(a);
    expect(store.file(a).existsSync(), isFalse);
    expect(store.file(b).existsSync(), isTrue);
    // Xóa file không còn tồn tại không báo lỗi.
    await store.delete(a);
  });

  test(
    'sweep xóa ảnh không còn được dùng, giữ ảnh đang dùng (AC-07)',
    () async {
      final source = File('${temp.path}/goc.jpg')
        ..writeAsBytesSync(jpegBytes(50, 50));
      final kept = await store.importImage(source.path);
      final orphan = await store.importImage(source.path);
      final other = File('${store.directory.path}/ghi-chu.txt')
        ..writeAsStringSync('không phải ảnh của app');

      final removed = await store.sweep({kept});
      expect(removed, 1);
      expect(store.file(kept).existsSync(), isTrue);
      expect(store.file(orphan).existsSync(), isFalse);
      expect(other.existsSync(), isTrue);
    },
  );

  test('sweep khi thư mục chưa có không báo lỗi', () async {
    expect(await store.sweep({}), 0);
  });
}
