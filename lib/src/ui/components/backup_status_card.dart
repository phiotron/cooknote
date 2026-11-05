import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Trạng thái sao lưu (SCR-47/51): chỉ "An toàn" khi bản gần nhất đã được kiểm lại.
enum BackupStatus { safe, overdue, failing, notSetUp }

/// Thẻ trạng thái sao lưu: vòng tròn biểu tượng + TỪ ("An toàn", "Quá hạn", "Đang lỗi",
/// "Chưa bật") + giải thích + hành động. Màu đi cùng biểu tượng và chữ (không chỉ màu).
class BackupStatusCard extends StatelessWidget {
  const BackupStatusCard({
    super.key,
    required this.status,
    this.body,
    this.actions = const [],
  });

  final BackupStatus status;

  /// Giải thích ngắn (lần sao lưu gần nhất, lý do lỗi…).
  final String? body;
  final List<Widget> actions;

  static String wordOf(AppLocalizations l, BackupStatus s) => switch (s) {
    BackupStatus.safe => l.backupStatusSafe,
    BackupStatus.overdue => l.backupStatusOverdue,
    BackupStatus.failing => l.backupStatusFailing,
    BackupStatus.notSetUp => l.backupStatusNotSetUp,
  };

  static IconData iconOf(BackupStatus s) => switch (s) {
    BackupStatus.safe => Icons.verified_user_rounded,
    BackupStatus.overdue => Icons.schedule_rounded,
    BackupStatus.failing => Icons.gpp_maybe_rounded,
    BackupStatus.notSetUp => Icons.cloud_off_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final b = context.bep;
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final (bg, fg, icBg, icFg) = switch (status) {
      BackupStatus.safe => (
        b.successContainer,
        b.onSuccessContainer,
        b.success,
        b.onSuccess,
      ),
      BackupStatus.overdue => (
        b.warningContainer,
        b.onWarningContainer,
        b.warning,
        b.onWarning,
      ),
      BackupStatus.failing => (
        cs.errorContainer,
        cs.onErrorContainer,
        cs.error,
        cs.onError,
      ),
      BackupStatus.notSetUp => (
        cs.surfaceContainerHigh,
        cs.onSurface,
        cs.outline,
        cs.surface,
      ),
    };
    final word = wordOf(l, status);
    return Semantics(
      container: true,
      label: body == null ? word : '$word. $body',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BepRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: icBg, shape: BoxShape.circle),
                child: Icon(iconOf(status), color: icFg),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      word,
                      style: text.titleMedium!.copyWith(color: fg),
                    ),
                  ),
                  if (body != null) ...[
                    const SizedBox(height: 4),
                    ExcludeSemantics(
                      child: Text(
                        body!,
                        style: text.bodyMedium!.copyWith(color: fg),
                      ),
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 4, children: actions),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
