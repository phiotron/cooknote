import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/recipe_photo.dart';
import '../../ui/ui.dart';

/// Thùng rác: khôi phục hoặc xóa hẳn (AC-05, SCR-13).
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
        title: Text(l.deleteForeverTitle),
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

  Future<void> _emptyTrash(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(recipeRepositoryProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.emptyTrashTitle),
        content: Text(l.emptyTrashBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.emptyTrash),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await repo.emptyTrash();
    showMessage(l.emptyTrashDone);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final trash = ref.watch(trashProvider).value ?? const [];
    final now = ref.watch(clockProvider)();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.trash),
        actions: [
          if (trash.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () => _emptyTrash(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: Text(l.emptyTrash),
              ),
            ),
        ],
      ),
      body: trash.isEmpty
          ? EmptyState(
              illustration: BepIllo.empty,
              title: l.trashEmpty,
              body: l.trashEmptyBody,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.trashInfo,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final r in trash) ...[
                  _TrashRow(
                    name: r.name,
                    coverPhoto: r.coverPhoto,
                    daysLeft: r.deletedAt == null
                        ? trashDays
                        : trashDays - now.difference(r.deletedAt!).inDays,
                    onRestore: () async {
                      await ref.read(recipeRepositoryProvider).restore(r.id);
                      showMessage(l.restored);
                    },
                    onDeleteForever: () => _deleteForever(context, ref, r.id),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ],
              ],
            ),
    );
  }
}

class _TrashRow extends StatelessWidget {
  const _TrashRow({
    required this.name,
    required this.coverPhoto,
    required this.daysLeft,
    required this.onRestore,
    required this.onDeleteForever,
  });

  final String name;
  final String? coverPhoto;
  final int daysLeft;
  final VoidCallback onRestore;
  final VoidCallback onDeleteForever;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bep = context.bep;
    final cs = theme.colorScheme;
    final soon = daysLeft <= 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: BepRadius.circular(BepRadius.sm),
              child: coverPhoto == null
                  ? PhotoPlaceholder(title: name)
                  : RecipePhoto(coverPhoto, cacheWidth: 200),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (soon)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 15,
                          color: bep.warning,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        soon
                            ? l.trashRemovedTomorrow
                            : l.trashRemovedInDays(daysLeft.clamp(0, trashDays)),
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: soon
                              ? bep.warning
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: soon ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Tooltip(
                      message: l.restore,
                      child: TextButton.icon(
                        onPressed: onRestore,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, BepTap.min),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.restore, size: 18),
                        label: Text(l.restore),
                      ),
                    ),
                    Tooltip(
                      message: l.deleteForever,
                      child: TextButton(
                        onPressed: onDeleteForever,
                        style: TextButton.styleFrom(
                          foregroundColor: cs.error,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, BepTap.min),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(l.deleteForever),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
