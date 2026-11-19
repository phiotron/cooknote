import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../ui/recipe_photo.dart';

/// Xem ảnh toàn màn hình: vuốt để chuyển ảnh, chụm hai ngón để phóng to (AC-09).
class PhotoViewerScreen extends ConsumerStatefulWidget {
  const PhotoViewerScreen({super.key, required this.id, this.initialIndex = 0});

  final int id;
  final int initialIndex;

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  late final PageController _controller;
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos =
        ref.watch(recipeProvider(widget.id)).value?.draft.photos ?? const [];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: photos.isEmpty
            ? null
            : Text(
                '${(_index + 1).clamp(1, photos.length)}/${photos.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
      body: photos.isEmpty
          ? const SizedBox.shrink()
          : PageView.builder(
              controller: _controller,
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: RecipePhoto(
                    photos[i],
                    fit: BoxFit.contain,
                    cacheWidth: null,
                  ),
                ),
              ),
            ),
    );
  }
}
