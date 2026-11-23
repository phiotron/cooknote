import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/aisle_repository.dart';
import '../../data/data_providers_v3.dart';
import '../../ui/ui.dart';

/// Quản lý khu vực đi chợ (SCR-31, AC-36): thêm, đổi tên, xóa, sắp theo
/// đường đi trong cửa hàng. Kéo thả hoặc dùng nút lên/xuống cho trình đọc
/// màn hình.
class AislesScreen extends ConsumerWidget {
  const AislesScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final name = await _askName(
      context,
      title: l.shoppingAddAisle,
      label: l.shoppingAisleName,
    );
    if (name == null || !context.mounted) return;
    await _run(context, () => ref.read(aisleRepositoryProvider).add(name));
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Aisle aisle) async {
    final l = AppLocalizations.of(context);
    final name = await _askName(
      context,
      title: l.shoppingAisleRename,
      label: l.shoppingAisleName,
      initial: aisle.name,
    );
    if (name == null || !context.mounted) return;
    await _run(
      context,
      () => ref.read(aisleRepositoryProvider).rename(aisle.id, name),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Aisle aisle) async {
    final l = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l.shoppingAisleDeleteTitle(aisle.name),
      body: l.shoppingAisleDeleteBody,
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await ref.read(aisleRepositoryProvider).delete(aisle.id);
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    List<Aisle> aisles,
    int from,
    int to,
  ) async {
    if (to < 0 || to >= aisles.length) return;
    final ids = [for (final a in aisles) a.id];
    ids.insert(to, ids.removeAt(from));
    await ref.read(aisleRepositoryProvider).reorder(ids);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final aisles = ref.watch(aislesProvider).value ?? const <Aisle>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.shoppingAisles)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.shoppingAddAisle),
      ),
      body: aisles.isEmpty
          ? EmptyState(
              illustration: BepIllo.basket,
              title: l.shoppingAddAisle,
              body: l.shoppingAislesHint,
              actions: [
                BepButton(
                  label: l.shoppingAddAisle,
                  icon: Icons.add,
                  onPressed: () => _add(context, ref),
                ),
              ],
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              buildDefaultDragHandles: false,
              itemCount: aisles.length,
              onReorderItem: (from, to) {
                _move(context, ref, aisles, from, to);
              },
              header: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  l.shoppingAislesHint,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l.shoppingAislesNote,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              itemBuilder: (context, i) {
                final aisle = aisles[i];
                return ListTile(
                  key: ValueKey(aisle.id),
                  minTileHeight: 56,
                  leading: ReorderableDragStartListener(
                    index: i,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.drag_indicator),
                    ),
                  ),
                  title: Text(aisle.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l.moveUp,
                        onPressed: i == 0
                            ? null
                            : () => _move(context, ref, aisles, i, i - 1),
                        icon: const Icon(Icons.keyboard_arrow_up),
                      ),
                      IconButton(
                        tooltip: l.moveDown,
                        onPressed: i == aisles.length - 1
                            ? null
                            : () => _move(context, ref, aisles, i, i + 1),
                        icon: const Icon(Icons.keyboard_arrow_down),
                      ),
                      PopupMenuButton<String>(
                        tooltip: l.moreActions,
                        onSelected: (v) {
                          if (v == 'rename') {
                            _rename(context, ref, aisle);
                          } else if (v == 'delete') {
                            _delete(context, ref, aisle);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(l.shoppingAisleRename),
                          ),
                          PopupMenuItem(value: 'delete', child: Text(l.delete)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final l = AppLocalizations.of(context);
    try {
      await action();
    } on AisleException catch (e) {
      if (!context.mounted) return;
      showMessage(switch (e.problem) {
        AisleProblem.emptyName => l.nameRequired,
        AisleProblem.nameTooLong => l.nameTooLong,
        AisleProblem.notFound => l.notFound,
      });
    }
  }
}

/// Hộp nhập tên khu vực; trả về null nếu hủy.
Future<String?> _askName(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
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
        maxLength: maxAisleName,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
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
