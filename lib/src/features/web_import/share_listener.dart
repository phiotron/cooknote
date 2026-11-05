import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/recipe_repository.dart';
import '../../web_import/browser_input.dart';
import '../../web_import/web_providers.dart';

/// Đường dẫn cần mở cho chữ được chia sẻ (AC-17): có URL thì tới màn nhập web,
/// không thì tới màn soạn với chữ đó. Trả về (đường dẫn, bản nháp hoặc null).
(String, RecipeDraft?) routeForSharedText(String text) {
  final url = firstUrlIn(text);
  if (url != null) return ('/web?url=${Uri.encodeQueryComponent(url)}', null);
  return ('/recipe/new', RecipeDraft(name: '', notes: text.trim()));
}

/// Nhận URL hoặc chữ từ "Chia sẻ" của app khác (AC-17) và mở đúng màn.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<ShareIntentListener> createState() => _ListenerState();
}

class _ListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    final source = ref.read(shareSourceProvider);
    source.initialText().then((t) {
      if (t != null && mounted) _open(t);
    });
    _sub = source.texts().listen(_open, onError: (Object _) {});
  }

  void _open(String text) {
    final (path, draft) = routeForSharedText(text);
    // Chờ khung hình đầu để router đã sẵn sàng khi khởi động nguội.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.router.push(path, extra: draft);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
