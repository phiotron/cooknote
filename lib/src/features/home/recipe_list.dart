import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_query.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/recipe_photo.dart';
import '../../ui/ui.dart';
import '../backup/backup_notice.dart';
import 'filter_sheet.dart';
import 'recipe_format.dart';
import 'sort_sheet.dart';

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
  const RecipeListTab({
    super.key,
    this.selected,
    this.onToggle,
    this.onLongPress,
  });

  /// null = không ở chế độ chọn; ngược lại là các id đang chọn.
  final Set<int>? selected;
  final void Function(int id)? onToggle;
  final void Function(int id)? onLongPress;

  @override
  ConsumerState<RecipeListTab> createState() => _RecipeListTabState();
}

class _RecipeListTabState extends ConsumerState<RecipeListTab> {
  final _search = TextEditingController();

  bool get _selecting => widget.selected != null;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setText(String text) {
    final q = ref.read(recipeQueryProvider);
    ref.read(recipeQueryProvider.notifier).set(q.copyWith(text: text));
  }

  void _open(int id) {
    if (_selecting) {
      widget.onToggle?.call(id);
    } else {
      context.push('/recipe/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final query = ref.watch(recipeQueryProvider);
    final recipes = ref.watch(recipesProvider).value;
    final grid = ref.watch(viewModeProvider).value == 'grid';
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final empty = recipes != null && recipes.isEmpty && !query.isFiltering;

    // "Xóa bộ lọc" ở nơi khác cũng phải xóa chữ trong ô tìm.
    ref.listen(recipeQueryProvider, (previous, next) {
      if (_search.text != next.text) _search.text = next.text;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_selecting)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l.tabRecipes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: grid ? l.viewList : l.viewGrid,
                  icon: Icon(grid ? Icons.view_list : Icons.grid_view),
                  onPressed: () => ref
                      .read(settingsRepositoryProvider)
                      .setViewMode(grid ? 'list' : 'grid'),
                ),
                PopupMenuButton<String>(
                  tooltip: l.moreActions,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'select') widget.onLongPress?.call(-1);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'select',
                      child: Text(l.selectRecipes),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (!empty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: _setText,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
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
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PillButton(
                  icon: Icons.tune,
                  label: query.filterCount == 0
                      ? l.filter
                      : l.filterWithCount(query.filterCount),
                  onPressed: () => showRecipeFilterSheet(context),
                ),
                _PillButton(
                  icon: Icons.swap_vert,
                  label: sortLabel(l, query.sort),
                  trailing: Icons.keyboard_arrow_down,
                  onPressed: () => showRecipeSortSheet(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    recipes == null ? '' : l.resultCount(recipes.length),
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (query.isFiltering && (recipes?.isNotEmpty ?? false))
                  TextButton(
                    onPressed: () {
                      _search.clear();
                      ref
                          .read(recipeQueryProvider.notifier)
                          .set(query.cleared());
                    },
                    child: Text(l.clearFilters),
                  ),
              ],
            ),
          ),
        ],
        const BackupNoticeBanner(),
        Expanded(
          child: recipes == null
              ? const Center(child: CircularProgressIndicator())
              : empty
              ? const _EmptyBook()
              : recipes.isEmpty
              ? _NoMatch(onClear: () => _search.clear())
              : grid
              ? _RecipeGrid(
                  recipes: recipes,
                  selected: widget.selected,
                  onTap: _open,
                  onLongPress: (id) => widget.onLongPress?.call(id),
                )
              : _RecipeRows(
                  recipes: recipes,
                  selected: widget.selected,
                  onTap: _open,
                  onLongPress: (id) => widget.onLongPress?.call(id),
                ),
        ),
      ],
    );
  }
}

/// Nút lọc/sắp xếp dạng viên thuốc, nhãn theo giá trị đang dùng.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final IconData? trailing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
          if (trailing != null) ...[
            const SizedBox(width: 2),
            Icon(trailing, size: 18),
          ],
        ],
      ),
    );
  }
}

/// Chưa có công thức nào: hướng dẫn 4 cách thêm (SCR-02).
class _EmptyBook extends StatelessWidget {
  const _EmptyBook();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final items = [
      (Icons.edit_note, l.addManual, '/recipe/new'),
      (Icons.public, l.fromWeb, '/web'),
      (Icons.document_scanner_outlined, l.scanPhoto, '/scan'),
      (Icons.file_open_outlined, l.importFile, '/import'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
      child: Column(
        children: [
          const BepIllustration(BepIllo.collect),
          const SizedBox(height: 16),
          Text(
            l.noRecipes,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            l.noRecipesHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              for (final (icon, title, route) in items)
                Card(
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () => context.push(route),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(icon, color: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l.privacyNote,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoMatch extends ConsumerWidget {
  const _NoMatch({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 16),
            Text(
              l.noMatch,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                onClear();
                ref
                    .read(recipeQueryProvider.notifier)
                    .set(ref.read(recipeQueryProvider).cleared());
              },
              child: Text(l.clearFilters),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ảnh bìa hoặc ô thay thế có tên danh mục.
Widget _cover(RecipeSummary r, {required int cacheWidth}) {
  final photo = r.coverPhoto;
  if (photo != null) return RecipePhoto(photo, cacheWidth: cacheWidth);
  return PhotoPlaceholder(title: r.name, categoryLabel: r.categoryName);
}

class _RecipeRows extends StatelessWidget {
  const _RecipeRows({
    required this.recipes,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final List<RecipeSummary> recipes;
  final Set<int>? selected;
  final void Function(int id) onTap;
  final void Function(int id) onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: recipes.length,
      itemBuilder: (context, i) {
        final r = recipes[i];
        return RecipeRow(
          cover: _cover(r, cacheWidth: 200),
          title: r.name,
          selected: selected?.contains(r.id),
          bookmarked: r.favorite,
          onTap: () => onTap(r.id),
          onLongPress: () => onLongPress(r.id),
          meta: Row(
            children: [
              if (r.totalMinutes != null) ...[
                Icon(Icons.schedule, size: 15, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  formatMinutes(l, r.totalMinutes!),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 10),
              ],
              StarRating(value: r.rating, size: 14),
              if (r.categoryName != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    r.categoryName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  const _RecipeGrid({
    required this.recipes,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final List<RecipeSummary> recipes;
  final Set<int>? selected;
  final void Function(int id) onTap;
  final void Function(int id) onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, i) {
        final r = recipes[i];
        return RecipeCard(
          cover: _cover(r, cacheWidth: 400),
          title: r.name,
          selected: selected?.contains(r.id),
          bookmarked: r.favorite,
          onTap: () => onTap(r.id),
          onLongPress: () => onLongPress(r.id),
          meta: Row(
            children: [
              if (r.totalMinutes != null) ...[
                Icon(Icons.schedule, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    formatMinutes(l, r.totalMinutes!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              StarRating(value: r.rating, size: 13),
            ],
          ),
        );
      },
    );
  }
}
