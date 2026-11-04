import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:saf_util/saf_util.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../backup/backup_format.dart';
import '../../backup/backup_service.dart';
import '../../backup/backup_settings.dart';
import '../../backup/backup_target.dart';
import '../../providers.dart';
import '../../ui/format.dart';
import '../../ui/messenger.dart';

String backupErrorText(AppLocalizations l, BackupException e) =>
    switch (e.problem) {
      BackupProblem.notABackup => l.errBackupNotABackup,
      BackupProblem.newerFormat => l.errBackupNewer,
      BackupProblem.checksumMismatch => l.errBackupChecksum,
      BackupProblem.missingFile => l.errBackupMissing,
      BackupProblem.badData => l.errBackupBad,
    };

/// Câu báo cho một chuỗi lỗi `mã|chi tiết` của [BackupConfig.lastError].
String backupFailureText(AppLocalizations l, String error) =>
    switch (error.split('|').first) {
      BackupErrorKind.target => l.backupFailedTarget,
      BackupErrorKind.verify => l.backupFailedVerify,
      _ => l.backupFailedOther,
    };

/// Sao lưu và khôi phục (F-11, AC-49 tới AC-57).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key, this.initialRestorePath});

  /// Mở sẵn hộp Khôi phục cho file này (từ "Nhập từ file" khi gặp `.cooknote`).
  final String? initialRestorePath;

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  List<BackupFileInfo>? _files;
  bool _filesFailed = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
    final path = widget.initialRestorePath;
    if (path != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restoreFrom(File(path));
      });
    }
  }

  BackupService get _service => ref.read(backupServiceProvider);

  Future<void> _loadFiles() async {
    final config = await ref.read(backupSettingsProvider).read();
    final target = ref.read(backupTargetFactoryProvider)(config);
    if (target == null) {
      if (mounted) setState(() => _files = null);
      return;
    }
    try {
      final list = [
        for (final f in await target.list())
          if (isOwnBackupName(f.name)) f,
      ]..sort((a, b) => b.name.compareTo(a.name));
      if (mounted) {
        setState(() {
          _files = list;
          _filesFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _files = null;
          _filesFailed = true;
        });
      }
    }
  }

  /// Hộp tiến độ có nút Hủy; trả về null nếu người dùng hủy.
  Future<T?> _withProgress<T>(
    String title,
    Future<T> Function(
      void Function(double) onProgress,
      bool Function() cancelled,
    )
    task, {
    bool cancellable = true,
  }) async {
    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final progress = ValueNotifier<double?>(null);
    var cancel = false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title),
          content: ValueListenableBuilder<double?>(
            valueListenable: progress,
            builder: (_, v, _) => LinearProgressIndicator(value: v),
          ),
          actions: [
            if (cancellable)
              TextButton(onPressed: () => cancel = true, child: Text(l.cancel)),
          ],
        ),
      ),
    );
    try {
      return await task((v) => progress.value = v, () => cancel);
    } on BackupCancelled {
      showMessage(l.backupCancelled);
      return null;
    } finally {
      navigator.pop();
      progress.dispose();
    }
  }

  void _reportRun(BackupRunResult r) {
    final l = AppLocalizations.of(context);
    switch (r.outcome) {
      case BackupOutcome.success:
        showMessage(l.backupDone(formatBytes(r.info!.bytes)));
      case BackupOutcome.unchanged:
        showMessage(l.backupUnchanged);
      case BackupOutcome.failed:
        showMessage(backupFailureText(l, r.error ?? ''));
      case BackupOutcome.disabled || BackupOutcome.notDue || BackupOutcome.busy:
        break;
    }
  }

  Future<void> _chooseFolder() async {
    final dir = await SafUtil().pickDirectory(
      writePermission: true,
      persistablePermission: true,
    );
    if (dir == null) return;
    await ref.read(backupSettingsProvider).setTarget(dir.uri, dir.name);
    await _runNow(force: true);
  }

  Future<void> _runNow({bool force = false}) async {
    final l = AppLocalizations.of(context);
    final result = await _withProgress(
      l.backupWorking,
      (onProgress, cancelled) => _service.runNow(
        force: force,
        onProgress: onProgress,
        cancelled: cancelled,
      ),
    );
    if (result != null) _reportRun(result);
    await _loadFiles();
  }

  Future<void> _saveElsewhere() async {
    final l = AppLocalizations.of(context);
    final dirs = ref.read(appDirsProvider);
    await dirs.temp.create(recursive: true);
    final out = File(p.join(dirs.temp.path, backupFileName(DateTime.now())));
    final info = await _withProgress(
      l.backupWorking,
      (onProgress, cancelled) => _service.createFile(
        out,
        onProgress: onProgress,
        cancelled: cancelled,
      ),
    );
    if (info == null) return;
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(out.path)]));
    } finally {
      // File tạm bị xóa sau khi chia sẻ xong (AC-48).
      if (await out.exists()) {
        try {
          await out.delete();
        } on FileSystemException {
          // Lần mở app sau sẽ dọn.
        }
      }
    }
  }

  Future<void> _restoreFromPicker() async {
    final picked = await FilePicker.pickFiles();
    final path = picked.isEmpty ? null : picked.first.path;
    if (path == null || !mounted) return;
    await _restoreFrom(File(path));
  }

  Future<void> _restoreFromTarget(BackupFileInfo info) async {
    final config = await ref.read(backupSettingsProvider).read();
    final target = ref.read(backupTargetFactoryProvider)(config);
    if (target == null || !mounted) return;
    final dirs = ref.read(appDirsProvider);
    final fetchDir = Directory(p.join(dirs.temp.path, 'restore'));
    final l = AppLocalizations.of(context);
    try {
      final file = await target.fetch(info, fetchDir);
      if (!mounted) return;
      await _restoreFrom(file);
    } catch (_) {
      showMessage(l.backupListError);
    } finally {
      if (await fetchDir.exists()) {
        try {
          await fetchDir.delete(recursive: true);
        } on FileSystemException {
          // Không quan trọng.
        }
      }
    }
  }

  Future<void> _restoreFrom(File file) async {
    final l = AppLocalizations.of(context);
    final BackupInfo info;
    try {
      info = await verifyBackupFile(file);
    } on BackupException catch (e) {
      showMessage(backupErrorText(l, e));
      return;
    }
    if (!mounted) return;
    final lang = Localizations.localeOf(context).languageCode;
    final when = DateFormat.yMMMd(lang).add_Hm().format(info.createdAt);
    var mode = RestoreMode.merge;
    final chosen = await showDialog<RestoreMode>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.restoreChooseMode),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.restoreInfo(info.recipes, info.photos, when)),
                const SizedBox(height: 8),
                RadioGroup<RestoreMode>(
                  groupValue: mode,
                  onChanged: (v) => setState(() => mode = v ?? mode),
                  child: Column(
                    children: [
                      RadioListTile<RestoreMode>(
                        contentPadding: EdgeInsets.zero,
                        value: RestoreMode.merge,
                        title: Text(l.restoreMerge),
                        subtitle: Text(l.restoreMergeInfo),
                      ),
                      RadioListTile<RestoreMode>(
                        contentPadding: EdgeInsets.zero,
                        value: RestoreMode.replace,
                        title: Text(l.restoreReplace),
                        subtitle: Text(l.restoreReplaceWarning),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, mode),
              child: Text(l.backupRestoreTitle),
            ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    try {
      final summary = await _withProgress(
        l.restoreWorking,
        (onProgress, _) =>
            _service.restore(file, chosen, onProgress: onProgress),
        cancellable: false,
      );
      if (summary != null) {
        showMessage(
          l.restoreDone(summary.recipesAdded, summary.recipesSkipped),
        );
      }
    } on BackupException catch (e) {
      showMessage(backupErrorText(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final config =
        ref.watch(backupConfigProvider).value ?? const BackupConfig();
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    Widget header(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          t,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
    final last = config.lastSuccess;
    return Scaffold(
      appBar: AppBar(title: Text(l.backup)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.backupLast, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      last == null
                          ? l.backupNever
                          : l.backupLastDetail(
                              DateFormat.yMMMd(lang).add_Hm().format(last),
                              formatBytes(config.lastBytes ?? 0),
                            ),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (config.enabled && config.treeName != null) ...[
                      const SizedBox(height: 4),
                      Text(l.backupFolder(config.treeName!)),
                    ],
                    if (config.enabled && config.lastError != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              backupFailureText(l, config.lastError!),
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          header(l.backupAutoTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!config.enabled) ...[
                  Text(l.backupFolderHint),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _chooseFolder,
                    icon: const Icon(Icons.folder_open),
                    label: Text(l.backupChooseFolder),
                  ),
                ] else ...[
                  Text(l.backupInterval, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<BackupInterval>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: BackupInterval.daily,
                        label: Text(l.intervalDaily),
                      ),
                      ButtonSegment(
                        value: BackupInterval.weekly,
                        label: Text(l.intervalWeekly),
                      ),
                    ],
                    selected: {config.interval},
                    onSelectionChanged: (s) =>
                        ref.read(backupSettingsProvider).setInterval(s.first),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: config.keep,
                    decoration: InputDecoration(labelText: l.backupKeepLabel),
                    items: [
                      for (var i = minBackupKeep; i <= maxBackupKeep; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(l.backupKeepValue(i)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(backupSettingsProvider).setKeep(v);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _runNow(force: true),
                    icon: const Icon(Icons.backup),
                    label: Text(l.backupRunNow),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: _chooseFolder,
                        child: Text(l.backupChangeFolder),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref.read(backupSettingsProvider).clearTarget();
                          await _loadFiles();
                        },
                        child: Text(l.backupDisable),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          header(l.backupSaveElsewhere),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.backupSaveElsewhereHint),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saveElsewhere,
                  icon: const Icon(Icons.ios_share),
                  label: Text(l.backupSaveElsewhere),
                ),
              ],
            ),
          ),
          header(l.backupRestoreTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _restoreFromPicker,
                icon: const Icon(Icons.restore),
                label: Text(l.backupRestoreFile),
              ),
            ),
          ),
          if (config.enabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l.backupRestoreFromFolder,
                style: theme.textTheme.labelLarge,
              ),
            ),
            if (_filesFailed)
              ListTile(title: Text(l.backupListError))
            else if (_files != null && _files!.isEmpty)
              ListTile(title: Text(l.backupNoFiles))
            else
              for (final f in _files ?? const <BackupFileInfo>[])
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(
                    DateFormat.yMMMd(lang).add_Hm().format(f.modified),
                  ),
                  subtitle: Text('${f.name} · ${formatBytes(f.size)}'),
                  onTap: () => _restoreFromTarget(f),
                ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_open, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l.backupUnencrypted)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l.backupSystemLayer, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
