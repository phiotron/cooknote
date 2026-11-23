import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/category_repository.dart';
import '../../data/data_providers_v3.dart';
import '../../data/meal_plan_repository.dart';
import '../../data/recipe_query.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// SCR-40: gợi ý ngẫu nhiên (AC-41). Lọc theo danh mục/thẻ/thời gian, xem
/// trước các ô còn trống của tuần rồi áp một lần.
class MenuRandomScreen extends ConsumerStatefulWidget {
  const MenuRandomScreen({super.key});

  @override
  ConsumerState<MenuRandomScreen> createState() => _MenuRandomScreenState();
}

class _MenuRandomScreenState extends ConsumerState<MenuRandomScreen> {
  final _categoryIds = <int>{};
  final _tags = <String>{};
  int? _maxMinutes;
  bool _busy = false;
  bool _previewing = false;
  bool _tooFew = false;
  List<MealAssignment> _suggestions = const [];
  Map<int, String> _names = const {};

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  List<DateTime> _days() => weekDates(
    _today,
    weekStart: ref.read(weekStartProvider).value ?? DateTime.monday,
  );

  Future<void> _preview() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final recipes = await ref
          .read(recipeRepositoryProvider)
          .search(
            RecipeQuery(
              categoryIds: _categoryIds,
              tags: _tags,
              maxTotalMinutes: _maxMinutes,
            ),
          );
      if (!mounted) return;
      if (recipes.isEmpty) {
        showMessage(l.menuRandomZero);
        return;
      }
      final days = _days();
      final repo = ref.read(mealPlanRepositoryProvider);
      final suggestions = await repo.suggest(
        dates: days,
        recipeIds: [for (final r in recipes) r.id],
      );
      final existing = await repo.getRange(days.first, days.last);
      final slots = ref.read(mealSlotsProvider).value ?? const <MealSlot>[];
      final occupied = {for (final e in existing) '${e.date}|${e.slotId}'}
          .length;
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _names = {for (final r in recipes) r.id: r.name};
        _tooFew = suggestions.length < days.length * slots.length - occupied;
        _previewing = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply() async {
    if (_suggestions.isEmpty) return;
    final l = AppLocalizations.of(context);
    await ref.read(mealPlanRepositoryProvider).applySuggestions(_suggestions);
    if (!mounted) return;
    showBepSnackBar(l.menuRandomApplied);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final startup = ref.watch(v3StartupProvider);
    if (startup.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.menuRandomTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.menuRandomTitle)),
      body: _previewing ? _buildPreview(context, l) : _buildFilters(context, l),
    );
  }

  Widget _buildFilters(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    final days = _days();
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final tags = ref.watch(tagsProvider).value ?? const <TagCount>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          l.menuRandomIntro(
            _shortDate(context, days.first),
            _shortDate(context, days.last),
          ),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        NotebookTabHeader(l.filterCategories),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in categories)
              FilterChip(
                label: Text(c.name),
                selected: _categoryIds.contains(c.id),
                onSelected: (on) => setState(() {
                  if (on) {
                    _categoryIds.add(c.id);
                  } else {
                    _categoryIds.remove(c.id);
                  }
                }),
              ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          NotebookTabHeader(l.filterTags),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final t in tags.take(10))
                FilterChip(
                  label: Text(t.tag),
                  selected: _tags.contains(t.tag),
                  onSelected: (on) => setState(() {
                    if (on) {
                      _tags.add(t.tag);
                    } else {
                      _tags.remove(t.tag);
                    }
                  }),
                ),
            ],
          ),
        ],
        NotebookTabHeader(l.filterMaxTime),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: Text(l.filterAny),
              selected: _maxMinutes == null,
              onSelected: (_) => setState(() => _maxMinutes = null),
            ),
            for (final m in const [30, 45, 60])
              ChoiceChip(
                label: Text(l.minutesShort(m)),
                selected: _maxMinutes == m,
                onSelected: (_) => setState(() => _maxMinutes = m),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: BepButton(
                label: l.cancel,
                kind: BepButtonKind.outlined,
                onPressed: () => context.pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BepButton(
                label: l.menuRandomPreview,
                onPressed: _busy ? null : _preview,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    final byDay = <String, List<MealAssignment>>{};
    for (final a in _suggestions) {
      byDay.putIfAbsent(a.date, () => []).add(a);
    }
    final dates = byDay.keys.toList()..sort();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(l.menuRandomPreviewTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          _tooFew ? l.menuRandomTooFew : l.menuRandomNoRepeat,
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (_suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l.menuRandomZero, style: theme.textTheme.bodyLarge),
          ),
        for (final date in dates) ...[
          NotebookTabHeader(
            MaterialLocalizations.of(context)
                .formatMediumDate(DateTime.parse(date)),
            count: '${byDay[date]!.length}',
          ),
          for (final a in byDay[date]!)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _slotName(slots, a.slotId),
                          style: theme.textTheme.labelMedium!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _names[a.recipeId] ?? '',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: BepTag(
                            l.menuRandomSuggested,
                            tone: BepTone.suggested,
                            icon: Icons.lightbulb_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: BepButton(
                label: l.cancel,
                kind: BepButtonKind.outlined,
                onPressed: () => setState(() => _previewing = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BepButton(
                label: l.apply,
                onPressed: _suggestions.isEmpty ? null : _apply,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _slotName(List<MealSlot> slots, int id) =>
      slots.where((s) => s.id == id).firstOrNull?.name ?? '';
}

String _shortDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatShortMonthDay(d);
