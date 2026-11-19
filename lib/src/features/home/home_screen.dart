import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../ui/ui.dart';
import '../exchange/exchange_actions.dart';
import 'recipe_list.dart';

/// Gốc tab "Công thức" (SCR-02, AC-01). Thanh dưới 5 mục do khung ứng dụng
/// dựng; màn này lo danh sách, nút "+", bảng thêm và chế độ chọn nhiều.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// null = không ở chế độ chọn.
  Set<int>? _selected;

  void _startSelection([int? id]) {
    setState(() => _selected = id == null ? <int>{} : {id});
  }

  void _exitSelection() => setState(() => _selected = null);

  void _toggle(int id) {
    final selected = _selected;
    if (selected == null) {
      _startSelection(id);
      return;
    }
    setState(() {
      if (!selected.remove(id)) selected.add(id);
      if (selected.isEmpty) _selected = null;
    });
  }

  void _longPress(int id) {
    if (id < 0) {
      _startSelection();
    } else if (_selected == null) {
      _startSelection(id);
    }
  }

  void _selectAll(List<int> ids) {
    setState(() => _selected = ids.toSet());
  }

  Future<void> _trashSelected(List<int> ids) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(recipeRepositoryProvider);
    final ok = await showConfirmDialog(
      context,
      title: l.trashSelected,
      body: l.trashedCount(ids.length),
      confirmLabel: l.trashSelected,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    for (final id in ids) {
      await repo.moveToTrash(id);
    }
    _exitSelection();
    showUndoSnackBar(
      message: l.trashedCount(ids.length),
      undoLabel: l.undo,
      onUndo: () {
        for (final id in ids) {
          repo.restore(id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = _selected;
    final recipes = ref.watch(recipesProvider).value ?? const [];
    final ids = selected == null
        ? const <int>[]
        : [
            for (final r in recipes)
              if (selected.contains(r.id)) r.id,
          ];

    return Scaffold(
      appBar: selected == null
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              leading: IconButton(
                tooltip: l.exitSelection,
                icon: const Icon(Icons.close),
                onPressed: _exitSelection,
              ),
              title: Text(l.selectedCount(selected.length)),
              actions: [
                TextButton(
                  onPressed: () => _selectAll([for (final r in recipes) r.id]),
                  child: Text(l.selectAll),
                ),
              ],
            ),
      body: SafeArea(
        top: selected == null,
        child: Column(
          children: [
            Expanded(
              child: RecipeListTab(
                selected: selected,
                onToggle: _toggle,
                onLongPress: _longPress,
              ),
            ),
            if (selected != null)
              _SelectionBar(
                hasSelection: ids.isNotEmpty,
                onShare: ids.isEmpty
                    ? null
                    : () => exportRecipesJson(context, ref, ids),
                onExportJson: ids.isEmpty
                    ? null
                    : () => exportRecipesJson(context, ref, ids),
                onCookbook: ids.isEmpty
                    ? null
                    : () => makeCookbook(context, ref, ids),
                onTrash: ids.isEmpty ? null : () => _trashSelected(ids),
              ),
          ],
        ),
      ),
      floatingActionButton: selected == null
          ? FloatingActionButton(
              tooltip: l.addRecipe,
              onPressed: () => _showAddSheet(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  /// Bảng chọn cách thêm công thức (SCR-03, AC-01).
  void _showAddSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l.addRecipe,
                  style: Theme.of(sheet).textTheme.headlineSmall,
                ),
              ),
              _AddCard(
                icon: Icons.edit_note,
                title: l.addManual,
                subtitle: l.addSheetManualSub,
                onTap: () {
                  Navigator.pop(sheet);
                  context.push('/recipe/new');
                },
              ),
              const SizedBox(height: 8),
              _AddCard(
                icon: Icons.public,
                title: l.fromWeb,
                subtitle: l.addSheetWebSub,
                tag: l.needsInternet,
                onTap: () {
                  Navigator.pop(sheet);
                  context.push('/web');
                },
              ),
              const SizedBox(height: 8),
              _AddCard(
                icon: Icons.document_scanner_outlined,
                title: l.scanPhoto,
                subtitle: l.addSheetScanSub,
                onTap: () {
                  Navigator.pop(sheet);
                  context.push('/scan');
                },
              ),
              const SizedBox(height: 8),
              _AddCard(
                icon: Icons.file_open_outlined,
                title: l.importFile,
                subtitle: l.addSheetImportSub,
                onTap: () {
                  Navigator.pop(sheet);
                  context.push('/import');
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Theme.of(sheet).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l.addSheetTip,
                      style: Theme.of(sheet).textTheme.bodySmall!.copyWith(
                        color: Theme.of(sheet).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tag,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BepRadius.circular(BepRadius.md),
                ),
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (tag != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: BepTag(tag!, tone: BepTone.info),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thanh hành động khi đang chọn nhiều công thức (SCR-06).
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.hasSelection,
    required this.onShare,
    required this.onExportJson,
    required this.onCookbook,
    required this.onTrash,
  });

  final bool hasSelection;
  final VoidCallback? onShare;
  final VoidCallback? onExportJson;
  final VoidCallback? onCookbook;
  final VoidCallback? onTrash;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _Action(
                icon: Icons.share_outlined,
                label: l.shareRecipe,
                onPressed: onShare,
              ),
              _Action(
                icon: Icons.data_object,
                label: l.exportJson,
                onPressed: onExportJson,
              ),
              _Action(
                icon: Icons.menu_book_outlined,
                label: l.cookbookMake,
                onPressed: onCookbook,
              ),
              _Action(
                icon: Icons.delete_outline,
                label: l.trashSelected,
                onPressed: onTrash,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).disabledColor;
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall!.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
