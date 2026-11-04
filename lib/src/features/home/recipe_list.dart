import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_query.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/recipe_photo.dart';
import 'filter_sheet.dart';

String sortLabel(AppLocalizations l, RecipeSort s) => switch (s) {
  RecipeSort.name => l.sortName,
  RecipeSort.created => l.sortCreated,
  RecipeSort.updated => l.sortUpdated,
  RecipeSort.rating => l.sortRating,
  RecipeSort.cookTime => l.sortCookTime,
  RecipeSort.lastCooked => l.sortLastCooked,
};

/// Mục "Công thức": ô tìm, lọc, sắp xếp, xem lưới hoặc dòng (F-02).
class RecipeListTab extends ConsumerStatefulWidget {
  const RecipeListTab({super.key});

  @override
  ConsumerState<RecipeListTab> createState() => _RecipeListTabState();
}

class _RecipeListTabState extends ConsumerState<RecipeListTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setText(String text) {
    final q = ref.read(recipeQueryProvider);
    ref.read(recipeQueryProvider.notifier).set(q.copyWith(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final query = ref.watch(recipeQueryProvider);
    final recipes = ref.watch(recipesProvider).value;
    final grid = ref.watch(viewModeProvider).value == 'grid';

    // "Xóa bộ lọc" ở nơi khác cũng phải xóa chữ trong ô tìm.
    ref.listen(recipeQueryProvider, (previous, next) {
      if (_search.text != next.text) _search.text = next.text;
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _search,
            onChanged: _setText,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l.clearSearch,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        _setText('');
                      },
                    ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => showRecipeFilterSheet(context),
                icon: const Icon(Icons.filter_list),
                label: Text(
                  query.filterCount == 0
                      ? l.filter
                      : l.filterWithCount(query.filterCount),
                ),
              ),
              PopupMenuButton<Object>(
                tooltip: l.sort,
                icon: const Icon(Icons.sort),
                onSelected: (v) {
                  final n = ref.read(recipeQueryProvider.notifier);
                  if (v is RecipeSort) {
                    // Tên xếp A→Z, còn lại mới/cao/lâu nhất trước.
                    n.set(
                      query.copyWith(sort: v, ascending: v == RecipeSort.name),
                    );
                  } else {
                    n.set(query.copyWith(ascending: !query.ascending));
                  }
                },
                itemBuilder: (_) => [
                  for (final s in RecipeSort.values)
                    CheckedPopupMenuItem<Object>(
                      value: s,
                      checked: s == query.sort,
                      child: Text(sortLabel(l, s)),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem<Object>(
                    value: 'direction',
                    child: Text(
                      query.ascending ? l.sortDescending : l.sortAscending,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: query.isFiltering && recipes != null
                    ? Text(
                        l.resultCount(recipes.length),
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : const SizedBox.shrink(),
              ),
              IconButton(
                tooltip: grid ? l.viewList : l.viewGrid,
                icon: Icon(grid ? Icons.view_list : Icons.grid_view),
                onPressed: () => ref
                    .read(settingsRepositoryProvider)
                    .setViewMode(grid ? 'list' : 'grid'),
              ),
            ],
          ),
        ),
        Expanded(
          child: recipes == null
              ? const Center(child: CircularProgressIndicator())
              : recipes.isEmpty
              ? _Empty(filtering: query.isFiltering)
              : grid
              ? _RecipeGrid(recipes: recipes)
              : _RecipeRows(recipes: recipes),
        ),
      ],
    );
  }
}

class _Empty extends ConsumerWidget {
  const _Empty({required this.filtering});

  final bool filtering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtering ? Icons.search_off : Icons.menu_book_outlined,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              filtering ? l.noMatch : l.noRecipes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (filtering)
              TextButton(
                onPressed: () => ref
                    .read(recipeQueryProvider.notifier)
                    .set(ref.read(recipeQueryProvider).cleared()),
                child: Text(l.clearFilters),
              )
            else
              Text(l.noRecipesHint, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RecipeRows extends StatelessWidget {
  const _RecipeRows({required this.recipes});

  final List<RecipeSummary> recipes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: recipes.length,
      itemBuilder: (context, i) {
        final r = recipes[i];
        return ListTile(
          minTileHeight: 72,
          leading: SizedBox(
            width: 56,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: RecipePhoto(r.coverPhoto, cacheWidth: 200),
            ),
          ),
          title: Text(r.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: r.totalMinutes == null
              ? null
              : Text(l.minutesShort(r.totalMinutes!)),
          trailing: r.favorite
              ? const Icon(Icons.favorite, color: Colors.redAccent)
              : null,
          onTap: () => context.push('/recipe/${r.id}'),
        );
      },
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({required this.recipes});

  final List<RecipeSummary> recipes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, i) {
        final r = recipes[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/recipe/${r.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RecipePhoto(r.coverPhoto, cacheWidth: 400),
                        if (r.favorite)
                          const Positioned(
                            right: 8,
                            top: 8,
                            child: Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Text(
                    r.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    r.totalMinutes == null
                        ? ' '
                        : l.minutesShort(r.totalMinutes!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
