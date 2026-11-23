import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/data_providers_v3.dart';
import '../../data/meal_plan_repository.dart';
import '../../data/shopping_repository.dart';
import '../../providers.dart';
import '../../ui/ui.dart';
import 'add_to_menu_sheet.dart';
import '../shopping/add_to_shopping_sheet.dart';

/// Gốc tab Thực đơn (SCR-34/35/36, AC-38..AC-41). Ba cách xem Ngày/Tuần/Tháng;
/// mỗi bữa là một ô nhận kéo thả, chạm một món để mở/nấu/đổi khẩu phần/chuyển/xoá.
/// Các bảng SCR-37 (thêm món), SCR-38 (chuyển món), SCR-41 (đi chợ theo khoảng)
/// nằm trong file này và `add_to_menu_sheet.dart`.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _view = 'week';
  DateTime _anchor = DateTime(2000);
  bool _inited = false;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  void _initFromQuery(BuildContext context) {
    if (_inited) return;
    _inited = true;
    _anchor = _today;
    final params = GoRouterState.of(context).uri.queryParameters;
    final view = params['view'];
    if (view == 'day' || view == 'week' || view == 'month') _view = view!;
    final date = DateTime.tryParse(params['date'] ?? '');
    if (date != null) {
      _anchor = DateTime(date.year, date.month, date.day);
    }
  }

  DateTime _gridStart(int weekStart) {
    final first = DateTime(_anchor.year, _anchor.month, 1);
    final back = (first.weekday - weekStart + 7) % 7;
    return DateTime(first.year, first.month, first.day - back);
  }

  ({DateTime from, DateTime to}) _range(int weekStart) {
    if (_view == 'month') {
      final start = _gridStart(weekStart);
      return (
        from: start,
        to: DateTime(start.year, start.month, start.day + 41),
      );
    }
    if (_view == 'day') return (from: _anchor, to: _anchor);
    final days = weekDates(_anchor, weekStart: weekStart);
    return (from: days.first, to: days.last);
  }

  void _shift(int delta) {
    setState(() {
      _anchor = switch (_view) {
        'month' => DateTime(_anchor.year, _anchor.month + delta, 1),
        'day' => DateTime(_anchor.year, _anchor.month, _anchor.day + delta),
        _ => DateTime(_anchor.year, _anchor.month, _anchor.day + delta * 7),
      };
    });
  }

  Future<void> _openEntry(
    PlanEntry entry,
    List<MealSlot> slots,
    int weekStart,
  ) async {
    final l = AppLocalizations.of(context);
    final action = await showBepSheet<String>(
      context,
      builder: (sheet) => _EntryActions(entry: entry),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case 'open':
        if (entry.recipeId != null) context.push('/recipe/${entry.recipeId}');
      case 'cook':
        if (entry.recipeId != null) context.push('/cook/${entry.recipeId}');
      case 'servings':
        await _editServings(entry);
      case 'edit':
        await _editText(entry);
      case 'move':
        await _moveEntry(entry, slots, weekStart);
      case 'remove':
        await _removeEntry(entry, l);
    }
  }

  Future<void> _editServings(PlanEntry entry) async {
    final initial = entry.servings ?? entry.recipeServings ?? 1;
    final value = await _askServings(context, initial);
    if (value == null || !mounted) return;
    await ref.read(mealPlanRepositoryProvider).setServings(entry.id, value);
  }

  Future<void> _editText(PlanEntry entry) async {
    final l = AppLocalizations.of(context);
    final text = await _askText(
      context,
      title: l.menuTabFreeText,
      label: l.menuTabFreeText,
      hint: l.menuFreeTextHint,
      initial: entry.freeText ?? '',
      maxLength: maxFreeText,
    );
    if (text == null || !mounted) return;
    try {
      await ref.read(mealPlanRepositoryProvider).setText(entry.id, text);
    } on MealPlanException catch (e) {
      if (!mounted) return;
      showMessage(_error(l, e.problem));
    }
  }

  Future<void> _moveEntry(
    PlanEntry entry,
    List<MealSlot> slots,
    int weekStart,
  ) async {
    final target = await showBepSheet<_MoveTarget>(
      context,
      builder: (_) =>
          _MoveSheet(entry: entry, slots: slots, weekStart: weekStart),
    );
    if (target == null || !mounted) return;
    await ref
        .read(mealPlanRepositoryProvider)
        .moveEntry(entry.id, date: target.date, slotId: target.slotId);
  }

  Future<void> _removeEntry(PlanEntry entry, AppLocalizations l) async {
    final ok = await showConfirmDialog(
      context,
      title: l.menuEntryRemove,
      body: entry.title,
      confirmLabel: l.remove,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(mealPlanRepositoryProvider).deleteEntry(entry.id);
    if (!mounted) return;
    showBepSnackBar(l.menuEntryRemoved);
  }

  Future<void> _addTo(DateTime date, int? slotId) =>
      showNewMenuEntrySheet(context, date: dateKey(date), slotId: slotId);

  Future<void> _saveWeekTemplate(int weekStart) async {
    final l = AppLocalizations.of(context);
    final days = weekDates(_anchor, weekStart: weekStart);
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

  Future<void> _openRangeShopping(int weekStart) async {
    final days = weekDates(_anchor, weekStart: weekStart);
    final candidates = await showBepSheet<List<ShoppingCandidate>>(
      context,
      builder: (_) =>
          _RangeShoppingSheet(weekFrom: days.first, weekTo: days.last),
    );
    if (candidates == null || !mounted) return;
    await showAddShoppingCandidatesSheet(context, candidates: candidates);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final startup = ref.watch(v3StartupProvider);
    if (startup.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.tabMenu)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    _initFromQuery(context);
    final weekStart = ref.watch(weekStartProvider).value ?? DateTime.monday;
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    final range = _range(weekStart);
    final entries =
        ref
            .watch(mealPlanRangeProvider((from: range.from, to: range.to)))
            .value ??
        const <PlanEntry>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabMenu),
        actions: [
          PopupMenuButton<String>(
            tooltip: l.moreActions,
            onSelected: (v) async {
              switch (v) {
                case 'random':
                  await context.push('/menu/random');
                case 'templates':
                  await context.push('/menu/templates');
                case 'shopping':
                  await _openRangeShopping(weekStart);
                case 'save':
                  await _saveWeekTemplate(weekStart);
                case 'slots':
                  await context.push('/settings/meal-slots');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'random', child: Text(l.menuRandom)),
              PopupMenuItem(
                value: 'templates',
                child: Text(l.menuApplyTemplate),
              ),
              PopupMenuItem(
                value: 'shopping',
                child: Text(l.menuAddToShopping),
              ),
              PopupMenuItem(value: 'save', child: Text(l.menuSaveWeekTemplate)),
              PopupMenuItem(value: 'slots', child: Text(l.menuMealSlots)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'menuFab',
        onPressed: () => _addTo(_anchor, null),
        icon: const Icon(Icons.add),
        label: Text(l.menuAddToMenu),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: _view == 'month'
            ? null
            : (d) {
                final v = d.primaryVelocity ?? 0;
                if (v < -120) {
                  _shift(1);
                } else if (v > 120) {
                  _shift(-1);
                }
              },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _viewSwitcher(),
            _rangeBar(l, weekStart, range),
            _quickActions(l, weekStart),
            if (_view == 'month')
              _monthGrid(context, l, weekStart, entries)
            else if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _view == 'day'
                          ? l.menuNothingPlannedDay
                          : l.menuNothingPlannedWeek,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.menuEmptyHint,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._daySections(context, l, weekStart, slots, entries),
          ],
        ),
      ),
    );
  }

  Widget _viewSwitcher() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: 'day',
            label: Text(AppLocalizations.of(context).menuDay),
          ),
          ButtonSegment(
            value: 'week',
            label: Text(AppLocalizations.of(context).menuWeek),
          ),
          ButtonSegment(
            value: 'month',
            label: Text(AppLocalizations.of(context).menuMonth),
          ),
        ],
        selected: {_view},
        onSelectionChanged: (s) => setState(() => _view = s.first),
      ),
    ),
  );

  Widget _rangeBar(
    AppLocalizations l,
    int weekStart,
    ({DateTime from, DateTime to}) range,
  ) {
    final label = switch (_view) {
      'month' => MaterialLocalizations.of(context).formatMonthYear(_anchor),
      'day' => _mediumDate(context, _anchor),
      _ => l.menuWeekRange(
        _shortDate(context, range.from),
        _shortDate(context, range.to),
      ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: l.back,
            onPressed: () => _shift(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _anchor = _today),
            child: Text(l.today),
          ),
          IconButton(
            tooltip: l.next,
            onPressed: () => _shift(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(AppLocalizations l, int weekStart) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ActionChip(
          avatar: const Icon(Icons.casino_outlined, size: 18),
          label: Text(l.menuRandom),
          onPressed: () => context.push('/menu/random'),
        ),
        ActionChip(
          avatar: const Icon(Icons.auto_awesome_outlined, size: 18),
          label: Text(l.menuApplyTemplate),
          onPressed: () => context.push('/menu/templates'),
        ),
        ActionChip(
          avatar: const Icon(Icons.shopping_basket_outlined, size: 18),
          label: Text(l.menuAddToShopping),
          onPressed: () => _openRangeShopping(weekStart),
        ),
        ActionChip(
          avatar: const Icon(Icons.bookmark_add_outlined, size: 18),
          label: Text(l.menuSaveWeekTemplate),
          onPressed: () => _saveWeekTemplate(weekStart),
        ),
      ],
    ),
  );

  List<Widget> _daySections(
    BuildContext context,
    AppLocalizations l,
    int weekStart,
    List<MealSlot> slots,
    List<PlanEntry> entries,
  ) {
    final days = _view == 'day'
        ? [_anchor]
        : weekDates(_anchor, weekStart: weekStart);
    final today = _today;
    final byDate = <String, List<PlanEntry>>{};
    for (final e in entries) {
      byDate.putIfAbsent(e.date, () => []).add(e);
    }
    final out = <Widget>[];
    for (final day in days) {
      final key = dateKey(day);
      final mine = byDate[key] ?? const <PlanEntry>[];
      final isToday = key == dateKey(today);
      out.add(
        NotebookTabHeader(
          _mediumDate(context, day),
          count: isToday ? l.today : '${mine.length}',
        ),
      );
      for (final slot in slots) {
        out.add(_slotBlock(context, l, day, slot, mine));
      }
    }
    return out;
  }

  Widget _slotBlock(
    BuildContext context,
    AppLocalizations l,
    DateTime day,
    MealSlot slot,
    List<PlanEntry> entries,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mine = [
      for (final e in entries)
        if (e.slotId == slot.id) e,
    ];
    return DragTarget<_EntryDrag>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) {
        ref
            .read(mealPlanRepositoryProvider)
            .moveEntry(d.data.entryId, date: day, slotId: slot.id);
      },
      builder: (context, candidate, rejected) {
        final highlight = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: BepMotion.of(context),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 4),
          decoration: BoxDecoration(
            color: highlight
                ? cs.primaryContainer.withValues(alpha: 0.45)
                : null,
            borderRadius: BepRadius.circular(BepRadius.md),
            border: Border.all(
              color: highlight ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      slot.name,
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.menuAddToMenu,
                    onPressed: () => _addTo(day, slot.id),
                    icon: const Icon(Icons.add, size: 20),
                  ),
                ],
              ),
              if (mine.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 8, 4),
                  child: Text(
                    highlight ? l.menuDropHere : '',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final entry in mine)
                  _EntryTile(
                    entry: entry,
                    onTap: () =>
                        _openEntry(entry, _slotsNow(), _weekStartNow()),
                    onAction: (a) => _entryAction(entry, a),
                  ),
            ],
          ),
        );
      },
    );
  }

  List<MealSlot> _slotsNow() => ref.read(mealSlotsProvider).value ?? const [];

  int _weekStartNow() => ref.read(weekStartProvider).value ?? DateTime.monday;

  Future<void> _entryAction(PlanEntry entry, String action) async {
    final l = AppLocalizations.of(context);
    switch (action) {
      case 'open':
        if (entry.recipeId != null) context.push('/recipe/${entry.recipeId}');
      case 'cook':
        if (entry.recipeId != null) context.push('/cook/${entry.recipeId}');
      case 'servings':
        await _editServings(entry);
      case 'edit':
        await _editText(entry);
      case 'move':
        await _moveEntry(entry, _slotsNow(), _weekStartNow());
      case 'remove':
        await _removeEntry(entry, l);
    }
  }

  Widget _monthGrid(
    BuildContext context,
    AppLocalizations l,
    int weekStart,
    List<PlanEntry> entries,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final start = _gridStart(weekStart);
    final counts = <String, int>{};
    for (final e in entries) {
      counts[e.date] = (counts[e.date] ?? 0) + 1;
    }
    final today = dateKey(_today);
    final narrow = MaterialLocalizations.of(context).narrowWeekdays;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      narrow[(((weekStart - 1) + i) % 7 + 1) % 7],
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final day = DateTime(start.year, start.month, start.day + index);
              final key = dateKey(day);
              final count = counts[key] ?? 0;
              final inMonth = day.month == _anchor.month;
              final isToday = key == today;
              return InkWell(
                borderRadius: BepRadius.circular(BepRadius.sm),
                onTap: () => setState(() {
                  _anchor = day;
                  _view = 'day';
                }),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday ? cs.primary : null,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${day.day}',
                          style: theme.textTheme.labelMedium!.copyWith(
                            color: isToday
                                ? cs.onPrimary
                                : inMonth
                                ? cs.onSurface
                                : cs.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (count > 0)
                        Text(
                          count > 3 ? '+$count' : '•' * count.clamp(1, 3),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: cs.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _mediumDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatMediumDate(d);

String _shortDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatShortMonthDay(d);

String _servingsText(double v) =>
    v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

String _error(AppLocalizations l, MealPlanProblem problem) => switch (problem) {
  MealPlanProblem.emptyName => l.nameRequired,
  MealPlanProblem.nameTooLong => l.nameTooLong,
  MealPlanProblem.emptyEntry => l.nameRequired,
  MealPlanProblem.notFound => l.notFound,
};

/// Một món trong lịch: chạm để mở bảng hành động, giữ lâu để kéo sang bữa khác.
class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.onTap,
    required this.onAction,
  });

  final PlanEntry entry;
  final VoidCallback onTap;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final servings = entry.servings ?? entry.recipeServings;
    final tile = InkWell(
      onTap: onTap,
      borderRadius: BepRadius.circular(BepRadius.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 0, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.drag_indicator,
                size: 18,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      decoration: entry.recipeInTrash
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (servings != null && entry.recipeId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: BepTag(
                        l.menuEntryServings(_servingsText(servings)),
                        icon: Icons.people_outline,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: l.moreActions,
              onSelected: onAction,
              itemBuilder: (_) => [
                if (entry.recipeId != null) ...[
                  PopupMenuItem(value: 'open', child: Text(l.menuEntryOpen)),
                  PopupMenuItem(value: 'cook', child: Text(l.menuEntryCook)),
                  PopupMenuItem(value: 'servings', child: Text(l.menuServings)),
                ] else
                  PopupMenuItem(value: 'edit', child: Text(l.edit)),
                PopupMenuItem(value: 'move', child: Text(l.menuEntryMove)),
                PopupMenuItem(value: 'remove', child: Text(l.menuEntryRemove)),
              ],
            ),
          ],
        ),
      ),
    );
    return LongPressDraggable<_EntryDrag>(
      data: _EntryDrag(entry.id),
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(entry.title),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      child: tile,
    );
  }
}

