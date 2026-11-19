import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../cook/cook_providers.dart';
import '../../cook/recipe_view.dart';
import '../../cooking/unit_conversion.dart';
import '../../data/database.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/linkified_text.dart';
import '../../ui/recipe_photo.dart';
import '../../ui/ui.dart';
import '../exchange/exchange_actions.dart';
import '../home/recipe_format.dart';
import '../menu/add_to_menu_sheet.dart';
import '../shopping/add_to_shopping_sheet.dart';
import 'servings_sheet.dart';

String difficultyLabel(AppLocalizations l, Difficulty? d) => switch (d) {
  Difficulty.easy => l.difficultyEasy,
  Difficulty.medium => l.difficultyMedium,
  Difficulty.hard => l.difficultyHard,
  null => l.difficultyNone,
};

/// Xem một công thức (AC-09) và các thao tác sửa, nhân bản, xóa (AC-05, AC-06).
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final recipe = ref.watch(recipeProvider(id));
    return recipe.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (r) {
        if (r == null || r.deletedAt != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l.notFound)),
          );
        }
        return _Detail(recipe: r);
      },
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.recipe});

  final RecipeDetail recipe;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  final _photos = PageController();
  int _photo = 0;

  @override
  void dispose() {
    _photos.dispose();
    super.dispose();
  }

  RecipeDetail get recipe => widget.recipe;

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(recipeRepositoryProvider);
    final router = GoRouter.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.deleteTitle),
        content: Text(l.deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await repo.moveToTrash(recipe.id);
    router.pop();
    showUndoSnackBar(
      message: l.deletedMessage,
      undoLabel: l.undo,
      onUndo: () => repo.restore(recipe.id),
    );
  }

  Future<void> _duplicate() async {
    final l = AppLocalizations.of(context);
    final newId = await ref
        .read(recipeRepositoryProvider)
        .duplicate(recipe.id, copyLabel: l.copyLabel);
    showMessage(l.duplicated);
    if (mounted) context.pushReplacement('/recipe/$newId');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final d = recipe.draft;
    final view = ref.watch(recipeViewProvider(recipe.id));
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final categoryNames = {for (final c in categories) c.id: c.name};
    final unit = d.servingsUnit ?? l.peopleUnit;

    final facts = <(String, String)>[
      if (d.servings != null)
        (l.factServings, '${formatNumber(d.servings!)} $unit'),
      if (d.prepMinutes != null)
        (l.factPrep, formatMinutes(l, d.prepMinutes!)),
      if (d.cookMinutes != null)
        (l.factCook, formatMinutes(l, d.cookMinutes!)),
      if (d.totalMinutes != null)
        (l.factTotal, formatMinutes(l, d.totalMinutes!)),
      if (d.difficulty != null)
        (l.factDifficulty, difficultyLabel(l, d.difficulty)),
    ];

    Widget sectionTitle(String title, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleLarge!.copyWith(
                fontFamily: kSerifFamily,
                fontFamilyFallback: const [kSansFamily],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    final ingredients = ingredientsView(d.ingredients, view);
    final steps = stepsView(d.steps, view);
    final scaleLabel = [
      d.servings == null
          ? l.noServings
          : '${formatNumber(d.servings!)} $unit',
      formatFactor(view.factor),
      view.units == null
          ? l.unitOriginal
          : view.units == UnitSystem.metric
          ? l.unitMetric
          : l.unitUs,
    ].join(' · ');

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(
            recipe: recipe,
            controller: _photos,
            index: _photo,
            onIndex: (i) => setState(() => _photo = i),
            onDelete: _delete,
            onDuplicate: _duplicate,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        d.name,
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontFamily: kSerifFamily,
                          fontFamilyFallback: const [kSansFamily],
                        ),
                      ),
                    ),
                    if (d.favorite) const RibbonBookmark(size: 28),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StarRating(value: d.rating, size: 20),
                    const SizedBox(width: 8),
                    Text('${d.rating}/5', style: theme.textTheme.bodyMedium),
                  ],
                ),
                if (d.categoryIds.isNotEmpty || d.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final id in d.categoryIds)
                        if (categoryNames[id] != null)
                          Chip(
                            avatar: const Icon(Icons.folder_outlined, size: 18),
                            label: Text(categoryNames[id]!),
                          ),
                      for (final t in d.tags)
                        Chip(
                          avatar: const Icon(Icons.sell_outlined, size: 18),
                          label: Text(t),
                        ),
                    ],
                  ),
                ],
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FactsGrid(facts: facts),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.cookedTimes(recipe.cookCount),
                            style: theme.textTheme.labelLarge,
                          ),
                          if (recipe.lastCookedAt != null)
                            Text(
                              l.lastCooked(
                                DateFormat.yMMMd(
                                  Localizations.localeOf(
                                    context,
                                  ).languageCode,
                                ).format(recipe.lastCookedAt!),
                              ),
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(recipeRepositoryProvider)
                            .markCooked(recipe.id);
                        showMessage(l.cookedRecorded);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(l.markCooked),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            showAddToMenuSheet(context, recipe.id),
                        icon: const Icon(Icons.calendar_month_outlined, size: 20),
                        label: Text(
                          l.addToMenu,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            showAddToShoppingSheet(context, recipe.id),
                        icon: const Icon(
                          Icons.shopping_basket_outlined,
                          size: 20,
                        ),
                        label: Text(
                          l.addToShopping,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                sectionTitle(
                  l.ingredients,
                  trailing: ActionChip(
                    label: Text(scaleLabel),
                    onPressed: () =>
                        showServingsSheet(context, recipe.id, recipe),
                  ),
                ),
                for (final line in ingredients)
                  Padding(
                    padding: EdgeInsets.only(top: line.isHeading ? 10 : 6),
                    child: line.isHeading
                        ? Semantics(
                            header: true,
                            child: Text(
                              line.text,
                              style: theme.textTheme.titleSmall!.copyWith(
                                fontFamily: kSerifFamily,
                                fontFamilyFallback: const [kSansFamily],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: LinkifiedText(line.text)),
                              if (line.cannotScale)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 15,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                  ),
                if (d.steps.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  sectionTitle(l.steps),
                  for (final (i, line) in steps.indexed)
                    Padding(
                      padding: EdgeInsets.only(top: line.isHeading ? 10 : 8),
                      child: line.isHeading
                          ? Semantics(
                              header: true,
                              child: Text(
                                line.text,
                                style: theme.textTheme.titleSmall!.copyWith(
                                  fontFamily: kSerifFamily,
                                  fontFamilyFallback: const [kSansFamily],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '${i + 1}.',
                                    style: theme.textTheme.bodyMedium!
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Expanded(child: LinkifiedText(line.text)),
                              ],
                            ),
                    ),
                ],
                if (d.notes != null && d.notes!.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  sectionTitle(l.notes),
                  LinkifiedText(d.notes!),
                ],
                if (d.nutrition != null && d.nutrition!.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  sectionTitle(l.nutrition),
                  Text(d.nutrition!),
                ],
                if ((d.source ?? '').isNotEmpty ||
                    (d.sourceUrl ?? '').isNotEmpty) ...[
                  const SizedBox(height: 22),
                  sectionTitle(l.source),
                  if ((d.source ?? '').isNotEmpty) Text(d.source!),
                  if ((d.sourceUrl ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LinkifiedText(d.sourceUrl!),
                    ),
                ],
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: BepButton(
          label: l.cookButton,
          icon: Icons.soup_kitchen_outlined,
          size: BepButtonSize.cook,
          block: true,
          onPressed: () => context.push('/cook/${recipe.id}'),
        ),
      ),
    );
  }
}

/// Ảnh lớn ở đầu trang + các nút nổi (SCR-07).
class _Hero extends ConsumerWidget {
  const _Hero({
    required this.recipe,
    required this.controller,
    required this.index,
    required this.onIndex,
    required this.onDelete,
    required this.onDuplicate,
  });

  final RecipeDetail recipe;
  final PageController controller;
  final int index;
  final ValueChanged<int> onIndex;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = recipe.draft;
    final photos = d.photos;
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photos.isEmpty)
            PhotoPlaceholder(
              title: d.name,
              categoryLabel: null,
            )
          else
            PageView.builder(
              controller: controller,
              itemCount: photos.length,
              onPageChanged: onIndex,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () =>
                    context.push('/recipe/${recipe.id}/photos?index=$i'),
                child: RecipePhoto(photos[i], cacheWidth: 900),
              ),
            ),
          if (photos.isNotEmpty) const PhotoScrim(height: 140),
          Positioned(
            left: 8,
            top: 8,
            child: _HeroButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                _HeroButton(
                  tooltip: l.favorite,
                  icon: d.favorite ? Icons.favorite : Icons.favorite_border,
                  color: d.favorite ? Colors.redAccent : null,
                  onPressed: () => ref
                      .read(recipeRepositoryProvider)
                      .setFavorite(recipe.id, !d.favorite),
                ),
                _HeroButton(
                  tooltip: l.shareRecipe,
                  icon: Icons.ios_share,
                  onPressed: () =>
                      shareRecipeSheet(context, ref, recipe.id, d.name),
                ),
                PopupMenuButton<String>(
                  tooltip: l.moreActions,
                  color: cs.surfaceContainerHigh,
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (v) => v == 'copy' ? onDuplicate() : onDelete(),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'copy', child: Text(l.duplicate)),
                    PopupMenuItem(value: 'delete', child: Text(l.delete)),
                  ],
                ),
              ],
            ),
          ),
          if (photos.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .55),
                  borderRadius: BepRadius.circular(BepRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${index + 1}/${photos.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: Colors.black.withValues(alpha: .45),
      foregroundColor: color ?? Colors.white,
    ),
    icon: Icon(icon),
  );
}

/// Bảng thông tin 3 cột có kẻ ô như sổ tay.
class _FactsGrid extends StatelessWidget {
  const _FactsGrid({required this.facts});

  final List<(String, String)> facts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cells = [...facts];
    while (cells.length % 3 != 0) {
      cells.add(('', ''));
    }
    Widget cell((String, String) f) => TableCell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (f.$1.isNotEmpty)
              Text(
                f.$1,
                style: theme.textTheme.labelSmall!.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
            if (f.$1.isNotEmpty && f.$2.isNotEmpty)
              const SizedBox(height: 2),
            if (f.$2.isNotEmpty)
              Text(
                f.$2,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BepRadius.circular(BepRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder.all(color: cs.outlineVariant, width: 1),
        children: [
          for (var i = 0; i < cells.length; i += 3)
            TableRow(
              children: [
                for (var c = 0; c < 3; c++)
                  if (i + c < cells.length) cell(cells[i + c]) else Container(),
              ],
            ),
        ],
      ),
    );
  }
}
