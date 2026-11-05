import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../exchange/exchange_actions.dart';

/// Gốc tab "Thêm" (SCR-46). F0: danh sách cũ chuyển nguyên từ HomeScreen cho vẫn dùng được;
/// G6 làm lại theo mockup (giữ tên lớp [MoreScreen] và route `/more`).
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.tabMore)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: Text(l.importFile),
            onTap: () => context.push('/import'),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(l.exportAllJson),
            onTap: () async {
              final ids = await allRecipeIds(ref);
              if (!context.mounted) return;
              exportRecipesJson(context, ref, ids);
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l.cookbookAll),
            onTap: () async {
              final ids = await allRecipeIds(ref);
              if (!context.mounted) return;
              makeCookbook(context, ref, ids);
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l.backup),
            onTap: () => context.push('/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(l.categories),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l.trash),
            onTap: () => context.push('/trash'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l.settings),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
