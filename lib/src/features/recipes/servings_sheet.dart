import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../cook/cook_providers.dart';
import '../../cook/recipe_view.dart';
import '../../cooking/unit_conversion.dart';
import '../../data/recipe_repository.dart';
import '../../ui/theme/theme.dart';
import '../home/recipe_format.dart';

/// Bảng "Khẩu phần & đơn vị" (SCR-08): chỉ đổi cách đang xem, công thức gốc
/// không đổi (AC-32, AC-33).
Future<void> showServingsSheet(
  BuildContext context,
  int recipeId,
  RecipeDetail recipe,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => _ServingsSheet(id: recipeId, recipe: recipe),
);

class _ServingsSheet extends ConsumerWidget {
  const _ServingsSheet({required this.id, required this.recipe});

  final int id;
  final RecipeDetail recipe;

  Future<void> _custom(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    final factor = await showDialog<double>(
      context: context,
      builder: (dialog) {
        String? error;
        return StatefulBuilder(
          builder: (dialog, setState) => AlertDialog(
            title: Text(l.scaleCustomTitle),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l.scaleFactorLabel,
                errorText: error,
              ),
              onSubmitted: (v) => Navigator.pop(dialog, parseFactor(v)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final v = parseFactor(controller.text);
                  if (v == null) {
                    setState(() => error = l.scaleInvalid);
                  } else {
                    Navigator.pop(dialog, v);
                  }
                },
                child: Text(l.done),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (factor != null) ref.read(recipeViewProvider(id).notifier).setFactor(factor);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final view = ref.watch(recipeViewProvider(id));
    final notifier = ref.read(recipeViewProvider(id).notifier);
    final base = recipe.draft.servings;
    final unit = recipe.draft.servingsUnit ?? l.peopleUnit;
    final shown = base == null ? null : base * view.factor;

    void step(int delta) {
      if (base == null || base <= 0) return;
      final next = (shown! + delta).clamp(1, 9999).toDouble();
      notifier.setFactor(next / base);
    }

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: theme.textTheme.labelLarge),
    );

    final preview = ingredientsView(recipe.draft.ingredients, view)
        .where((line) => !line.isHeading)
        .take(4)
        .toList();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l.servingsUnitsTitle,
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                label(l.servings),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.outline),
                    borderRadius: BepRadius.circular(BepRadius.full),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: l.decreaseServings,
                        onPressed: base == null ? null : () => step(-1),
                        icon: const Icon(Icons.remove),
                      ),
                      Expanded(
                        child: Text(
                          base == null
                              ? l.noServings
                              : '${formatNumber(shown!)} $unit',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: l.increaseServings,
                        onPressed: base == null ? null : () => step(1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                label(l.scaleFactorLabel),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in [0.5, 1.0, 2.0, 3.0])
                      ChoiceChip(
                        label: Text(formatFactor(f)),
                        selected: view.factor == f,
                        onSelected: (_) => notifier.setFactor(f),
                      ),
                    ChoiceChip(
                      label: Text(l.scaleCustomButton),
                      selected: false,
                      onSelected: (_) => _custom(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                label(l.unitsLabel),
                SegmentedButton<UnitSystem?>(
                  segments: [
                    ButtonSegment(value: null, label: Text(l.unitOriginal)),
                    ButtonSegment(
                      value: UnitSystem.metric,
                      label: Text(l.unitMetric),
                    ),
                    ButtonSegment(
                      value: UnitSystem.us,
                      label: Text(l.unitUs),
                    ),
                  ],
                  selected: {view.units},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => notifier.setUnits(s.first),
                ),
                const SizedBox(height: 8),
                Text(
                  l.unitsCaption,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                label(l.previewLabel),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    border: Border.all(color: cs.outlineVariant),
                    borderRadius: BepRadius.circular(BepRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (preview.isEmpty)
                        Text(
                          l.ingredientsHint,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      for (final line in preview)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  line.text,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              if (line.cannotScale)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 15,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        l.cannotScale,
                                        style: theme.textTheme.bodySmall!
                                            .copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: notifier.reset,
                  child: Text(l.resetView),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.done),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
