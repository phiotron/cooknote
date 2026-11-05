import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'browser_engine.dart';
import 'web_images.dart';
import 'webview_engine.dart';

/// Tạo trình duyệt cho màn nhập từ web; test ghi đè bằng bản giả.
final browserEngineFactoryProvider = Provider<BrowserEngine Function()>(
  (ref) => WebViewEngine.new,
);

/// Bộ tải ảnh; test ghi đè bằng bản giả để không gọi mạng thật.
final imageDownloaderProvider = Provider<ImageDownloader>(
  (ref) => HttpImageDownloader(),
);

/// Nguồn chữ hoặc URL được app khác chia sẻ tới CookNote (AC-17).
abstract class ShareSource {
  /// Chữ chia sẻ đã mở app (khởi động nguội); null nếu không có.
  Future<String?> initialText();

  /// Chữ chia sẻ khi app đang chạy.
  Stream<String> texts();
}

/// Bản thật dùng receive_sharing_intent. Không có plugin (khi test) thì coi
/// như không có gì được chia sẻ.
class PluginShareSource implements ShareSource {
  static String? _textOf(List<SharedMediaFile> files) {
    for (final f in files) {
      if (f.type == SharedMediaType.text || f.type == SharedMediaType.url) {
        final t = f.path.trim();
        if (t.isNotEmpty) return t;
      }
    }
    return null;
  }

  @override
  Future<String?> initialText() async {
    try {
      final files = await ReceiveSharingIntent.instance.getInitialMedia();
      final text = _textOf(files);
      if (text != null) await ReceiveSharingIntent.instance.reset();
      return text;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<String> texts() {
    try {
      return ReceiveSharingIntent.instance
          .getMediaStream()
          .map(_textOf)
          .where((t) => t != null)
          .cast<String>()
          .handleError((Object _) {});
    } catch (_) {
      return const Stream.empty();
    }
  }
}

final shareSourceProvider = Provider<ShareSource>((ref) => PluginShareSource());
