import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../exchange/exchange_actions.dart';

/// SCR-52 (AC-44, AC-45, AC-48): nhập từ file (Paprika, Recipe Keeper, JSON,
/// `.cooknote`) và xuất toàn bộ công thức ra JSON hoặc sách PDF.
class ExchangeHubScreen extends ConsumerWidget {
  const ExchangeHubScreen({super.key});

  Future<void> _exportAll(
    BuildContext context,
    WidgetRef ref, {
    required bool pdf,
  }) async {
    final ids = await allRecipeIds(ref);
    if (!context.mounted) return;
    if (pdf) {
      await makeCookbook(context, ref, ids);
    } else {
      await exportRecipesJson(context, ref, ids);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.exchangeTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: Text(l.exchangeImport),
            subtitle: Text(l.exchangeImportSub),
            onTap: () => context.push('/import'),
          ),
          const Divider(height: 8),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(l.exchangeExportAll),
            onTap: () => _exportAll(context, ref, pdf: false),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l.exchangeCookbook),
            subtitle: Text(l.exchangePdf),
            onTap: () => _exportAll(context, ref, pdf: true),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              l.exchangeExportHint,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
