import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum BepButtonKind { filled, tonal, outlined, text, danger, dangerText }

/// Cỡ nút: chuẩn 48 dp (AC-60), lớn 56, Chế độ nấu 64 (tapCook).
enum BepButtonSize { standard, big, cook }

/// Nút chuẩn của app (SCR-57): bọc nút Material đã cấu hình trong theme, thêm
/// biến thể nguy hiểm, cỡ lớn/nấu, [block] (rộng hết chiều ngang) và biểu tượng.
class BepButton extends StatelessWidget {
  const BepButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = BepButtonKind.filled,
    this.size = BepButtonSize.standard,
    this.icon,
    this.block = false,
    this.semanticLabel,
  });

  final String label;

  /// null = nút bị khóa.
  final VoidCallback? onPressed;
  final BepButtonKind kind;
  final BepButtonSize size;
  final IconData? icon;
  final bool block;
  final String? semanticLabel;

  double get _height => switch (size) {
    BepButtonSize.standard => BepTap.min,
    BepButtonSize.big => 56,
    BepButtonSize.cook => BepTap.cook,
  };

  double get _fontSize => switch (size) {
    BepButtonSize.standard => 14,
    BepButtonSize.big => 16,
    BepButtonSize.cook => 18,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge!
        .copyWith(fontSize: _fontSize);
    final common = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(block ? double.infinity : 64, _height),
      ),
      textStyle: WidgetStatePropertyAll(textStyle),
    );
    final child = Text(label, textAlign: TextAlign.center);
    final iconWidget = icon == null ? null : Icon(icon, size: 20);

    final danger = kind == BepButtonKind.danger;
    final dangerText = kind == BepButtonKind.dangerText;
    final style = danger
        ? common.merge(
            FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
          )
        : dangerText
        ? common.merge(TextButton.styleFrom(foregroundColor: cs.error))
        : common;
    final Widget button = switch (kind) {
      BepButtonKind.filled || BepButtonKind.danger =>
        iconWidget == null
            ? FilledButton(onPressed: onPressed, style: style, child: child)
            : FilledButton.icon(
                onPressed: onPressed,
                style: style,
                icon: iconWidget,
                label: child,
              ),
      BepButtonKind.tonal =>
        iconWidget == null
            ? FilledButton.tonal(
                onPressed: onPressed,
                style: style,
                child: child,
              )
            : FilledButton.tonalIcon(
                onPressed: onPressed,
                style: style,
                icon: iconWidget,
                label: child,
              ),
      BepButtonKind.outlined =>
        iconWidget == null
            ? OutlinedButton(onPressed: onPressed, style: style, child: child)
            : OutlinedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: iconWidget,
                label: child,
              ),
      BepButtonKind.text || BepButtonKind.dangerText =>
        iconWidget == null
            ? TextButton(onPressed: onPressed, style: style, child: child)
            : TextButton.icon(
                onPressed: onPressed,
                style: style,
                icon: iconWidget,
                label: child,
              ),
    };
    return semanticLabel == null
        ? button
        : Semantics(
            label: semanticLabel,
            button: true,
            excludeSemantics: true,
            enabled: onPressed != null,
            onTap: onPressed,
            child: button,
          );
  }
}
