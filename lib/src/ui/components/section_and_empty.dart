import 'package:flutter/material.dart';

import '../illustrations.dart';
import '../theme/theme.dart';

/// Tiêu đề nhóm kiểu tab sổ tay (SCR-57): nhãn Lora trên nền tab, kẻ ngang dưới,
/// số đếm bên phải. Là tiêu đề (heading) cho trình đọc màn hình.
class NotebookTabHeader extends StatelessWidget {
  const NotebookTabHeader(this.title, {super.key, this.count, this.trailing});

  final String title;

  /// Số đếm hiện bên phải (có thể null).
  final String? count;

  /// Thay cho [count] khi cần nút (vd "Xem hết").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Semantics(
      header: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outline, width: 1.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                heightFactor: 1,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 5, 12, 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(9),
                    ),
                    border: Border(
                      left: BorderSide(color: cs.outlineVariant),
                      top: BorderSide(color: cs.outlineVariant),
                      right: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                  child: Text(
                    title,
                    style: text.titleMedium!.copyWith(
                      fontFamily: kSerifFamily,
                      fontFamilyFallback: const [kSansFamily],
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (count != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  count!,
                  style: text.labelMedium!
                      .copyWith(color: cs.onSurfaceVariant)
                      .tabular,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Trạng thái rỗng (SCR-57): minh hoạ + tiêu đề (Lora) + giải thích + hành động.
/// Cuộn được để không vỡ ở chữ 200% hoặc màn thấp.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    this.body,
    this.actions = const [],
  });

  final BepIllo illustration;
  final String title;
  final String? body;

  /// Thường là một [BepButton]; hành động chính trước.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: box.hasBoundedHeight ? box.maxHeight - 32 : 0,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BepIllustration(illustration),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    body!,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                for (final a in actions) ...[const SizedBox(height: 16), a],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
