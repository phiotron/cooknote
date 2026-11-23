import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/data_providers_v3.dart';
import '../../data/meal_plan_repository.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// SCR-39: thực đơn mẫu (AC-39). Lưu tuần đang xem thành mẫu, áp mẫu vào một
/// ngày bắt đầu, hỏi Thay thế/Thêm khi bữa đích đã có món.
class MenuTemplatesScreen extends ConsumerStatefulWidget {
  const MenuTemplatesScreen({super.key});

  @override
  ConsumerState<MenuTemplatesScreen> createState() =>
      _MenuTemplatesScreenState();
}

class _MenuTemplatesScreenState extends ConsumerState<MenuTemplatesScreen> {
  Future<void> _createFromWeek() async {
    final l = AppLocalizations.of(context);
    final now = ref.read(clockProvider)();
    final weekStart = ref.read(weekStartProvider).value ?? DateTime.monday;
    final days = weekDates(now, weekStart: weekStart);
    final name = await _askText(
      context,
      title: l.menuTemplateSaveWeek,
      label: l.menuTemplateName,
      maxLength: maxTemplateName,
    );
    if (name == null || !mounted) return;
    try {
      await ref
          .read(mealPlanRepositoryProvider)
          .createTemplateFromRange(name, days.first, days.last);
      if (!mounted) return;
      showBepSnackBar(l.menuTemplateCreated);
    } on MealPlanException catch (e) {
      if (!mounted) return;
      showMessage(_error(l, e.problem));
    }
  }

  Future<void> _rename(MenuTemplateInfo template) async {
    final l = AppLocalizations.of(context);
    final name = await _askText(
      context,
      title: l.menuTemplates,
      label: l.menuTemplateName,
      initial: template.name,
      maxLength: maxTemplateName,
    );
    if (name == null || !mounted) return;
    try {
      await ref
          .read(mealPlanRepositoryProvider)
          .renameTemplate(template.id, name);
    } on MealPlanException catch (e) {
      if (!mounted) return;
      showMessage(_error(l, e.problem));
    }
  }

  Future<void> _delete(MenuTemplateInfo template) async {
    final l = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l.menuTemplateDeleteTitle(template.name),
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(mealPlanRepositoryProvider).deleteTemplate(template.id);
  }

  Future<void> _apply(MenuTemplateInfo template) => showBepSheet<void>(
    context,
    builder: (_) => _ApplySheet(template: template),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final startup = ref.watch(v3StartupProvider);
    if (startup.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.menuTemplates)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final templates = ref.watch(menuTemplatesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.menuTemplates)),
      floatingActionButton: templates.isEmpty
          ? null
          : FloatingActionButton.extended(
              heroTag: 'menuTemplatesFab',
              onPressed: _createFromWeek,
              icon: const Icon(Icons.add),
              label: Text(l.menuNewTemplate),
            ),
      body: templates.isEmpty
          ? EmptyState(
              illustration: BepIllo.calendar,
              title: l.menuNoTemplates,
              body: l.menuNoTemplatesBody,
              actions: [
                BepButton(
                  label: l.menuTemplateSaveWeek,
                  icon: Icons.bookmark_add_outlined,
                  onPressed: _createFromWeek,
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final t in templates)
                  Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: ListTile(
                      title: Text(
                        t.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(l.menuTemplateItems(t.entryCount, t.days)),
                      onTap: () => _apply(t),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _apply(t),
                            child: Text(l.apply),
                          ),
                          PopupMenuButton<String>(
                            tooltip: l.moreActions,
                            onSelected: (v) {
                              switch (v) {
                                case 'rename':
                                  _rename(t);
                                case 'delete':
                                  _delete(t);
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(l.edit),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ApplySheet extends ConsumerStatefulWidget {
  const _ApplySheet({required this.template});

  final MenuTemplateInfo template;

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  late DateTime _start;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    _start = DateTime(now.year, now.month, now.day);
  }

  Future<void> _apply() async {
    final l = AppLocalizations.of(context);
    if (_busy) return;
    setState(() => _busy = true);
    final repo = ref.read(mealPlanRepositoryProvider);
    try {
      final startDays = [_start];
      final occupied = await repo.occupiedTargets(
        widget.template.id,
        startDays,
      );
      var mode = TemplateApplyMode.add;
      if (occupied.isNotEmpty && mounted) {
        final choice = await _askOccupied(context, occupied);
        if (choice == null) return;
        mode = choice;
      }
      await repo.applyTemplate(widget.template.id, startDays, mode: mode);
      if (!mounted) return;
      Navigator.pop(context);
      showBepSnackBar(l.menuTemplateApplied);
    } on MealPlanException catch (e) {
      if (!mounted) return;
      showMessage(_error(l, e.problem));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final weekStart = ref.watch(weekStartProvider).value ?? DateTime.monday;
    final days = weekDates(_start, weekStart: weekStart);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.menuTemplateApplyTitle(widget.template.name),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l.menuTemplateItems(
              widget.template.entryCount,
              widget.template.days,
            ),
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(l.menuTemplateStartDate, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final d in days)
                ChoiceChip(
                  label: Text(_shortDate(context, d)),
                  selected: dateKey(d) == dateKey(_start),
                  onSelected: (_) => setState(() => _start = d),
                ),
            ],
          ),
          const SizedBox(height: 12),
          BepButton(
            block: true,
            label: l.apply,
            onPressed: _busy ? null : _apply,
          ),
        ],
      ),
    );
  }

  Future<TemplateApplyMode?> _askOccupied(
    BuildContext context,
    List<({String date, int slotId})> occupied,
  ) {
    final l = AppLocalizations.of(context);
    final first = occupied.first;
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(DateTime.parse(first.date));
    return showDialog<TemplateApplyMode>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.menuTemplateOccupiedTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.menuTemplateOccupiedBody(date, occupied.length)),
              const SizedBox(height: 8),
              Text(
                l.menuTemplateReplaceHint,
                style: Theme.of(dialog).textTheme.bodySmall!.copyWith(
                  color: Theme.of(dialog).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, TemplateApplyMode.add),
            child: Text(l.add),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, TemplateApplyMode.replace),
            child: Text(l.replace),
          ),
        ],
      ),
    );
  }
}

String _shortDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatShortMonthDay(d);

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
  int maxLength = 100,
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
