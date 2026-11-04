import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../ui/recipe_photo.dart';

/// Xem ảnh toàn màn hình: vuốt để chuyển ảnh, chụm hai ngón để phóng to (AC-09).
class PhotoViewerScreen extends ConsumerWidget {
  const PhotoViewerScreen({super.key, required this.id, this.initialIndex = 0});

  final int id;
  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos =
        ref.watch(recipeProvider(id)).value?.draft.photos ?? const [];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: photos.isEmpty
          ? const SizedBox.shrink()
          : PageView.builder(
              controller: PageController(
                initialPage: initialIndex.clamp(0, photos.length - 1),
              ),
              itemCount: photos.length,
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