class _EntryDrag {
  const _EntryDrag(this.entryId);

  final int entryId;
}

class _EntryActions extends StatelessWidget {
  const _EntryActions({required this.entry});

  final PlanEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasRecipe = entry.recipeId != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.title, style: theme.textTheme.headlineSmall),
          Text(
            '${_mediumDate(context, DateTime.parse(entry.date))} · '
            '${_slotName(context, entry.slotId)}',
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (hasRecipe) ...[
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(l.menuEntryOpen),
              onTap: () => Navigator.pop(context, 'open'),
            ),
            ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: Text(l.menuEntryCook),
              onTap: () => Navigator.pop(context, 'cook'),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(l.menuServings),
              onTap: () => Navigator.pop(context, 'servings'),
            ),
          ] else
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.edit),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(l.menuEntryMove),
            onTap: () => Navigator.pop(context, 'move'),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              l.menuEntryRemove,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => Navigator.pop(context, 'remove'),
          ),
        ],
      ),
    );
  }

  String _slotName(BuildContext context, int slotId) {
    final slots =
        ProviderScope.containerOf(context).read(mealSlotsProvider).value ??
        const <MealSlot>[];
    return slots.where((s) => s.id == slotId).firstOrNull?.name ?? '';
  }
}

class _MoveTarget {
  const _MoveTarget(this.date, this.slotId);

