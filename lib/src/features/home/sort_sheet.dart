import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_query.dart';
import '../../providers.dart';
import 'recipe_list.dart' show sortLabel;

/// Bảng sắp xếp danh sách công thức (SCR-05): chọn khoá rồi chọn chiều.
Future<void> showRecipeSortSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _SortSheet(),
    );

class _SortSheet extends ConsumerWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final query = ref.watch(recipeQueryProvider);
    final notifier = ref.read(recipeQueryProvider.notifier);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l.sort, style: theme.textTheme.headlineSmall),
            ),
          ),
          Flexible(
            child: RadioGroup<RecipeSort>(
              groupValue: query.sort,
              onChanged: (v) {
                if (v == null) return;
                notifier.set(
                  query.copyWith(sort: v, ascending: v == RecipeSort.name),
                );
              },
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final s in RecipeSort.values)
                    RadioListTile<RecipeSort>(
                      value: s,
                      title: Text(sortLabel(l, s)),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l.sortAscending)),
                ButtonSegment(value: false, label: Text(l.sortDescending)),
              ],
              selected: {query.ascending},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  notifier.set(query.copyWith(ascending: s.first)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.sortMissingLast,
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
}
