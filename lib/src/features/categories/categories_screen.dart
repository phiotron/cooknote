import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/category_repository.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// Quản lý danh mục: thêm, đổi tên, xóa, kéo sắp xếp, lồng tối đa 3 cấp
/// (AC-10, SCR-14).
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(categoriesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.categories)),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: l.addCategory,
        onPressed: () => addCategory(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(l.addCategory),
      ),
      body: all.isEmpty
          ? EmptyState(
              illustration: BepIllo.collect,
              title: l.categoriesEmpty,
              body: l.categoryEmptyBody,
              actions: [
                BepButton(
                  label: l.addCategory,
                  icon: Icons.add,
                  onPressed: () => addCategory(context, ref, null),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 96),
              children: [_Group(all: all, parentId: null)],
            ),
    );
  }
}

/// Hộp nhập tên danh mục; trả về null nếu hủy.
Future<String?> _askName(
  BuildContext context,
  String title, {
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
        maxLength: maxCategoryName,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l.categoryName),
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

Future<void> _run(BuildContext context, Future<void> Function() action) async {
  final l = AppLocalizations.of(context);
  try {
    await action();
  } on CategoryException catch (e) {
    showMessage(switch (e.problem) {
      CategoryProblem.tooDeep => l.categoryDepthLimit,
      _ => l.categoryNameInvalid,
    });
  }
}

/// Thêm danh mục cấp đầu ([parent] null) hoặc danh mục con của [parent].
Future<void> addCategory(
  BuildContext context,
  WidgetRef ref,
  Category? parent,
) async {
  final l = AppLocalizations.of(context);
  final repo = ref.read(categoryRepositoryProvider);
  final name = await _askName(
    context,
    parent == null ? l.addCategory : l.addSubCategory,
  );
  if (name == null || !context.mounted) return;
  await _run(context, () => repo.add(name, parentId: parent?.id));
}

/// Các danh mục con trực tiếp của [parentId], kéo để đổi thứ tự.
class _Group extends ConsumerWidget {
  const _Group({required this.all, required this.parentId});

  final List<Category> all;
  final int? parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final repo = ref.read(categoryRepositoryProvider);
    final counts = ref.watch(categoryCountsProvider).value ?? const {};
    final items = [
      for (final c in all)
        if (c.parentId == parentId) c,
    ];
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorderItem: (from, to) {
        final ids = [for (final c in items) c.id];
        ids.insert(to, ids.removeAt(from));
        repo.reorder(parentId, ids);
      },
      itemBuilder: (context, i) {
        final c = items[i];
        final top = c.depth == 1;
        return Column(
          key: ValueKey(c.id),
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(
                left: 8.0 + (c.depth - 1) * 40,
                right: 4,
              ),
              minTileHeight: 56,
              leading: ReorderableDragStartListener(
                index: i,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.drag_indicator),
                ),
              ),
              title: Row(
                children: [
                  if (!top)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '↳',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: top
                          ? theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            )
                          : theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${counts[c.id] ?? 0}',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: cs.onSurfaceVariant)
                        .tabular,
                  ),
                  PopupMenuButton<String>(
                    tooltip: l.moreActions,
                    onSelected: (v) async {
                      switch (v) {
                        case 'sub':
                          await addCategory(context, ref, c);
                        case 'rename':
                          final name = await _askName(
                            context,
                            l.renameCategory,
                            initial: c.name,
                          );
                          if (name != null && context.mounted) {
                            await _run(context, () => repo.rename(c.id, name));
                          }
                        case 'delete':
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (dialog) => AlertDialog(
                              title: Text(l.deleteCategoryTitle),
                              content: Text(l.deleteCategoryBody),
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
                          if (ok == true) await repo.delete(c.id);
                      }
                    },
                    itemBuilder: (_) => [
                      if (c.depth < maxCategoryDepth)
                        PopupMenuItem(
                          value: 'sub',
                          child: Text(l.addSubCategory),
                        ),
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(l.renameCategory),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l.deleteCategory),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant),
            _Group(all: all, parentId: c.id),
          ],
        );
      },
    );
  }
}
