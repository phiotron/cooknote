import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../backup/backup_settings.dart';
import '../../providers.dart';

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
    final text = switch (notice) {
      BackupNotice.suggestEnable => l.noticeSuggest(count),
      BackupNotice.overdue => l.noticeOverdue,
      BackupNotice.targetError => l.noticeError,
      BackupNotice.none => '',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        color: isError ? scheme.errorContainer : scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Icon(isError ? Icons.warning_amber : Icons.backup_outlined),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
              TextButton(
                onPressed: () => context.push('/backup'),
                child: Text(l.noticeOpen),
              ),
            ],
          ),
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
