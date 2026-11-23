import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/data_providers_v3.dart';
import '../../data/meal_plan_repository.dart';
import '../../ui/ui.dart';

/// SCR-42: các bữa trong ngày (AC-38). Thêm, đổi tên, xoá và sắp lại thứ tự;
/// xoá bữa đang có món thì hỏi trước.
class MealSlotsScreen extends ConsumerWidget {
  const MealSlotsScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final name = await _askText(
      context,
      title: l.menuAddSlot,
      label: l.menuSlotName,
      maxLength: maxMealSlotName,
    );
    if (name == null || !context.mounted) return;
    try {
      await ref.read(mealPlanRepositoryProvider).addSlot(name);
    } on MealPlanException catch (e) {
      if (!context.mounted) return;
      showMessage(_error(l, e.problem));
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    MealSlot slot,
  ) async {
    final l = AppLocalizations.of(context);
    final name = await _askText(
      context,
      title: l.menuSlotName,
      label: l.menuSlotName,
      initial: slot.name,
      maxLength: maxMealSlotName,
    );
    if (name == null || !context.mounted) return;
    try {
      await ref.read(mealPlanRepositoryProvider).renameSlot(slot.id, name);
    } on MealPlanException catch (e) {
      if (!context.mounted) return;
      showMessage(_error(l, e.problem));
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MealSlot slot,
  ) async {
    final l = AppLocalizations.of(context);
    final uses = await ref
        .read(mealPlanRepositoryProvider)
        .countSlotUses(slot.id);
    if (!context.mounted) return;
    final ok = await showConfirmDialog(
      context,
      title: l.menuDeleteSlotTitle(slot.name),
      body: uses == 0
          ? l.menuDeleteSlotBody
          : '${l.menuDeleteSlotBody}\n\n${l.menuSlotUses(uses)}',
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await ref.read(mealPlanRepositoryProvider).deleteSlot(slot.id);
  }

  Future<void> _reorder(
    WidgetRef ref,
    List<MealSlot> slots,
    int from,
    int to,
  ) async {
    final ids = [for (final s in slots) s.id];
    final id = ids.removeAt(from);
    ids.insert(to, id);
    await ref.read(mealPlanRepositoryProvider).reorderSlots(ids);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final startup = ref.watch(v3StartupProvider);
    if (startup.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.menuMealSlots)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.menuMealSlots)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'mealSlotsFab',
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.menuAddSlot),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        buildDefaultDragHandles: false,
        itemCount: slots.length,
        onReorderItem: (from, to) => _reorder(ref, slots, from, to),
        itemBuilder: (context, index) {
          final slot = slots[index];
          return ListTile(
            key: ValueKey(slot.id),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            title: Text(slot.name),
            onTap: () => _rename(context, ref, slot),
            trailing: PopupMenuButton<String>(
              tooltip: l.moreActions,
              onSelected: (v) {
                switch (v) {
                  case 'rename':
                    _rename(context, ref, slot);
                  case 'delete':
                    _delete(context, ref, slot);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'rename', child: Text(l.edit)),
                PopupMenuItem(value: 'delete', child: Text(l.delete)),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _error(AppLocalizations l, MealPlanProblem problem) => switch (problem) {
  MealPlanProblem.emptyName => l.nameRequired,
  MealPlanProblem.nameTooLong => l.nameTooLong,
  MealPlanProblem.emptyEntry => l.nameRequired,
  MealPlanProblem.notFound => l.notFound,
};

Future<String?> _askText(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  int maxLength = 30,
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
