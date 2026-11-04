import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';
import '../../ui/recipe_photo.dart';

/// Thùng rác: khôi phục hoặc xóa hẳn (AC-05).
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  Future<void> _deleteForever(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(recipeRepositoryProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.deleteForever),
        content: Text(l.deleteForeverBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.deleteForever),
          ),
        ],
      ),
    );
    if (ok == true) await repo.deleteForever(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final trash = ref.watch(trashProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.trash)),
      body: trash.isEmpty
          ? Center(child: Text(l.trashEmpty))
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.trashInfo),
                ),
                for (final r in trash)
                  ListTile(
                    minTileHeight: 72,
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: RecipePhoto(r.coverPhoto, cacheWidth: 200),
                      ),
                    ),
                    title: Text(r.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l.restore,
                          icon: const Icon(Icons.restore_from_trash),
                          onPressed: () async {
                            await ref
                                .read(recipeRepositoryProvider)
                                .restore(r.id);
                            showMessage(l.restored);
                          },
                        ),
                        IconButton(
                          tooltip: l.deleteForever,
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () => _deleteForever(context, ref, r.id),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
