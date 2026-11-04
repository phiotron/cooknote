import 'dart:async';
import 'dart:io';

import '../data/image_store.dart';
import '../data/recipe_repository.dart' show maxRecipePhotos;

/// Tải một ảnh về file [targetPath]; ném lỗi nếu không tải được. Tách riêng để
/// test không gọi mạng thật (AC-22).
abstract class ImageDownloader {
  Future<void> download(Uri url, String targetPath);
}

/// Bản thật dùng `dart:io`, không thêm gói mạng nào. Chỉ http(s); tối đa
/// [maxBytes]; có thời gian chờ.
class HttpImageDownloader implements ImageDownloader {
  HttpImageDownloader({
    this.timeout = const Duration(seconds: 20),
    this.maxBytes = 15 * 1024 * 1024,
  });

  final Duration timeout;
  final int maxBytes;

  @override
  Future<void> download(Uri url, String targetPath) async {
    if (url.scheme != 'http' && url.scheme != 'https') {
      throw ArgumentError('Chỉ tải http(s)');
    }
    // Android chặn http thường; hầu hết web đã có https.
    final target = url.scheme == 'http' ? url.replace(scheme: 'https') : url;
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(target).timeout(timeout);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Mozilla/5.0 (Linux; Android 13) CookNote',
      );
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}');
      }
      final sink = File(targetPath).openWrite();
      var total = 0;
      try {
        await for (final chunk in response.timeout(timeout)) {
          total += chunk.length;
          if (total > maxBytes) throw const FileSystemException('Ảnh quá lớn');
          sink.add(chunk);
        }
      } finally {
        await sink.close();
      }
    } finally {
      client.close(force: true);
    }
  }
}

/// Cho người dùng bấm "Bỏ qua ảnh" khi đang tải.
class ImageCancel {
  bool cancelled = false;
}

/// Tải ảnh của công thức về máy rồi đưa qua [ImageStore.importImage] (AC-22).
/// Tối đa [max] ảnh (mặc định 20). Mỗi ảnh có thời gian chờ [perImage]; cả đợt
/// không quá [budget]. Ảnh lỗi bị bỏ qua, không làm hỏng việc lưu. Trả về tên
/// file đã lưu trong ImageStore và số ảnh lỗi/bỏ lỡ qua [onProgress].
Future<WebImagesResult> importWebImages({
  required List<String> urls,
  required ImageDownloader downloader,
  required ImageStore store,
  required Directory tempDir,
  int max = maxRecipePhotos,
  Duration perImage = const Duration(seconds: 20),
  Duration budget = const Duration(seconds: 90),
  ImageCancel? cancel,
  void Function(int done, int total)? onProgress,
}) async {
  final unique = <String>[];
  for (final u in urls) {
    if (!unique.contains(u)) unique.add(u);
  }
  final wanted = unique.take(max).toList();
  final names = <String>[];
  var failed = 0;
  final clock = Stopwatch()..start();
  try {
    await tempDir.create(recursive: true);
  } on FileSystemException {
    return WebImagesResult(const [], wanted.length);
  }
  for (var i = 0; i < wanted.length; i++) {
    onProgress?.call(i, wanted.length);
    if ((cancel?.cancelled ?? false) || clock.elapsed >= budget) {
      failed += wanted.length - i;
      break;
    }
    final uri = Uri.tryParse(wanted[i]);
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}web_${DateTime.now().microsecondsSinceEpoch}_$i.tmp',
    );
    try {
      if (uri == null) throw const FormatException();
      await downloader.download(uri, file.path).timeout(perImage);
      names.add(await store.importImage(file.path));
    } catch (_) {
      failed++;
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // File tạm; lần sau dọn.
      }
    }
  }
  onProgress?.call(wanted.length, wanted.length);
  return WebImagesResult(names, failed);
}

class WebImagesResult {
  const WebImagesResult(this.names, this.failed);

  final List<String> names;
  final int failed;
}
