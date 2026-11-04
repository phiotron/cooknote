import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Hiện ảnh của công thức từ thư mục riêng của app; [fileName] null hoặc file
/// mất thì hiện ô trống có biểu tượng.
class RecipePhoto extends ConsumerWidget {
  const RecipePhoto(
    this.fileName, {
    super.key,
    this.fit = BoxFit.cover,
    this.cacheWidth = 600,
  });

  final String? fileName;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
    final name = fileName;
    if (name == null) return placeholder;
    return Image.file(
      ref.watch(imageStoreProvider).file(name),
      fit: fit,
      cacheWidth: cacheWidth,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}
