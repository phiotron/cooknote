import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/data_providers_v3.dart';
import '../../data/shopping_repository.dart';
import '../../data/v3_defaults.dart';
import '../../shopping/name_match.dart';
import '../../shopping/quantity_merge.dart';
import '../../ui/ui.dart';

/// Một công thức nguồn của bảng "Thêm vào đi chợ" (SCR-32).
class ShoppingSourceRecipe {
  const ShoppingSourceRecipe(this.recipeId, {this.servings, this.onlyLineIds});

  final int recipeId;

  /// Khẩu phần cần mua; null = khẩu phần đang xem (recipeViewProvider) hoặc gốc.
  final double? servings;

  /// Chỉ các dòng nguyên liệu này (id `recipe_lines`); null = tất cả.
  /// "Nấu được gì?" (SCR-45) truyền các dòng còn thiếu.
  final Set<int>? onlyLineIds;
}

/// ĐIỂM NỐI CỐ ĐỊNH (F0): chi tiết công thức → "Thêm vào đi chợ" (SCR-32) cho một công
/// thức ở khẩu phần đang xem. G1 gọi hàm này; G4 thay ruột (giữ chữ ký).
Future<void> showAddToShoppingSheet(BuildContext context, int recipeId) =>
    showAddIngredientsToShoppingSheet(
      context,
      recipes: [ShoppingSourceRecipe(recipeId)],
    );

/// ĐIỂM NỐI CỐ ĐỊNH (F0): dạng tổng quát cho nhiều công thức — Thực đơn theo khoảng ngày
/// (SCR-41) và "Nấu được gì?" (SCR-45, chỉ món thiếu). G5 gọi; G4 làm ruột.
Future<void> showAddIngredientsToShoppingSheet(
  BuildContext context, {
  required List<ShoppingSourceRecipe> recipes,
}) {
  if (recipes.isEmpty) return Future.value();
  return showBepSheet<void>(
    context,
    builder: (_) => _AddToShoppingSheet(recipes: recipes),
  );
}

/// "Nấu được gì?" (SCR-45): chỉ thêm các dòng nguyên liệu còn thiếu.
Future<void> showAddCandidatesSheet(
  BuildContext context, {
  required int recipeId,
  required Set<int> onlyLineIds,
}) => showAddIngredientsToShoppingSheet(
  context,
  recipes: [ShoppingSourceRecipe(recipeId, onlyLineIds: onlyLineIds)],
);

/// Thực đơn theo khoảng ngày (SCR-41): ứng viên đã tính sẵn theo khẩu phần
/// từng bữa, mở thẳng bảng chọn nguyên liệu.
Future<void> showAddShoppingCandidatesSheet(
  BuildContext context, {
  required List<ShoppingCandidate> candidates,
}) {
  if (candidates.isEmpty) return Future.value();
  return showBepSheet<void>(
    context,
    builder: (_) =>
        _AddToShoppingSheet(recipes: const [], initialCandidates: candidates),
  );
}

class _AddToShoppingSheet extends ConsumerStatefulWidget {
  const _AddToShoppingSheet({required this.recipes, this.initialCandidates});

  final List<ShoppingSourceRecipe> recipes;
  final List<ShoppingCandidate>? initialCandidates;

  @override
  ConsumerState<_AddToShoppingSheet> createState() =>
      _AddToShoppingSheetState();
}

