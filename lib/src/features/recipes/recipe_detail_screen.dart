import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../data/recipe_lines.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/linkified_text.dart';
import '../../ui/messenger.dart';
import '../../ui/recipe_photo.dart';
import '../exchange/exchange_actions.dart';

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

class _Detail extends ConsumerWidget {
  const _Detail({required this.recipe});

  final RecipeDetail recipe;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
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

  Future<void> _duplicate(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final newId = await ref
        .read(recipeRepositoryProvider)
        .duplicate(recipe.id, copyLabel: l.copyLabel);
    showMessage(l.duplicated);
    if (context.mounted) context.pushReplacement('/recipe/$newId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = recipe.draft;
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );

    Widget lineList(List<RecipeLine> lines, {required bool numbered}) {
      var n = 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: EdgeInsets.only(top: line.isHeading ? 12 : 6),
              child: line.isHeading
                  ? Semantics(
                      header: true,
                      child: Text(line.text, style: theme.textTheme.titleSmall),
                    )
                  : numbered
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 28, child: Text('${++n}.')),
                        Expanded(child: LinkifiedText(line.text)),
                      ],
                    )
                  : LinkifiedText(line.text),
            ),
        ],
      );
    }

    final facts = <String>[
      if (d.servings != null)
        '${_num(d.servings!)}${d.servingsUnit == null ? '' : ' ${d.servingsUnit}'}',
      if (d.prepMinutes != null)
        '${l.prepTime.split(' (').first}: ${l.minutesShort(d.prepMinutes!)}',
      if (d.cookMinutes != null)
        '${l.cookTime.split(' (').first}: ${l.minutesShort(d.cookMinutes!)}',
      if (d.totalMinutes != null)
        '${l.totalTime.split(' (').first}: ${l.minutesShort(d.totalMinutes!)}',
      if (d.difficulty != null) difficultyLabel(l, d.difficulty),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l.favorite,
            icon: Icon(
              d.favorite ? Icons.favorite : Icons.favorite_border,
              color: d.favorite ? Colors.redAccent : null,
            ),
            onPressed: () => ref
                .read(recipeRepositoryProvider)
                .setFavorite(recipe.id, !d.favorite),
          ),
          IconButton(
            tooltip: l.shareRecipe,
            icon: const Icon(Icons.ios_share),
            onPressed: () =>
                shareRecipeSheet(context, ref, recipe.id, d.name),
          ),
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/recipe/${recipe.id}/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) =>
                v == 'copy' ? _duplicate(context, ref) : _delete(context, ref),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'copy', child: Text(l.duplicate)),
              PopupMenuItem(value: 'delete', child: Text(l.delete)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (d.photos.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: d.photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => InkWell(
                  onTap: () =>
                      context.push('/recipe/${recipe.id}/photos?index=$i'),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RecipePhoto(d.photos[i], cacheWidth: 800),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Semantics(
                  label: l.ratingStars(d.rating),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Icon(
                          i <= d.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber.shade700,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (d.categoryIds.isNotEmpty || d.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    if (d.categoryIds.contains(c.id))
                      Chip(
                        avatar: const Icon(Icons.folder_outlined, size: 18),
                        label: Text(c.name),
                      ),
                  for (final t in d.tags)
                    Chip(
                      avatar: const Icon(Icons.sell_outlined, size: 18),
                      label: Text(t),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l.markCooked),
                  onPressed: () async {
                    await ref
                        .read(recipeRepositoryProvider)
                        .markCooked(recipe.id);
                    showMessage(l.cookedRecorded);
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recipe.cookCount == 0
                        ? l.cookedTimes(0)
                        : '${l.cookedTimes(recipe.cookCount)}\n${l.lastCooked(DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(recipe.lastCookedAt!))}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (facts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final f in facts) Chip(label: Text(f))],
              ),
            ),
          if (d.ingredients.isNotEmpty)
            section(l.ingredients, [lineList(d.ingredients, numbered: false)]),
          if (d.steps.isNotEmpty)
            section(l.steps, [lineList(d.steps, numbered: true)]),
          if (d.notes != null && d.notes!.isNotEmpty)
            section(l.notes, [LinkifiedText(d.notes!)]),
          if (d.nutrition != null && d.nutrition!.isNotEmpty)
            section(l.nutrition, [Text(d.nutrition!)]),
          if ((d.source ?? '').isNotEmpty || (d.sourceUrl ?? '').isNotEmpty)
            section(l.source, [
              if ((d.source ?? '').isNotEmpty) Text(d.source!),
              if ((d.sourceUrl ?? '').isNotEmpty) LinkifiedText(d.sourceUrl!),
            ]),
        ],
      ),
    );
  }
}

/// Số khẩu phần gọn: 4 thay vì 4.0.
String _num(double v) => v == v.roundToDouble() ? '${v.toInt()}' : v.toString();
