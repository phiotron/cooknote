import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../backup/backup_settings.dart';
import '../../providers.dart';
import '../../ui/theme/theme.dart';

/// Nhắc sao lưu ngay trên màn Công thức (AC-51, AC-53): lỗi nơi lưu, quá 7
/// ngày chưa sao lưu, hoặc gợi ý bật khi đã có từ 10 công thức.
class BackupNoticeBanner extends ConsumerWidget {
  const BackupNoticeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(backupNoticeProvider);
    if (notice == BackupNotice.none) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final count = ref.watch(recipeCountProvider).value ?? 0;
    final isError = notice == BackupNotice.targetError;
    final scheme = Theme.of(context).colorScheme;
    final bep = context.bep;
    final text = switch (notice) {
      BackupNotice.suggestEnable => l.noticeSuggest(count),
      BackupNotice.overdue => l.noticeOverdue,
      BackupNotice.targetError => l.noticeError,
      BackupNotice.none => '',
    };
    final bg = isError ? scheme.errorContainer : bep.infoContainer;
    final fg = isError ? scheme.onErrorContainer : bep.onInfoContainer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BepRadius.circular(BepRadius.md),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.shield_outlined,
              color: fg,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: fg),
                  ),
                  TextButton(
                    onPressed: () => context.push('/backup'),
                    style: TextButton.styleFrom(
                      foregroundColor: fg,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: Theme.of(context).textTheme.labelLarge!
                          .copyWith(
                            decoration: TextDecoration.underline,
                            color: fg,
                          ),
                    ),
                    child: Text(l.noticeOpen),
                  ),
                ],
              ),
            ),
            if (notice == BackupNotice.suggestEnable)
              IconButton(
                tooltip: l.cancel,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close, size: 20, color: fg),
                onPressed: () =>
                    ref.read(backupSettingsProvider).dismissSuggestion(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tự sao lưu khi app vào nền (AC-50). Việc mở app do `startupProvider` lo.
class BackupLifecycleObserver extends ConsumerStatefulWidget {
  const BackupLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BackupLifecycleObserver> createState() => _ObserverState();
}

class _ObserverState extends ConsumerState<BackupLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // runIfDue không ném lỗi; kết quả nằm trong cài đặt sao lưu.
      ref.read(backupServiceProvider).runIfDue();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
