import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../cook/cook_providers.dart';
import '../../cook/timer_engine.dart';
import '../../providers.dart';
import '../theme/theme.dart';

/// Viên thuốc hẹn giờ đang chạy (SCR-24): hiện trên mọi màn NGOÀI Chế độ nấu khi có hẹn
/// giờ; một hẹn giờ thì "tên · mm:ss", nhiều thì "N hẹn giờ · mm:ss" (cái gần nhất).
/// Chạm → [onOpen] với công thức của hẹn giờ gần nhất. Không có hẹn giờ thì không chiếm chỗ.
/// Chữ số cùng bề rộng để không nhảy; đọc màn hình: tên + thời gian còn lại + "Mở Chế độ nấu".
class RunningTimerPill extends ConsumerWidget {
  const RunningTimerPill({super.key, required this.onOpen});

  final void Function(int recipeId) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(timersProvider.select((s) => s.running));
    if (running.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final b = context.bep;
    final now = ref.read(clockProvider)();
    final soonest = running.reduce(
      (a, c) => c.endsAt.isBefore(a.endsAt) ? c : a,
    );
    final time = formatRemaining(soonest.remaining(now));
    final many = running.length > 1;
    final label = many
        ? l.timerPillMany(running.length, time)
        : l.timerPillOne(soonest.name, time);
    final spoken = many
        ? l.timerPillManySemantics(running.length, time)
        : l.timerPillSemantics(soonest.name, time);
    return Semantics(
      button: true,
      label: spoken,
      excludeSemantics: true,
      child: Material(
        color: b.timerActive,
        elevation: 3,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onOpen(soonest.recipeId),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: BepTap.min,
              maxWidth: MediaQuery.sizeOf(context).width - 32,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 18, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_rounded, size: 22, color: b.onTimerActive),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge!
                          .copyWith(
                            color: b.onTimerActive,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          )
                          .tabular,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
