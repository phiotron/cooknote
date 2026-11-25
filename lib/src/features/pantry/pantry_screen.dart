import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/aisle_repository.dart';
import '../../data/data_providers_v3.dart';
import '../../data/pantry_repository.dart';
import '../../data/text_normalize.dart';
import '../../providers.dart';
import '../../pantry/expiry.dart';
import '../../ui/ui.dart';

/// Gốc tab Tủ bếp (SCR-43/44, AC-42/AC-43): lọc theo hạn dùng, nhóm theo khu
/// vực, chạm một món để sửa. Bảng thêm/sửa món nằm trong file này.
class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  PantryFilter _filter = PantryFilter.all;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _edit(PantryItem? item) =>
      showBepSheet<void>(context, builder: (_) => _PantryItemSheet(item: item));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final startup = ref.watch(v3StartupProvider);
    if (startup.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.tabPantry)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final items =
        ref.watch(pantryItemsProvider(_filter)).value ?? const <PantryItem>[];
    final query = normalizeText(_query);
    final visible = query.isEmpty
        ? items
        : [
            for (final item in items)
              if (normalizeText(item.name).contains(query)) item,
          ];
    final counts =
        ref.watch(pantryExpiryCountsProvider).value ?? (soon: 0, expired: 0);
    final cookable = ref.watch(cookableProvider).value ?? const [];
    final aisles = ref.watch(aislesProvider).value ?? const <Aisle>[];
    final almost = cookable.where((c) => c.missingCount <= 3).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabPantry),
        actions: [
          IconButton(
            tooltip: l.pantryWhatCanICook,
            onPressed: () => context.push('/pantry/can-cook'),
            icon: const Icon(Icons.restaurant_menu),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pantryFab',
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add),
        label: Text(l.pantryAdd),
      ),
      body: _filter == PantryFilter.all && items.isEmpty
          ? EmptyState(
              illustration: BepIllo.jar,
              title: l.pantryEmpty,
              body: l.pantryEmptyBody,
              actions: [
                BepButton(
                  label: l.pantryAdd,
                  icon: Icons.add,
                  onPressed: () => _edit(null),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: Text(l.pantryWhatCanICook),
                    subtitle: Text(
                      cookable.isEmpty
                          ? l.pantryCanCookEmpty
                          : l.pantryAlmost(almost),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/pantry/can-cook'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: l.search,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l.clearSearch,
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: Text(l.pantryAll),
                        selected: _filter == PantryFilter.all,
                        onSelected: (_) =>
                            setState(() => _filter = PantryFilter.all),
                      ),
                      ChoiceChip(
                        label: Text(l.pantrySoon(counts.soon)),
                        selected: _filter == PantryFilter.soon,
                        onSelected: (_) =>
                            setState(() => _filter = PantryFilter.soon),
                      ),
                      ChoiceChip(
                        label: Text(l.pantryExpired(counts.expired)),
                        selected: _filter == PantryFilter.expired,
                        onSelected: (_) =>
                            setState(() => _filter = PantryFilter.expired),
                      ),
                    ],
                  ),
                ),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      l.pantryFilterEmpty,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                else
                  ..._groups(context, l, aisles, visible),
              ],
            ),
    );
  }

  List<Widget> _groups(
    BuildContext context,
    AppLocalizations l,
    List<Aisle> aisles,
    List<PantryItem> items,
  ) {
    final known = {for (final a in aisles) a.id};
    final byAisle = <int?, List<PantryItem>>{};
    for (final item in items) {
      byAisle.putIfAbsent(item.aisleId, () => []).add(item);
    }
    final out = <Widget>[];
    for (final aisle in aisles) {
      final group = byAisle[aisle.id];
      if (group == null || group.isEmpty) continue;
      out.add(NotebookTabHeader(aisle.name, count: '${group.length}'));
      for (final item in group) {
        out.add(_row(context, l, item));
      }
    }
    final other = [
      for (final entry in byAisle.entries)
        if (!known.contains(entry.key)) ...entry.value,
    ];
    if (other.isNotEmpty) {
      out.add(NotebookTabHeader(l.shoppingNoAisle, count: '${other.length}'));
      for (final item in other) {
        out.add(_row(context, l, item));
      }
    }
    return out;
  }

  Widget _row(BuildContext context, AppLocalizations l, PantryItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final info = _expiryInfo(context, l, item);
    final amount = item.amountLabel(
      decimalComma: Localizations.localeOf(context).languageCode == 'vi',
    );
    return InkWell(
      onTap: () => _edit(item),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (amount.isNotEmpty)
              Text(
                amount,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            Text(item.name, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(info.icon, size: 16, color: info.color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    info.text,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: info.color,
                    ),
                  ),
                ),
                Text(
                  l.pantryBoughtOn(
                    MaterialLocalizations.of(context)
                        .formatShortMonthDay(item.purchasedOn),
                  ),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({String text, IconData icon, Color color}) _expiryInfo(
    BuildContext context,
    AppLocalizations l,
    PantryItem item,
  ) {
    final cs = Theme.of(context).colorScheme;
    final expires = item.expiresOn;
    if (expires == null) {
      return (
        text: l.pantryNoExpiry,
        icon: Icons.event_busy_outlined,
        color: cs.onSurfaceVariant,
      );
    }
    final left = daysLeft(expires, _today);
    if (left < 0) {
      return (
        text: l.pantryExpiredAgo(-left),
        icon: Icons.error_outline,
        color: context.bep.expired,
      );
    }
    if (left <= soonDays) {
      return (
        text: left == 0 ? l.pantryToday : l.pantryExpiresIn(left),
        icon: Icons.warning_amber_rounded,
        color: context.bep.expiringSoon,
      );
    }
    return (
      text: left <= 14
          ? l.pantryExpiresIn(left)
          : l.pantryExpiresOn(
              MaterialLocalizations.of(context).formatMonthYear(expires),
            ),
      icon: Icons.schedule,
      color: cs.onSurfaceVariant,
    );
  }
}

class _PantryItemSheet extends ConsumerStatefulWidget {
  const _PantryItemSheet({this.item});

  final PantryItem? item;

  @override
  ConsumerState<_PantryItemSheet> createState() => _PantryItemSheetState();
}

class _PantryItemSheetState extends ConsumerState<_PantryItemSheet> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late int _aisleId;
  late DateTime _bought;
  DateTime? _expires;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _amount = TextEditingController(text: item?.amountText ?? '');
    _aisleId = item?.aisleId ?? -1;
    final now = ref.read(clockProvider)();
    _bought = item?.purchasedOn ?? DateTime(now.year, now.month, now.day);
    _expires = item?.expiresOn;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool bought}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: bought ? _bought : (_expires ?? _bought),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final d = DateTime(picked.year, picked.month, picked.day);
      if (bought) {
        _bought = d;
      } else {
        _expires = d;
      }
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_busy) return;
    setState(() => _busy = true);
    final draft = PantryDraft(
      name: _name.text,
      amount: _amount.text,
      aisleId: _aisleId < 0 ? null : _aisleId,
      purchasedOn: _bought,
      expiresOn: _expires,
    );
    final repo = ref.read(pantryRepositoryProvider);
    try {
      final item = widget.item;
      if (item == null) {
        await repo.add(draft);
      } else {
        await repo.update(item.id, draft);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } on PantryException catch (e) {
      if (!mounted) return;
      showMessage(switch (e.problem) {
        PantryProblem.emptyName => l.nameRequired,
        PantryProblem.nameTooLong => l.nameTooLong,
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final item = widget.item;
    if (item == null) return;
    final ok = await showConfirmDialog(
      context,
      title: l.pantryItemDeleteTitle,
      body: item.name,
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(pantryRepositoryProvider).delete(item.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final aisles = ref.watch(aislesProvider).value ?? const <Aisle>[];
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
                  widget.item == null ? l.pantryAdd : l.pantryItemTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.cancel),
              ),
            ],
          ),
          TextField(
            controller: _name,
            autofocus: widget.item == null,
            maxLength: maxPantryName,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.pantryName),
          ),
          TextField(
            controller: _amount,
            decoration: InputDecoration(labelText: l.pantryQuantity),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _aisleId,
            decoration: InputDecoration(labelText: l.pantryAisle),
            items: [
              DropdownMenuItem(value: -1, child: Text(l.shoppingNoAisle)),
              for (final a in aisles)
                DropdownMenuItem(value: a.id, child: Text(a.name)),
            ],
            onChanged: (v) => setState(() => _aisleId = v ?? -1),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(l.pantryBought),
            subtitle: Text(
              MaterialLocalizations.of(context).formatMediumDate(_bought),
            ),
            onTap: () => _pick(bought: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(l.pantryExpiry),
            subtitle: Text(
              _expires == null
                  ? l.pantryNoExpiry
                  : MaterialLocalizations.of(context)
                        .formatMediumDate(_expires!),
            ),
            onTap: () => _pick(bought: false),
            trailing: _expires == null
                ? null
                : IconButton(
                    tooltip: l.pantryNoExpiryShort,
                    onPressed: () => setState(() => _expires = null),
                    icon: const Icon(Icons.clear),
                  ),
          ),
          if (_expires != null && _expires!.isBefore(_bought))
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: context.bep.expiringSoon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.pantryExpiryBeforePurchase,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: context.bep.expiringSoon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          BepButton(
            block: true,
            label: l.save,
            onPressed: _busy ? null : _save,
          ),
          if (widget.item != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: BepButton(
                block: true,
                label: l.delete,
                kind: BepButtonKind.dangerText,
                onPressed: _delete,
              ),
            ),
        ],
      ),
    );
  }
}