  final DateTime date;
  final int slotId;
}

/// SCR-38: chọn ngày và bữa đích cho một món.
class _MoveSheet extends StatefulWidget {
  const _MoveSheet({
    required this.entry,
    required this.slots,
    required this.weekStart,
  });

  final PlanEntry entry;
  final List<MealSlot> slots;
  final int weekStart;

  @override
  State<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<_MoveSheet> {
  late DateTime _date;
  late int _slotId;

  @override
  void initState() {
    super.initState();
    final parsed = DateTime.parse(widget.entry.date);
    _date = DateTime(parsed.year, parsed.month, parsed.day);
    _slotId = widget.entry.slotId;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final days = weekDates(_date, weekStart: widget.weekStart);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.menuMoveTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l.menuMoveDay, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final d in days)
                ChoiceChip(
                  label: Text(_shortDate(context, d)),
                  selected: dateKey(d) == dateKey(_date),
                  onSelected: (_) => setState(() => _date = d),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _slotId,
            decoration: InputDecoration(labelText: l.menuMoveMeal),
            items: [
              for (final s in widget.slots)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (v) => setState(() => _slotId = v ?? _slotId),
          ),
          const SizedBox(height: 12),
          BepButton(
            block: true,
            label: l.menuMove,
            onPressed: () =>
                Navigator.pop(context, _MoveTarget(_date, _slotId)),
          ),
        ],
      ),
    );
  }
}