class _AddToShoppingSheetState extends ConsumerState<_AddToShoppingSheet> {
  List<ShoppingCandidate> _candidates = const [];
  List<bool> _selected = const [];
  int? _listId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ref.read(v3StartupProvider.future);
    final repo = ref.read(shoppingRepositoryProvider);
    final lists = await repo.getLists();
    final all = <ShoppingCandidate>[];
    if (widget.initialCandidates != null) {
      all.addAll(widget.initialCandidates!);
    } else {
      for (final source in widget.recipes) {
        all.addAll(
          await repo.candidatesForRecipe(
            source.recipeId,
            servings: source.servings,
            onlyLineIds: source.onlyLineIds,
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _candidates = all;
      _selected = [for (final c in all) c.selected];
      _listId = lists.isEmpty ? null : lists.first.id;
      _loading = false;
    });
  }

  Future<void> _createList() async {
    final l = AppLocalizations.of(context);
    final name = defaultShoppingListName(
      Localizations.localeOf(context).languageCode,
    );
    try {
      final id = await ref.read(shoppingRepositoryProvider).createList(name);
      if (!mounted) return;
      setState(() => _listId = id);
    } on ShoppingException catch (e) {
      if (!mounted) return;
      showMessage(switch (e.problem) {
        ShoppingProblem.emptyName => l.nameRequired,
        ShoppingProblem.nameTooLong => l.nameTooLong,
        ShoppingProblem.notFound => l.notFound,
      });
    }
  }

  Future<void> _add() async {
    final listId = _listId;
    if (listId == null) return;
    final chosen = [
      for (var i = 0; i < _candidates.length; i++)
        if (_selected[i]) _candidates[i],
    ];
    if (chosen.isEmpty) return;
    final l = AppLocalizations.of(context);
    try {
      await ref.read(shoppingRepositoryProvider).addCandidates(listId, chosen);
      if (!mounted) return;
      Navigator.pop(context);
      showBepSnackBar(l.shoppingAdded(chosen.length));
    } on ShoppingException catch (e) {
      if (!mounted) return;
      showMessage(switch (e.problem) {
        ShoppingProblem.emptyName => l.nameRequired,
        ShoppingProblem.nameTooLong => l.nameTooLong,
        ShoppingProblem.notFound => l.notFound,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lists = ref.watch(shoppingListsProvider).value ?? const [];
    final listId = lists.any((x) => x.id == _listId)
        ? _listId
        : (lists.isEmpty ? null : lists.first.id);
    final items = listId == null
        ? const <ShoppingItem>[]
        : (ref.watch(shoppingItemsProvider(listId)).value ??
              const <ShoppingItem>[]);

    var selectedCount = 0;
    var mergeCount = 0;
    for (var i = 0; i < _candidates.length; i++) {
      if (!_selected[i]) continue;
      selectedCount++;
      final c = _candidates[i];
      if (items.any(
        (it) =>
            !it.checked &&
            namesMatch(it.name, c.name) &&
            canMerge(it.quantity, c.quantity),
      )) {
        mergeCount++;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.menuShoppingRangeTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.cancel),
              ),
            ],
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l.shoppingNoIngredients,
                style: theme.textTheme.bodyLarge,
              ),
            )
          else ...[
            Row(
              children: [
                Text(l.shoppingAddToList, style: theme.textTheme.labelLarge),
                const SizedBox(width: 8),
                if (lists.isEmpty)
                  TextButton(
                    onPressed: _createList,
                    child: Text(l.shoppingNewList),
                  )
                else
                  Flexible(
                    child: DropdownButton<int>(
                      value: listId,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (final ls in lists)
                          DropdownMenuItem(
                            value: ls.id,
                            child: Text(
                              ls.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _listId = v),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _candidates.length; i++) ...[
                  if (i == 0 ||
                      _candidates[i].recipeId != _candidates[i - 1].recipeId)
                    NotebookTabHeader(
                      _candidates[i].recipeName ?? l.addToShopping,
                      count: _sourceCount(i),
                    ),
                  CheckboxListTile(
                    value: _selected[i],
                    onChanged: (v) => setState(() => _selected[i] = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(_candidates[i].label()),
                    subtitle: _candidates[i].inPantry
                        ? Text(l.shoppingInPantry)
                        : null,
                    dense: true,
                  ),
                ],
              ],
            ),
            if (mergeCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
                        l.shoppingMergeWarning(mergeCount),
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            BepButton(
              block: true,
              label: selectedCount == 0
                  ? l.shoppingNoneSelected
                  : l.shoppingAddCount(selectedCount),
              onPressed: selectedCount == 0 || listId == null ? null : _add,
            ),
          ],
        ],
      ),
    );
  }

  /// Số dòng của cùng công thức bắt đầu tại [start].
  String _sourceCount(int start) {
    final id = _candidates[start].recipeId;
    var n = 0;
    for (var i = start; i < _candidates.length; i++) {
      if (_candidates[i].recipeId != id) break;
      n++;
    }
    return '$n';
  }
}
