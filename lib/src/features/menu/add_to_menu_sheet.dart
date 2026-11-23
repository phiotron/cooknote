import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/data_providers_v3.dart';
import '../../data/meal_plan_repository.dart';
import '../../data/recipe_query.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/ui.dart';

/// ĐIỂM NỐI CỐ ĐỊNH (F0): "Thêm vào thực đơn" (SCR-37). G1 gọi từ chi tiết công thức với
/// [recipeId]; G5 thay ruột (giữ chữ ký). [date] dạng `YYYY-MM-DD` và [slotId] điền sẵn
/// ngày/bữa khi mở từ một ô của lịch; null thì người dùng chọn trong bảng.
Future<void> showAddToMenuSheet(
  BuildContext context,
  int recipeId, {
  String? date,
  int? slotId,
}) => _show(context, recipeId: recipeId, date: date, slotId: slotId);

/// Mở bảng SCR-37 không chọn sẵn công thức (nút "Thêm vào thực đơn" của lịch).
Future<void> showNewMenuEntrySheet(
  BuildContext context, {
  String? date,
  int? slotId,
}) => _show(context, date: date, slotId: slotId);

Future<void> _show(
  BuildContext context, {
  int? recipeId,
  String? date,
  int? slotId,
}) => showBepSheet<void>(
  context,
  builder: (_) =>
      _AddToMenuSheet(recipeId: recipeId, date: date, slotId: slotId),
);

class _AddToMenuSheet extends ConsumerStatefulWidget {
  const _AddToMenuSheet({this.recipeId, this.date, this.slotId});

  final int? recipeId;
  final String? date;
  final int? slotId;

  @override
  ConsumerState<_AddToMenuSheet> createState() => _AddToMenuSheetState();
}

class _AddToMenuSheetState extends ConsumerState<_AddToMenuSheet> {
  late DateTime _date;
  late final TextEditingController _search;
  late final TextEditingController _text;
  int _tab = 0;
  int? _slotId;
  int? _pickedRecipeId;
  int _servings = 4;
  List<RecipeSummary> _results = const [];
  String _query = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _date = _parse(widget.date) ?? _today();
    _slotId = widget.slotId;
    _pickedRecipeId = widget.recipeId;
    _search = TextEditingController();
    _text = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(v3StartupProvider.future).then((_) => _load(''));
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _text.dispose();
    super.dispose();
  }

  DateTime _today() {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime? _parse(String? key) {
    if (key == null) return null;
    final d = DateTime.tryParse(key);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  Future<void> _load(String text) async {
    final list = await ref
        .read(recipeRepositoryProvider)
        .search(RecipeQuery(text: text));
    if (!mounted || _query != text) return;
    setState(() => _results = list.take(12).toList());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final slotId = _slotId;
    if (slotId == null || _busy) return;
    final repo = ref.read(mealPlanRepositoryProvider);
    setState(() => _busy = true);
    try {
      if (_tab == 0) {
        final id = _pickedRecipeId;
        if (id == null) return;
        await repo.addRecipe(_date, slotId, id, servings: _servings.toDouble());
      } else {
        final text = _text.text.trim();
        if (text.isEmpty) return;
        await repo.addText(_date, slotId, text);
      }
      if (!mounted) return;
      Navigator.pop(context);
      showBepSnackBar(l.menuEntryAdded);
    } on MealPlanException catch (e) {
      if (!mounted) return;
      showMessage(_error(l, e.problem));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _error(AppLocalizations l, MealPlanProblem problem) =>
      switch (problem) {
        MealPlanProblem.emptyName => l.nameRequired,
        MealPlanProblem.nameTooLong => l.nameTooLong,
        MealPlanProblem.emptyEntry => l.nameRequired,
        MealPlanProblem.notFound => l.notFound,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    final slotId = slots.any((s) => s.id == _slotId)
        ? _slotId
        : (slots.isEmpty ? null : slots.first.id);
    final initialName = widget.recipeId == null
        ? null
        : ref.watch(recipeProvider(widget.recipeId!)).value?.draft.name;
    final canAdd =
        slotId != null &&
        (_tab == 0 ? _pickedRecipeId != null : _text.text.trim().isNotEmpty);

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
                  l.menuAddTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.cancel),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 0, label: Text(l.menuTabRecipe)),
              ButtonSegment(value: 1, label: Text(l.menuTabFreeText)),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(l.menuDate),
            subtitle: Text(_mediumDate(context, _date)),
            onTap: _pickDate,
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: slotId,
                  decoration: InputDecoration(labelText: l.menuSlot),
                  items: [
                    for (final s in slots)
                      DropdownMenuItem(value: s.id, child: Text(s.name)),
                  ],
                  onChanged: (v) => setState(() => _slotId = v),
                ),
              ),
              const SizedBox(width: 12),
              _ServingsStepper(
                label: l.menuServings,
                value: _servings,
                onChanged: (v) => setState(() => _servings = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_tab == 0) ...[
            if (widget.recipeId != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(initialName ?? l.notFound),
                trailing: const Icon(Icons.check_circle),
              )
            else ...[
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: l.menuSearchRecipes,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) {
                  _query = v;
                  _load(v);
                },
              ),
              if (_results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l.menuNoRecipes,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                if (_query.trim().isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 2),
                    child: Text(
                      l.menuRecentFavourites,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                for (final r in _results)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _pickedRecipeId == r.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(
                      r.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: r.categoryName == null
                        ? null
                        : Text(r.categoryName!),
                    trailing: r.favorite
                        ? const Icon(Icons.bookmark, size: 20)
                        : null,
                    onTap: () => setState(() => _pickedRecipeId = r.id),
                  ),
              ],
            ],
          ] else
            TextField(
              controller: _text,
              autofocus: true,
              maxLength: maxFreeText,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.menuTabFreeText,
                hintText: l.menuFreeTextHint,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => canAdd ? _add() : null,
            ),
          const SizedBox(height: 8),
          BepButton(
            block: true,
            label: l.add,
            onPressed: canAdd && !_busy ? _add : null,
          ),
        ],
      ),
    );
  }
}

class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '−',
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$value', style: theme.textTheme.titleMedium),
            IconButton(
              tooltip: '+',
              onPressed: value < 99 ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}

String _mediumDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatMediumDate(d);
