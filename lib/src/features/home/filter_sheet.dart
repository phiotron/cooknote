import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/category_repository.dart';
import '../../providers.dart';

/// Bảng lọc công thức: danh mục, thẻ, số sao, yêu thích, thời gian, nguyên
/// liệu (AC-13). Kết quả cập nhật ngay khi chọn.
Future<void> showRecipeFilterSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FilterSheet(),
    );

const _timeChoices = [15, 30, 60, 120];

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
    final query = ref.watch(recipeQueryProvider);
    final notifier = ref.read(recipeQueryProvider.notifier);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final tags = ref.watch(tagsProvider).value ?? const [];
    final heading = Theme.of(context).textTheme.titleSmall;
    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: heading)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.filter,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: query.filterCount == 0
                          ? null
                          : () {
                              _ingredient.clear();
                              notifier.set(
                                query.copyWith(
                                  categoryIds: const {},
                                  tags: const {},
                                  minRating: 0,
                                  favoriteOnly: false,
                                  clearMaxTotalMinutes: true,
                                  ingredient: '',
                                ),
                              );
                            },
                      child: Text(l.clearFilters),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.done),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (categories.isNotEmpty)
                      section(
                        l.filterCategories,
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final c in categories)
                              FilterChip(
                                label: Text(categoryPath(categories, c)),
                                selected: query.categoryIds.contains(c.id),
                                onSelected: (on) => notifier.set(
                                  query.copyWith(
                                    categoryIds: {
                                      for (final id in query.categoryIds)
                                        if (id != c.id) id,
                                      if (on) c.id,
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (tags.isNotEmpty)
                      section(
                        l.filterTags,
                        Wrap(
                          spacing: 8,
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
                    section(
                      l.filterMinRating,
                      Row(
                        children: [
                          for (var i = 1; i <= 5; i++)
                            IconButton(
                              tooltip: l.ratingStars(i),
                              icon: Icon(
                                i <= query.minRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber.shade700,
                              ),
                              onPressed: () => notifier.set(
                                query.copyWith(
                                  minRating: query.minRating == i ? 0 : i,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      title: Text(l.filterFavorite),
                      value: query.favoriteOnly,
                      onChanged: (v) =>
                          notifier.set(query.copyWith(favoriteOnly: v)),
                    ),
                    section(
                      l.filterMaxTime,
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(l.anyTime),
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
                    section(
                      l.filterIngredient,
                      TextField(
                        controller: _ingredient,
                        decoration: const InputDecoration(isDense: true),
                        onChanged: (v) =>
                            notifier.set(query.copyWith(ingredient: v)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
