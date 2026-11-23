import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/data_providers_v3.dart';
import '../../data/pantry_repository.dart';
import '../../providers.dart';
import '../../ui/ui.dart';
import '../shopping/add_to_shopping_sheet.dart';

/// SCR-45: "Nấu được gì?" (AC-43). Xếp công thức theo tỉ lệ nguyên liệu đang
/// có trong Tủ bếp; công tắc bỏ qua gia vị cơ bản; thêm món thiếu vào đi chợ.
class CanCookScreen extends ConsumerWidget {
  const CanCookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final startup = ref.watch(v3StartupProvider);
    if (startup.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.pantryWhatCanICook)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final ignoreBasics = ref.watch(ignoreBasicsProvider).value ?? false;
    final recipes = ref.watch(cookableProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.pantryWhatCanICook)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SwitchListTile(
            value: ignoreBasics,
            onChanged: (v) =>
                ref.read(settingsRepositoryProvider).setIgnoreBasics(v),
            title: Text(l.pantryBasicsSwitch),
          ),
          if (recipes.isEmpty)
            EmptyState(
              illustration: BepIllo.jar,
              title: l.pantryCanCookEmpty,
              body: l.pantryCanCookEmptyBody,
              actions: [
                BepButton(
                  label: l.pantryAdd,
                  icon: Icons.add,
                  onPressed: () => context.pop(),
                ),
              ],
            )
          else ...[
            NotebookTabHeader(
              l.pantryWhatCanICook,
              count: l.pantryCanCookRecipes(recipes.length),
            ),
            for (final r in recipes) _RecipeTile(recipe: r),
          ],
        ],
      ),
    );
  }
}

class _RecipeTile extends ConsumerWidget {
  const _RecipeTile({required this.recipe});

  final CookableRecipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final missing = recipe.missing.join(', ');
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Semantics(
              label: l.pantryMatch(recipe.have, recipe.total),
              child: ExcludeSemantics(
                child: LinearProgressIndicator(
                  value: recipe.ratio,
                  minHeight: 6,
                  borderRadius: BepRadius.circular(BepRadius.xs),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.pantryMatch(recipe.have, recipe.total),
              style: theme.textTheme.labelMedium!.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              recipe.missing.isEmpty
                  ? l.pantryMissingNone
                  : l.pantryMissingOne(recipe.missingCount, missing),
              style: theme.textTheme.bodySmall!.copyWith(
                color: recipe.missing.isEmpty
                    ? context.bep.success
                    : cs.onSurfaceVariant,
              ),
            ),
            if (recipe.missing.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: BepButton(
                  label: l.pantryAddMissing,
                  kind: BepButtonKind.outlined,
                  icon: Icons.add_shopping_cart,
                  onPressed: () async {
                    await showAddIngredientsToShoppingSheet(
                      context,
                      recipes: [ShoppingSourceRecipe(recipe.id)],
                    );
                    if (!context.mounted) return;
                    showBepSnackBar(l.pantryMissingAdded);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
