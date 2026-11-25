import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../backup/backup_service.dart';
import '../../providers.dart';
import '../../ui/ui.dart';
import '../../web_import/webview_engine.dart' show clearBrowserData;

/// SCR-54 (AC-64): xoá toàn bộ dữ liệu theo ba bước — hỏi sao lưu trước, liệt
/// kê thứ sẽ mất, rồi xác nhận lần cuối. Không đụng tới file sao lưu bên ngoài.
class DeleteAllDataScreen extends ConsumerStatefulWidget {
  const DeleteAllDataScreen({super.key});

  @override
  ConsumerState<DeleteAllDataScreen> createState() =>
      _DeleteAllDataScreenState();
}

class _DeleteAllDataScreenState extends ConsumerState<DeleteAllDataScreen> {
  bool _busy = false;

  Future<void> _start() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);

    // Bước 1: hỏi sao lưu trước.
    final first = await _askBackupFirst(l);
    if (first == null || !mounted) return;
    if (first == _FirstStep.backup) {
      final result = await ref.read(backupServiceProvider).runNow(force: true);
      if (!mounted) return;
      if (result.outcome == BackupOutcome.disabled) {
        await context.push('/backup');
        return;
      }
      if (result.outcome != BackupOutcome.success &&
          result.outcome != BackupOutcome.unchanged) {
        showMessage(l.backupFailedOther);
        return;
      }
    }

    // Bước 2: liệt kê dữ liệu sẽ xoá.
    final cont = await _askWhat(l);
    if (!cont || !mounted) return;

    // Bước 3: xác nhận lần cuối.
    final ok = await showConfirmDialog(
      context,
      title: l.deleteAllFinalTitle,
      body: l.deleteAllFinalBody,
      confirmLabel: l.deleteAllConfirm,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _deleteAll(l);
  }

  Future<_FirstStep?> _askBackupFirst(AppLocalizations l) =>
      showDialog<_FirstStep>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l.deleteAllQuestion),
          content: Text(l.deleteAllQuestionBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialog, _FirstStep.skip),
              child: Text(l.deleteAllSkip),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, _FirstStep.backup),
              child: Text(l.deleteAllBackupNow),
            ),
          ],
        ),
      );

  Future<bool> _askWhat(AppLocalizations l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) {
        final theme = Theme.of(dialog);
        return AlertDialog(
          title: Text(l.deleteAllTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.deleteAllThisDeletes),
                const SizedBox(height: 8),
                for (final item in [
                  l.deleteAllRecipes,
                  l.deleteAllShopping,
                  l.deleteAllSettings,
                  l.deleteAllBrowser,
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  l.deleteAllBackupsSafe,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(l.deleteAllContinue),
            ),
          ],
        );
      },
    );
    return ok ?? false;
  }

  Future<void> _deleteAll(AppLocalizations l) async {
    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      await db.transaction(() async {
        for (final table in db.allTables) {
          await db.delete(table).go();
        }
      });
      await ref.read(imageStoreProvider).sweep(const {});
      try {
        await clearBrowserData();
      } catch (_) {
        // WebView không có trong test hoặc máy không hỗ trợ: bỏ qua.
      }
      if (!mounted) return;
      showBepSnackBar(l.deleteAllDone);
      context.go('/');
    } catch (_) {
      if (!mounted) return;
      showMessage(l.deleteAllFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsDeleteAll)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(l.deleteAllTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(l.deleteAllThisDeletes),
          const SizedBox(height: 8),
          for (final item in [
            l.deleteAllRecipes,
            l.deleteAllShopping,
            l.deleteAllSettings,
            l.deleteAllBrowser,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            l.deleteAllBackupsSafe,
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          BepButton(
            block: true,
            kind: BepButtonKind.danger,
            label: l.settingsDeleteAll,
            icon: Icons.delete_forever,
            onPressed: _busy ? null : _start,
          ),
        ],
      ),
    );
  }
}

enum _FirstStep { skip, backup }
