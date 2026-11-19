import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/category_repository.dart';
import '../../providers.dart';

/// Bảng lọc công thức: danh mục, thẻ, số sao, yêu thích, thời gian, nguyên
/// liệu (AC-13). Kết quả cập nhật ngay khi chọn; nút cuối hiện số công thức.
Future<void> showRecipeFilterSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _FilterSheet(),
    );

const _timeChoices = [15, 30, 45, 60, 90, 120];

/// Tên danh mục kèm đường dẫn cha, ví dụ "Món chính › Món Việt".
String categoryPath(List<Category> all, Category c) {
  final names = [c.name];
  var parent = c.parentId;
  while (parent != null) {
    final p = all.where((x) => x.id == parent).firstOrNull;
    if (p == null) break;
    names.insert(0, p.name);
    parent = p.parentId;
  }
  return names.join(' › ');
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late final TextEditingController _ingredient;

  @override
  void initState() {
    super.initState();
    _ingredient = TextEditingController(
      text: ref.read(recipeQueryProvider).ingredient,
    );
  }

  @override
  void dispose() {
    _ingredient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final query = ref.watch(recipeQueryProvider);
    final notifier = ref.read(recipeQueryProvider.notifier);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final tags = ref.watch(tagsProvider).value ?? const [];
    final count = ref.watch(recipesProvider).value?.length ?? 0;
    Widget heading(String title, {String? caption}) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: theme.textTheme.titleMedium)),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                caption,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l.filter, style: theme.textTheme.headlineSmall),
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  if (categories.isNotEmpty) ...[
                    heading(
                      l.filterCategories,
                      caption: l.filterIncludesSubs,
                    ),
                    for (final c in categories)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.only(
                          left: 8.0 + (c.depth - 1) * 24,
                          right: 16,
                        ),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: query.categoryIds.contains(c.id),
                        title: Text(c.name),
                        onChanged: (on) => notifier.set(
                          query.copyWith(
                            categoryIds: {
                              for (final id in query.categoryIds)
                                if (id != c.id) id,
                              if (on == true) c.id,
                            },
                          ),
                        ),
                      ),
                  ],
                  if (tags.isNotEmpty) ...[
                    heading(l.filterTags, caption: l.filterTagsAll),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in tags)
                            FilterChip(
                              label: Text(t.tag),
                              selected: query.tags.contains(t.tag),
                              onSelected: (on) => notifier.set(
                                query.copyWith(
                                  tags: {
                                    for (final x in query.tags)
                                      if (x != t.tag) x,
                                    if (on) t.tag,
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  heading(l.filterStars),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l.filterAny),
                          selected: query.minRating == 0,
                          onSelected: (_) =>
                              notifier.set(query.copyWith(minRating: 0)),
                        ),
                        for (var i = 1; i <= 5; i++)
                          ChoiceChip(
                            label: Text('$i★'),
                            selected: query.minRating == i,
                            onSelected: (_) => notifier.set(
                              query.copyWith(minRating: i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(l.filterFavorite),
                    value: query.favoriteOnly,
                    onChanged: (v) =>
                        notifier.set(query.copyWith(favoriteOnly: v)),
                  ),
                  heading(l.filterMaxTime),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l.filterAny),
                          selected: query.maxTotalMinutes == null,
                          onSelected: (_) => notifier.set(
                            query.copyWith(clearMaxTotalMinutes: true),
                          ),
                        ),
                        for (final m in _timeChoices)
                          ChoiceChip(
                            label: Text(l.minutesShort(m)),
                            selected: query.maxTotalMinutes == m,
                            onSelected: (_) => notifier.set(
                              query.copyWith(maxTotalMinutes: m),
                            ),
                          ),
                      ],
                    ),
                  ),
                  heading(l.filterIngredient),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _ingredient,
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (v) =>
                          notifier.set(query.copyWith(ingredient: v)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton(
                    onPressed: query.isFiltering
                        ? () {
                            _ingredient.clear();
                            notifier.set(query.cleared());
                          }
                        : null,
                    child: Text(l.clearFilters),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.showNRecipes(count)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
