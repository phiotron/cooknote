import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Cạnh dài nhất của ảnh lưu trong app (AC-07).
const maxPhotoSide = 2048;

/// File được chọn không đọc được thành ảnh.
class ImageImportException implements Exception {
  const ImageImportException();
}

/// Xoay ảnh theo EXIF, thu nhỏ để cạnh dài nhất không quá [maxSide], bỏ toàn
/// bộ EXIF (gồm vị trí GPS), rồi lưu dạng JPEG (AC-07).
Uint8List processImage(Uint8List bytes, {int maxSide = maxPhotoSide}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const ImageImportException();
  var image = img.bakeOrientation(decoded);
  if (max(image.width, image.height) > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide)
        : img.copyResize(image, height: maxSide);
  }
  image.exif = img.ExifData();
  return img.encodeJpg(image, quality: 85);
}

final _ownName = RegExp(r'^\d+_[0-9a-f]{8}\.jpg$');

/// Ảnh của công thức nằm trong thư mục riêng của app; cơ sở dữ liệu chỉ giữ
/// tên file (AC-07).
class ImageStore {
  ImageStore(this.directory);

  final Directory directory;
  final _random = Random();

  File file(String name) => File(p.join(directory.path, name));

  String _newName() =>
      '${DateTime.now().microsecondsSinceEpoch}_'
      '${_random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0')}.jpg';

  Future<String> _write(Uint8List bytes) async {
    await directory.create(recursive: true);
    final name = _newName();
    await file(name).writeAsBytes(bytes, flush: true);
    return name;
  }

  /// Chép và xử lý ảnh ở [sourcePath] vào thư mục của app, trả về tên file.
  Future<String> importImage(String sourcePath) async {
    final bytes = await File(sourcePath).readAsBytes();
    final processed = await Isolate.run(() => processImage(bytes));
    return _write(processed);
  }

  /// Bản sao độc lập của ảnh [name], dùng khi nhân bản công thức (AC-06).
  Future<String> copy(String name) async =>
      _write(await file(name).readAsBytes());

  /// Xóa ảnh [name]. Không xóa được (ví dụ file đang bị khóa) thì bỏ qua vì
  /// việc dọn là phụ: lần mở app sau [sweep] sẽ xóa ảnh không còn ai dùng.
  Future<void> delete(String name) async {
    try {
      final f = file(name);
      if (await f.exists()) await f.delete();
    } on FileSystemException {
      // Để [sweep] dọn sau.
    }
  }

  /// Xóa các ảnh do app tạo mà không còn công thức nào dùng; trả về số file
  /// đã xóa. File khác trong thư mục không bị đụng tới.
  Future<int> sweep(Set<String> keep) async {
    if (!await directory.exists()) return 0;
    var removed = 0;
    await for (final entity in directory.list()) {
      final name = p.basename(entity.path);
      if (entity is File && _ownName.hasMatch(name) && !keep.contains(name)) {
        await entity.delete();
        removed++;
      }
    }
    return removed;
  }
}
