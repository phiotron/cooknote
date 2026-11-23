import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/aisle_repository.dart';
import '../../data/data_providers_v3.dart';
import '../../data/shopping_repository.dart';
import '../../exchange/exchange_providers.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// Gốc tab Đi chợ (SCR-27, AC-34..AC-37). Mỗi danh sách có các món xếp theo
/// khu vực; chạm vào dòng để gạch, menu để sửa/chuyển khu vực/xóa. Các bảng
/// SCR-28 (danh sách), SCR-29 (thêm món), SCR-33 (dọn/chia sẻ) nằm trong file.
class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  int? _selectedListId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final startup = ref.watch(v3StartupProvider);
    if (startup.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.tabShopping)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final lists = ref.watch(shoppingListsProvider).value ?? const [];
    if (lists.isEmpty) return _buildNoLists(context, l);

    var current = _selectedListId;
    if (current == null || !lists.any((x) => x.id == current)) {
      current = lists.first.id;
    }
    return _buildList(context, l, lists, current);
  }

  Widget _buildNoLists(BuildContext context, AppLocalizations l) => Scaffold(
    appBar: AppBar(title: Text(l.tabShopping)),
    body: EmptyState(
      illustration: BepIllo.basket,
      title: l.shoppingMakeFirstList,
      body: l.shoppingNoListsHint,
      actions: [
        BepButton(
          label: l.shoppingNewList,
          icon: Icons.add,
          onPressed: () => _createList(context),
        ),
      ],
    ),
  );

  Widget _buildList(
    BuildContext context,
    AppLocalizations l,
    List<ShoppingListInfo> lists,
    int listId,
  ) {
    final list = lists.firstWhere((x) => x.id == listId);
    final items =
        ref.watch(shoppingItemsProvider(listId)).value ??
        const <ShoppingItem>[];
    final aisles = ref.watch(aislesProvider).value ?? const <Aisle>[];
    final frequent =
        ref.watch(frequentItemsProvider).value ?? const <KnownItem>[];

    final checked = [
      for (final i in items)
        if (i.checked) i,
    ];
    final open = [
      for (final i in items)
        if (!i.checked) i,
    ];
    final bought = checked.length;
    final total = items.length;
    final remaining = open.length;

    final groups = <int?, List<ShoppingItem>>{};
    for (final item in open) {
      groups.putIfAbsent(item.aisleId, () => []).add(item);
    }
    final knownAisles = {for (final a in aisles) a.id};

    final rows = <Widget>[];
    for (final aisle in aisles) {
      final group = groups[aisle.id];
      if (group == null || group.isEmpty) continue;
      rows.add(NotebookTabHeader(aisle.name, count: '${group.length}'));
      for (final item in group) {
        rows.add(_row(context, l, listId, item, aisles));
      }
    }
    final other = [
      for (final entry in groups.entries)
        if (!knownAisles.contains(entry.key)) ...entry.value,
    ];
    if (other.isNotEmpty) {
      rows.add(NotebookTabHeader(l.shoppingNoAisle, count: '${other.length}'));
      for (final item in other) {
        rows.add(_row(context, l, listId, item, aisles));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _chooseList(context, listId),
          borderRadius: BepRadius.circular(BepRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    list.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.shoppingAisles,
            onPressed: () => context.push('/shopping/aisles'),
            icon: const Icon(Icons.storefront_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: l.moreActions,
            onSelected: (v) async {
              switch (v) {
                case 'share':
                  await _share(context, l, listId, open.isNotEmpty);
                case 'rename':
                  await _renameList(context, l, list);
                case 'delete':
                  await _deleteList(context, l, list);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'share', child: Text(l.shoppingShareTitle)),
              PopupMenuItem(value: 'rename', child: Text(l.shoppingRenameList)),
              PopupMenuItem(value: 'delete', child: Text(l.shoppingDeleteList)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context, listId),
        icon: const Icon(Icons.add),
        label: Text(l.shoppingAddItem),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.shoppingBoughtOf(bought, total),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/shopping/aisles'),
                  icon: const Icon(Icons.place_outlined, size: 18),
                  label: Text(l.shoppingAisleCount(aisles.length)),
                ),
              ],
            ),
          ),
          if (items.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.shoppingNothingToBuy,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.shoppingEmptyHint,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (frequent.isNotEmpty) ...[
              NotebookTabHeader(l.shoppingFrequent),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final item in frequent)
                      ActionChip(
                        label: Text(item.name),
                        onPressed: () => _addKnown(listId, item.name),
                      ),
                  ],
                ),
              ),
            ],
          ] else ...[
            ...rows,
            if (remaining == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.shoppingAllDone,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.shoppingAllDoneSub,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            if (checked.isNotEmpty) ...[
              NotebookTabHeader(
                l.shoppingBought,
                count: '$bought',
                trailing: TextButton(
                  onPressed: () => _clearChecked(context, l, listId, bought),
                  child: Text(l.shoppingClearChecked),
                ),
              ),
              for (final item in checked)
                _row(context, l, listId, item, aisles),
            ],
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    AppLocalizations l,
    int listId,
    ShoppingItem item,
    List<Aisle> aisles,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sources = item.sources.map((s) => s.recipeName).toList();
    final style = theme.textTheme.bodyLarge!.copyWith(
      decoration: item.checked ? TextDecoration.lineThrough : null,
      color: item.checked ? cs.onSurfaceVariant : null,
    );
    return Semantics(
      checked: item.checked,
      child: InkWell(
        onTap: () => ref
            .read(shoppingRepositoryProvider)
            .setChecked(item.id, !item.checked),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  item.checked
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: item.checked ? cs.primary : cs.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label(), style: style),
                    if (sources.isNotEmpty)
                      Text(
                        l.shoppingSourcesFor(sources.join(', ')),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    if (item.sources.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: BepTag(
                          l.shoppingMergedTag,
                          icon: Icons.merge_type,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l.moreActions,
                onSelected: (v) async {
                  switch (v) {
                    case 'edit':
                      await _editItem(context, l, item);
                    case 'move':
                      await _moveItem(context, l, item, aisles);
                    case 'delete':
                      await _deleteItem(context, l, listId, item);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l.edit)),
                  PopupMenuItem(
                    value: 'move',
                    child: Text(l.shoppingMoveAisleTitle),
                  ),
                  PopupMenuItem(value: 'delete', child: Text(l.remove)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- hành động

  Future<void> _createList(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final name = await _askText(
      context,
      title: l.shoppingNewList,
      label: l.shoppingListName,
      hint: l.shoppingNewListHint,
      maxLength: maxShoppingListName,
    );
    if (name == null || !mounted) return;
    try {
      final id = await ref.read(shoppingRepositoryProvider).createList(name);
      if (!mounted) return;
      setState(() => _selectedListId = id);
    } on ShoppingException catch (e) {
      if (!mounted) return;
      showMessage(_shoppingError(l, e.problem));
    }
  }

  Future<void> _chooseList(BuildContext context, int currentId) async {
    final id = await showBepSheet<int>(
      context,
      builder: (_) => _ListsSheet(currentId: currentId),
    );
    if (id != null && mounted) setState(() => _selectedListId = id);
  }

  Future<void> _renameList(
    BuildContext context,
    AppLocalizations l,
    ShoppingListInfo list,
  ) async {
    final name = await _askText(
      context,
      title: l.shoppingRenameList,
      label: l.shoppingListName,
      initial: list.name,
      maxLength: maxShoppingListName,
    );
    if (name == null || !mounted) return;
    try {
      await ref.read(shoppingRepositoryProvider).renameList(list.id, name);
    } on ShoppingException catch (e) {
      if (!mounted) return;
      showMessage(_shoppingError(l, e.problem));
    }
  }

  Future<void> _deleteList(
    BuildContext context,
    AppLocalizations l,
    ShoppingListInfo list,
  ) async {
    final ok = await showConfirmDialog(
      context,
      title: l.shoppingDeleteListConfirm(list.name, list.itemCount),
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(shoppingRepositoryProvider).deleteList(list.id);
    if (!mounted) return;
    setState(() => _selectedListId = null);
  }

  Future<void> _addItem(BuildContext context, int listId) => showBepSheet<void>(
    context,
    builder: (_) => _AddItemSheet(listId: listId),
  );

  Future<void> _addKnown(int listId, String name) async {
    final l = AppLocalizations.of(context);
    try {
      final result = await ref
          .read(shoppingRepositoryProvider)
          .addText(listId, name);
      if (!mounted) return;
      showBepSnackBar(l.shoppingAdded(result.added + result.merged));
    } on ShoppingException catch (e) {
      if (!mounted) return;
      showMessage(_shoppingError(l, e.problem));
    }
  }

  Future<void> _editItem(
    BuildContext context,
    AppLocalizations l,
    ShoppingItem item,
  ) async {
    final line = await _askText(
      context,
      title: l.shoppingItemEditTitle,
      label: l.shoppingItemName,
      hint: l.shoppingItemHint,
      initial: item.label(),
      maxLength: maxShoppingItemName,
    );
    if (line == null || !mounted) return;
    try {
      await ref.read(shoppingRepositoryProvider).editItem(item.id, line);
    } on ShoppingException catch (e) {
      if (!mounted) return;
      showMessage(_shoppingError(l, e.problem));
    }
  }

  Future<void> _moveItem(
    BuildContext context,
    AppLocalizations l,
    ShoppingItem item,
    List<Aisle> aisles,
  ) async {
    final selected = await showBepSheet<int>(
      context,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.shoppingMoveAisleTitle,
              style: Theme.of(sheet).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            for (final aisle in aisles)
              ListTile(
                leading: Icon(
                  item.aisleId == aisle.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(aisle.name),
                onTap: () => Navigator.pop(sheet, aisle.id),
              ),
            ListTile(
              leading: Icon(
                item.aisleId == null || !aisles.any((a) => a.id == item.aisleId)
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(l.shoppingNoAisle),
              onTap: () => Navigator.pop(sheet, -1),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    await ref
        .read(shoppingRepositoryProvider)
        .moveToAisle(item.id, selected == -1 ? null : selected);
  }

  Future<void> _deleteItem(
    BuildContext context,
    AppLocalizations l,
    int listId,
    ShoppingItem item,
  ) async {
    final ok = await showConfirmDialog(
      context,
      title: l.shoppingDeleteItemConfirm(item.name),
      confirmLabel: l.remove,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(shoppingRepositoryProvider).deleteItem(item.id);
    if (!mounted) return;
    showMessage(l.shoppingItemDeleted);
  }

  Future<void> _clearChecked(
    BuildContext context,
    AppLocalizations l,
    int listId,
    int count,
  ) async {
    var toPantry = ref.read(shoppingToPantryProvider).value ?? false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setLocal) => AlertDialog(
          title: Text(l.shoppingClearTitle(count)),
          content: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: toPantry,
            onChanged: (v) => setLocal(() => toPantry = v ?? false),
            title: Text(l.shoppingMoveToPantry),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(l.shoppingClearChecked),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(settingsRepositoryProvider).setShoppingToPantry(toPantry);
    final cleared = await ref
        .read(shoppingRepositoryProvider)
        .clearChecked(listId, toPantry: toPantry);
    if (!mounted) return;
    showMessage(l.shoppingCleared(cleared));
  }

  Future<void> _share(
    BuildContext context,
    AppLocalizations l,
    int listId,
    bool hasOpen,
  ) async {
    if (!hasOpen) {
      showMessage(l.shoppingShareEmpty);
      return;
    }
    final lists = ref.read(shoppingListsProvider).value ?? const [];
    final name = lists.where((x) => x.id == listId).firstOrNull?.name;
    final text = await ref
        .read(shoppingRepositoryProvider)
        .exportText(listId, noAisleLabel: l.shoppingNoAisle);
    if (!mounted) return;
    await ref.read(sharerProvider).shareText(text, subject: name);
  }
}

String _shoppingError(AppLocalizations l, ShoppingProblem problem) =>
    switch (problem) {
      ShoppingProblem.emptyName => l.nameRequired,
      ShoppingProblem.nameTooLong => l.nameTooLong,
      ShoppingProblem.notFound => l.notFound,
    };

/// Hộp nhập một dòng chữ (tên danh sách, món); null nếu hủy.
Future<String?> _askText(
  BuildContext context, {
  required String title,
  required String label,
  String? hint,
  String initial = '',
  int maxLength = 200,
}) {
  final l = AppLocalizations.of(context);
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: maxLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, hintText: hint),
        onSubmitted: (v) => Navigator.pop(dialog, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialog, controller.text),
          child: Text(l.save),
        ),
      ],
    ),
  );
}

/// SCR-28: chọn, đổi tên, xóa danh sách; tạo danh sách mới.
class _ListsSheet extends ConsumerWidget {
  const _ListsSheet({required this.currentId});

  final int? currentId;

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final name = await _askText(
      context,
      title: l.shoppingNewList,
      label: l.shoppingListName,
      hint: l.shoppingNewListHint,
      maxLength: maxShoppingListName,
    );
    if (name == null || !context.mounted) return;
    try {
      final id = await ref.read(shoppingRepositoryProvider).createList(name);
      if (!context.mounted) return;
      Navigator.pop(context, id);
    } on ShoppingException catch (e) {
      if (!context.mounted) return;
      showMessage(_shoppingError(l, e.problem));
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    ShoppingListInfo list,
  ) async {
    final l = AppLocalizations.of(context);
    final name = await _askText(
      context,
      title: l.shoppingRenameList,
      label: l.shoppingListName,
      initial: list.name,
      maxLength: maxShoppingListName,
    );
    if (name == null || !context.mounted) return;
    try {
      await ref.read(shoppingRepositoryProvider).renameList(list.id, name);
    } on ShoppingException catch (e) {
      if (!context.mounted) return;
      showMessage(_shoppingError(l, e.problem));
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ShoppingListInfo list,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l.shoppingDeleteListConfirm(list.name, list.itemCount),
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await ref.read(shoppingRepositoryProvider).deleteList(list.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lists = ref.watch(shoppingListsProvider).value ?? const [];
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
                  l.shoppingLists,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.done),
              ),
            ],
          ),
          for (final list in lists)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                list.id == currentId
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(
                list.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                l.shoppingBoughtOf(
                  list.itemCount - list.remaining,
                  list.itemCount,
                ),
              ),
              onTap: () => Navigator.pop(context, list.id),
              trailing: PopupMenuButton<String>(
                tooltip: l.moreActions,
                onSelected: (v) {
                  switch (v) {
                    case 'rename':
                      _rename(context, ref, list);
                    case 'delete':
                      _delete(context, ref, list);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(l.shoppingRenameList),
                  ),
                  PopupMenuItem(value: 'delete', child: Text(l.delete)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          BepButton(
            label: l.shoppingNewList,
            kind: BepButtonKind.outlined,
            icon: Icons.add,
            onPressed: () => _create(context, ref),
          ),
        ],
      ),
    );
  }
}

/// SCR-29: thêm món bằng tay, gợi ý khi gõ, "Món hay mua" một chạm. Bảng ở
/// lại sau khi thêm để thêm nhanh nhiều món.
class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({required this.listId});

  final int listId;

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  List<KnownItem> _suggestions = const [];

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _suggest(String text) async {
    final list = await ref.read(shoppingRepositoryProvider).suggest(text);
    if (!mounted || _controller.text != text) return;
    setState(() => _suggestions = list);
  }

  Future<void> _add(String text) async {
    final l = AppLocalizations.of(context);
    if (text.trim().isEmpty) return;
    try {
      final result = await ref
          .read(shoppingRepositoryProvider)
          .addText(widget.listId, text);
      if (!mounted) return;
      _controller.clear();
      setState(() => _suggestions = const []);
      _focus.requestFocus();
      showBepSnackBar(l.shoppingAdded(result.added + result.merged));
    } on ShoppingException catch (e) {
      if (!mounted) return;
      showMessage(_shoppingError(l, e.problem));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final frequent =
        ref.watch(frequentItemsProvider).value ?? const <KnownItem>[];
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
                  l.shoppingAddItem,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.done),
              ),
            ],
          ),
          TextField(
            controller: _controller,
            focusNode: _focus,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l.shoppingAddItem,
              hintText: l.shoppingItemHint,
              suffixIcon: IconButton(
                tooltip: l.add,
                icon: const Icon(Icons.add),
                onPressed: () => _add(_controller.text),
              ),
            ),
            onChanged: _suggest,
            onSubmitted: _add,
          ),
          if (_suggestions.isNotEmpty)
            for (final item in _suggestions)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.search, size: 20),
                title: Text(item.name),
                onTap: () {
                  _controller.text = item.name;
                  _controller.selection = TextSelection.collapsed(
                    offset: item.name.length,
                  );
                  _focus.requestFocus();
                  setState(() => _suggestions = const []);
                },
              ),
          if (frequent.isNotEmpty) ...[
            NotebookTabHeader(l.shoppingFrequent),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final item in frequent)
                    ActionChip(
                      label: Text(item.name),
                      onPressed: () => _add(item.name),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
