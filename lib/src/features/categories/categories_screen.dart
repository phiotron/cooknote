import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/category_repository.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';

/// Quản lý danh mục: thêm, đổi tên, xóa, kéo sắp xếp, lồng tối đa 3 cấp
/// (AC-10).
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(categoriesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.categories)),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addCategory,
        onPressed: () => _add(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: all.isEmpty
          ? Center(child: Text(l.categoriesEmpty))
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
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

Future<void> _add(BuildContext context, WidgetRef ref, Category? parent) async {
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
    final repo = ref.read(categoryRepositoryProvider);
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
        return Column(
          key: ValueKey(c.id),
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(
                left: 16.0 + (c.depth - 1) * 24,
                right: 4,
              ),
              minTileHeight: 56,
              leading: ReorderableDragStartListener(
                index: i,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.drag_handle),
                ),
              ),
              title: Text(c.name),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  switch (v) {
                    case 'sub':
                      await _add(context, ref, c);
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
                          title: Text(l.deleteCategory),
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
                    PopupMenuItem(value: 'sub', child: Text(l.addSubCategory)),
                  PopupMenuItem(value: 'rename', child: Text(l.renameCategory)),
                  PopupMenuItem(value: 'delete', child: Text(l.delete)),
                ],
              ),
            ),
            _Group(all: all, parentId: c.id),
          ],
        );
      },
    );
  }
}