/// SCR-41: chọn khoảng ngày rồi mở bảng chọn nguyên liệu.
class _RangeShoppingSheet extends ConsumerStatefulWidget {
  const _RangeShoppingSheet({required this.weekFrom, required this.weekTo});

  final DateTime weekFrom;
  final DateTime weekTo;

  @override
  ConsumerState<_RangeShoppingSheet> createState() =>
      _RangeShoppingSheetState();
}

class _RangeShoppingSheetState extends ConsumerState<_RangeShoppingSheet> {
  String _mode = 'week';
  late DateTime _from;
  late DateTime _to;
  List<ShoppingCandidate>? _candidates;
  bool _loading = true;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _from = widget.weekFrom;
    _to = widget.weekTo;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ref
        .read(mealPlanRepositoryProvider)
        .shoppingCandidates(_from, _to);
    if (!mounted) return;
    setState(() {
      _candidates = list;
      _loading = false;
    });
  }

  void _setMode(String mode) {
    setState(() {
      _mode = mode;
      if (mode == 'week') {
        _from = widget.weekFrom;
        _to = widget.weekTo;
      } else if (mode == 'next3') {
        _from = _today;
        _to = DateTime(_from.year, _from.month, _from.day + 2);
      }
    });
    _load();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final d = DateTime(picked.year, picked.month, picked.day);
      if (isFrom) {
        _from = d;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = d;
        if (_to.isBefore(_from)) _from = _to;
      }
      _mode = 'custom';
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final candidates = _candidates ?? const <ShoppingCandidate>[];
    final recipes = {for (final c in candidates) c.recipeId}.length;
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
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: Text(l.menuShoppingThisWeek),
                selected: _mode == 'week',
                onSelected: (_) => _setMode('week'),
              ),
              ChoiceChip(
                label: Text(l.menuShoppingNext3),
                selected: _mode == 'next3',
                onSelected: (_) => _setMode('next3'),
              ),
              ChoiceChip(
                label: Text(l.menuShoppingCustom),
                selected: _mode == 'custom',
                onSelected: (_) => _setMode('custom'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isFrom: true),
                  child: Text(
                    '${l.menuShoppingFrom}: ${_shortDate(context, _from)}',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isFrom: false),
                  child: Text(
                    '${l.menuShoppingTo}: ${_shortDate(context, _to)}',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l.shoppingNoIngredients),
            )
          else ...[
            Text(
              l.menuShoppingSummary(recipes, candidates.length),
              style: theme.textTheme.bodyLarge,
            ),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.menuShoppingAtServings,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BepButton(
              block: true,
              label: l.menuShoppingChoose,
              onPressed: () => Navigator.pop(context, candidates),
            ),
          ],
        ],
      ),
    );
  }
}

Future<double?> _askServings(BuildContext context, double initial) {
  final l = AppLocalizations.of(context);
  var value = initial < 1 ? 1.0 : initial;
  return showDialog<double>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setLocal) => AlertDialog(
        title: Text(l.menuServings),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: value > 1
                  ? () => setLocal(() => value = (value - 1).clamp(1, 99))
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _servingsText(value),
                style: Theme.of(dialog).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: value < 99
                  ? () => setLocal(() => value = value + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, value),
            child: Text(l.save),
          ),
        ],
      ),
    ),
  );
}

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
