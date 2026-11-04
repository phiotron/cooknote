import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../ui/messenger.dart';
import 'cook_providers.dart';

/// Bọc cả app: khi một hẹn giờ hết lúc app đang mở thì hiện thanh báo ở bất
/// kỳ màn nào (AC-28). Âm báo do thông báo hệ thống hoặc [TimersNotifier].
class TimerAlertHost extends ConsumerWidget {
  const TimerAlertHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(timersProvider.select((s) => s.lastFinished), (prev, next) {
      if (next.isEmpty || identical(prev, next)) return;
      final l = AppLocalizations.of(context);
      final names = next.map((t) => t.name).join(', ');
      rootMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l.timerDone(names)),
            duration: const Duration(seconds: 30),
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.onInverseSurface,
          ),
        );
    });
    return child;
  }
}
