import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'photo.dart';

/// Sao đánh giá (chỉ đọc hoặc nhập). Đọc là "4 trên 5 sao"; chưa đánh giá là "Chưa đánh giá".
/// Khi nhập ([onChanged] khác null) mỗi sao là một nút ≥ 48 dp.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.size = 16,
    this.onChanged,
  });

  /// 0..5 (0 = chưa đánh giá).
  final int value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final label = value == 0 ? l.ratingUnset : l.ratingSemantics(value);
    if (onChanged == null) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size,
                color: i <= value ? cs.tertiary : cs.outline,
              ),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: l.ratingSemantics(i),
            isSelected: i <= value,
            onPressed: () => onChanged!(i == value ? 0 : i),
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: i <= value ? cs.tertiary : cs.outline,
            ),
          ),
      ],
    );
  }
}

/// Thẻ công thức dạng lưới (SCR-57): ảnh/ô thay thế 4:3, ruy-băng nếu [bookmarked],
/// tên Lora tối đa 2 dòng, dòng phụ (thời gian · khẩu phần…) bằng [meta].
/// Toàn thẻ là một vùng chạm; [selected] vẽ viền chọn + dấu tích (chọn nhiều, SCR-06).
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.cover,
    required this.title,
    this.meta,
    this.bookmarked = false,
    this.selected,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  /// Ảnh thật hoặc [PhotoPlaceholder] (không cần bọc khung — thẻ tự cắt 4:3).
  final Widget cover;
  final String title;
  final Widget? meta;
  final bool bookmarked;

  /// null = không ở chế độ chọn; true/false = ô chọn.
  final bool? selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: selected ?? false,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BepRadius.circular(14),
          side: BorderSide(
            color: selected == true ? cs.primary : cs.outlineVariant,
            width: selected == true ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cover,
                    if (bookmarked)
                      const Positioned(
                        top: 0,
                        right: 12,
                        child: RibbonBookmark(),
                      ),
                    if (selected != null)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Icon(
                          selected!
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: selected! ? cs.primary : Colors.white,
                          shadows: const [Shadow(blurRadius: 4)],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium!.copyWith(
                        fontFamily: kSerifFamily,
                        fontFamilyFallback: const [kSansFamily],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (meta != null) ...[const SizedBox(height: 4), meta!],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dòng công thức dạng danh sách: ảnh vuông 72 dp + tên + dòng phụ; cao tối thiểu 72 dp
/// và giãn theo chữ. Cùng quy ước chọn nhiều như [RecipeCard].
class RecipeRow extends StatelessWidget {
  const RecipeRow({
    super.key,
    required this.cover,
    required this.title,
    this.meta,
    this.bookmarked = false,
    this.selected,
    this.onTap,
    this.onLongPress,
  });

  final Widget cover;
  final String title;
  final Widget? meta;
  final bool bookmarked;
  final bool? selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: onTap != null,
      selected: selected ?? false,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (selected != null) ...[
                  Icon(
                    selected! ? Icons.check_circle : Icons.circle_outlined,
                    color: selected! ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                ],
                ClipRRect(
                  borderRadius: BepRadius.circular(10),
                  child: SizedBox(width: 72, height: 72, child: cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium!.copyWith(
                          fontFamily: kSerifFamily,
                          fontFamilyFallback: const [kSansFamily],
                        ),
                      ),
                      if (meta != null) ...[const SizedBox(height: 2), meta!],
                    ],
                  ),
                ),
                if (bookmarked)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: RibbonBookmark(size: 26),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
