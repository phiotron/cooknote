import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum BepTone { ok, warn, bad, info, neutral, suggested }

/// Thẻ trạng thái nhỏ: biểu tượng + chữ + màu (trạng thái không bao giờ chỉ bằng màu — S-50).
/// Dùng cho hạn dùng (sắp hết/quá hạn), "Gợi ý", "Không mã hóa", v.v.
class BepTag extends StatelessWidget {
  const BepTag(this.label, {super.key, this.tone = BepTone.neutral, this.icon});

  final String label;
  final BepTone tone;

  /// null = biểu tượng mặc định theo [tone]; truyền [BepTag.noIcon] không có.
  final IconData? icon;

  static IconData _defaultIcon(BepTone t) => switch (t) {
    BepTone.ok => Icons.check_circle_outline,
    BepTone.warn => Icons.warning_amber_rounded,
    BepTone.bad => Icons.error_outline,
    BepTone.info => Icons.info_outline,
    BepTone.neutral => Icons.label_outline,
    BepTone.suggested => Icons.lightbulb_outline,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final b = context.bep;
    final (bg, fg, edge) = switch (tone) {
      BepTone.ok => (b.successContainer, b.onSuccessContainer, null),
      BepTone.warn => (b.warningContainer, b.onWarningContainer, null),
      BepTone.bad => (cs.errorContainer, cs.onErrorContainer, null),
      BepTone.info => (b.infoContainer, b.onInfoContainer, null),
      BepTone.neutral => (cs.surfaceContainerHigh, cs.onSurfaceVariant, null),
      BepTone.suggested => (b.suggestedContainer, b.suggested, b.suggested),
    };
    final scale = MediaQuery.textScalerOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BepRadius.circular(6),
        border: edge == null ? null : Border.all(color: edge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? _defaultIcon(tone), size: scale.scale(14), color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium!
                  .copyWith(color: fg, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
