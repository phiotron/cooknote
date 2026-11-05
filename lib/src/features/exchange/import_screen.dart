import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../exchange/exchange_providers.dart';
import '../../exchange/imported_recipe.dart';
import '../../exchange/import_service.dart';
import '../../ui/messenger.dart';
import 'exchange_actions.dart';

/// Nhập từ file (F-10, AC-44, AC-45): tự nhận định dạng, báo kết quả.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportOutcome? _outcome;

  Future<void> _choose() async {
    final l = AppLocalizations.of(context);
    final service = ref.read(importServiceProvider);
    final path = await ref.read(importFilePickerProvider).pick();
    if (path == null || !mounted) return;
    final file = File(path);
    try {
      final kind = await service.detect(file);
      if (!mounted) return;
      if (kind == ImportKind.cooknote) {
        // File sao lưu: dùng màn Khôi phục có sẵn (kiểm mã băm, gộp/thay thế).
        context.push('/backup', extra: path);
        return;
      }
      if (kind == ImportKind.unknown) {
        showMessage(l.importUnknown);
        return;
      }
      final outcome = await runWithProgress<ImportOutcome>(
        context,
        l.importWorking,
        (onProgress, cancelled) =>
            service.importFile(file, onProgress: onProgress, cancelled: cancelled),
      );
      if (outcome == null || !mounted) return;
      setState(() => _outcome = outcome);
      if (outcome.cancelled) showMessage(l.importCancelled);
    } on ImportFormatException {
      showMessage(l.importBadFile);
    } on Object {
      showMessage(l.importBadFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final o = _outcome;
    return Scaffold(
      appBar: AppBar(title: Text(l.importTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.importIntro),
          const SizedBox(height: 12),
          Text(l.importUnverified, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _choose,
              icon: const Icon(Icons.file_open_outlined),
              label: Text(l.importChoose),
            ),
          ),
          if (o != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.importResult(o.imported, o.duplicates, o.skipped),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            if (o.reasons.isNotEmpty) ...[
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(l.importDetails, style: theme.textTheme.titleSmall),
              ),
              for (final r in o.reasons)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('• $r'),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
