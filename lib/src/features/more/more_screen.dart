import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../backup/backup_settings.dart';
import '../../providers.dart';
import '../../ui/format.dart';
import '../../ui/ui.dart';

/// Gốc tab "Thêm" (SCR-46, AC-01/AC-53/AC-63): trạng thái sao lưu, nhập & xuất,
/// danh mục, thùng rác, cài đặt, giới thiệu và lời hứa riêng tư.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final config = ref.watch(backupConfigProvider).value;
    final trashCount = ref.watch(trashProvider).value?.length ?? 0;
    final status = _status(config);
    final body = _backupBody(context, l, config);
    return Scaffold(
      appBar: AppBar(title: Text(l.tabMore)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: InkWell(
              borderRadius: BepRadius.circular(20),
              onTap: () => context.push('/backup'),
              child: BackupStatusCard(
                status: status,
                body: body,
                actions: [
                  TextButton(
                    onPressed: () => context.push('/backup'),
                    child: Text(l.backup),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(l.moreImportExport),
            subtitle: Text(l.moreImportExportSub),
            onTap: () => context.push('/exchange'),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: Text(l.categories),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l.trash),
            trailing: trashCount == 0
                ? const Icon(Icons.chevron_right)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BepTag('$trashCount'),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
            onTap: () => context.push('/trash'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l.settings),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.aboutTitle),
            onTap: () => context.push('/about'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.morePrivacy,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BackupStatus _status(BackupConfig? config) {
    if (config == null || !config.enabled) return BackupStatus.notSetUp;
    if (config.lastError != null) return BackupStatus.failing;
    final last = config.lastSuccess;
    if (last == null) return BackupStatus.overdue;
    final days = DateTime.now().difference(last).inDays;
    return days > backupReminderDays ? BackupStatus.overdue : BackupStatus.safe;
  }

  String _backupBody(
    BuildContext context,
    AppLocalizations l,
    BackupConfig? config,
  ) {
    if (config == null || !config.enabled) return l.moreBackupOff;
    final last = config.lastSuccess;
    if (last == null) return l.backupNever;
    final lang = Localizations.localeOf(context).languageCode;
    return l.backupLastDetail(
      DateFormat.yMMMd(lang).add_Hm().format(last),
      formatBytes(config.lastBytes ?? 0),
    );
  }
}
