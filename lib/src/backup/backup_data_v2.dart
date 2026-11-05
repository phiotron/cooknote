import 'package:drift/drift.dart';

import '../data/database.dart';
import '../shopping/name_match.dart';
import 'backup_errors.dart';

/// Phần dữ liệu thêm ở định dạng 2 (docs/BACKUP-FORMAT.md): khu vực, danh
/// sách đi chợ, món đã biết, tủ bếp, bữa, lịch thực đơn, thực đơn mẫu.
/// Chỉ được THÊM khóa, không đổi nghĩa khóa cũ (AC-55).

/// Các khóa cài đặt thêm ở định dạng 2 đi theo bản sao lưu.
const portableSettingsV2 = [
  'weekStart',
  'unitSystem',
  'ignoreBasics',
  'shoppingToPantry',
];

/// Bảng dữ liệu người dùng của định dạng 2, theo thứ tự xóa an toàn (con
/// trước cha). Thay thế toàn bộ thì luôn xóa, kể cả khi file là định dạng 1.
List<TableInfo<Table, dynamic>> userTablesV2(AppDatabase db) => [
  db.shoppingItemSources,
  db.shoppingItems,
  db.shoppingLists,
  db.knownItems,
  db.pantryItems,
  db.mealPlanEntries,
  db.menuTemplateEntries,
  db.menuTemplates,
];

final _dateKey = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String _iso(DateTime t) => t.toUtc().toIso8601String();
String? _isoOrNull(DateTime? t) => t == null ? null : _iso(t);
DateTime _parse(Object? v) => DateTime.parse(v as String).toLocal();
DateTime? _timeOrNull(Object? v) => v == null ? null : _parse(v);
double? _num(Object? v) => (v as num?)?.toDouble();

T _need<T>(Map<String, Object?> m, String key) {
  final v = m[key];
  if (v is! T) {
    throw BackupException(BackupProblem.badData, 'thiếu hoặc sai "$key"');
  }
  return v;
}

List<Map<String, Object?>> _maps(Object? v, String what) {
  if (v == null) return const [];
  if (v is! List) throw BackupException(BackupProblem.badData, what);
  return [
    for (final e in v)
      if (e is Map<String, Object?>)
        e
      else
        throw BackupException(BackupProblem.badData, what),
  ];
}

String? _dateOrNull(Object? v, String what) {
  if (v == null) return null;
  if (v is! String || !_dateKey.hasMatch(v)) {
    throw BackupException(BackupProblem.badData, 'ngày sai ở "$what"');
  }
  return v;
}

String _date(Object? v, String what) =>
    _dateOrNull(v, what) ??
    (throw BackupException(BackupProblem.badData, 'thiếu "$what"'));

/// Xuất phần định dạng 2.
Future<Map<String, Object?>> exportDataV2(AppDatabase db) async {
  final aisles = await (db.select(
    db.aisles,
  )..orderBy([(a) => OrderingTerm.asc(a.id)])).get();
  final lists = await (db.select(
    db.shoppingLists,
  )..orderBy([(l) => OrderingTerm.asc(l.id)])).get();
  final items =
      await (db.select(db.shoppingItems)..orderBy([
            (i) => OrderingTerm.asc(i.listId),
            (i) => OrderingTerm.asc(i.position),
            (i) => OrderingTerm.asc(i.id),
          ]))
          .get();
  final sources = await (db.select(
    db.shoppingItemSources,
  )..orderBy([(s) => OrderingTerm.asc(s.id)])).get();
  final known = await (db.select(
    db.knownItems,
  )..orderBy([(k) => OrderingTerm.asc(k.nameKey)])).get();
  final pantry = await (db.select(
    db.pantryItems,
  )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
  final slots = await (db.select(
    db.mealSlots,
  )..orderBy([(s) => OrderingTerm.asc(s.id)])).get();
  final plan =
      await (db.select(db.mealPlanEntries)..orderBy([
            (e) => OrderingTerm.asc(e.date),
            (e) => OrderingTerm.asc(e.slotId),
            (e) => OrderingTerm.asc(e.position),
            (e) => OrderingTerm.asc(e.id),
          ]))
          .get();
  final templates = await (db.select(
    db.menuTemplates,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  final templateEntries =
      await (db.select(db.menuTemplateEntries)..orderBy([
            (e) => OrderingTerm.asc(e.templateId),
            (e) => OrderingTerm.asc(e.dayOffset),
            (e) => OrderingTerm.asc(e.slotId),
            (e) => OrderingTerm.asc(e.position),
            (e) => OrderingTerm.asc(e.id),
          ]))
          .get();

  return {
    'aisles': [
      for (final a in aisles)
        {'id': a.id, 'key': a.key, 'name': a.name, 'position': a.position},
    ],
    'shoppingLists': [
      for (final l in lists)
        {
          'id': l.id,
          'name': l.name,
          'position': l.position,
          'createdAt': _iso(l.createdAt),
          'items': [
            for (final i in items)
              if (i.listId == l.id)
                {
                  'name': i.name,
                  'quantity': i.quantity,
                  'unit': i.unit,
                  'unitText': i.unitText,
                  'amountText': i.amountText,
                  'note': i.note,
                  'aisleId': i.aisleId,
                  'checked': i.checked,
                  'checkedAt': _isoOrNull(i.checkedAt),
                  'position': i.position,
                  'sources': [
                    for (final s in sources)
                      if (s.itemId == i.id)
                        {'recipeId': s.recipeId, 'recipeName': s.recipeName},
                  ],
                },
          ],
        },
    ],
    'knownItems': [
      for (final k in known)
        {
          'name': k.name,
          'aisleId': k.aisleId,
          'useCount': k.useCount,
          'lastUsedAt': _isoOrNull(k.lastUsedAt),
          'favorite': k.favorite,
          'favoritePosition': k.favoritePosition,
        },
    ],
    'pantry': [
      for (final p in pantry)
        {
          'name': p.name,
          'quantity': p.quantity,
          'unit': p.unit,
          'unitText': p.unitText,
          'amountText': p.amountText,
          'aisleId': p.aisleId,
          'purchasedOn': p.purchasedOn,
          'expiresOn': p.expiresOn,
          'createdAt': _iso(p.createdAt),
        },
    ],
    'mealSlots': [
      for (final s in slots)
        {'id': s.id, 'key': s.key, 'name': s.name, 'position': s.position},
    ],
    'mealPlan': [
      for (final e in plan)
        {
          'date': e.date,
          'slotId': e.slotId,
          'recipeId': e.recipeId,
          'text': e.freeText,
          'servings': e.servings,
          'position': e.position,
        },
    ],
    'menuTemplates': [
      for (final t in templates)
        {
          'id': t.id,
          'name': t.name,
          'position': t.position,
          'createdAt': _iso(t.createdAt),
          'entries': [
            for (final e in templateEntries)
              if (e.templateId == t.id)
                {
                  'dayOffset': e.dayOffset,
                  'slotId': e.slotId,
                  'recipeId': e.recipeId,
                  'text': e.freeText,
                  'servings': e.servings,
                  'position': e.position,
                },
          ],
        },
    ],
  };
}

/// Nạp phần định dạng 2 khi THAY THẾ TOÀN BỘ, sau khi đã nạp công thức (id
/// công thức giữ nguyên nên tham chiếu còn đúng). Người gọi đã xóa
/// [userTablesV2] và chạy trong giao dịch.
///
/// Khu vực và bữa là cấu hình: file không có khóa đó (định dạng 1) thì giữ
/// khu vực và bữa đang có. Tham chiếu tới khu vực không còn thì món thành
/// "không khu vực"; món lịch/mẫu trỏ tới bữa hoặc công thức không có thì bỏ.
Future<void> importDataV2(AppDatabase db, Map<String, Object?> data) async {
  if (data.containsKey('aisles')) {
    await db.delete(db.aisles).go();
    for (final a in _maps(data['aisles'], 'aisles')) {
      await db
          .into(db.aisles)
          .insert(
            AislesCompanion.insert(
              id: Value(_need<int>(a, 'id')),
              key: Value(a['key'] as String?),
              name: _need<String>(a, 'name'),
              position: Value((a['position'] as int?) ?? 0),
            ),
          );
    }
  }
  if (data.containsKey('mealSlots')) {
    await db.delete(db.mealSlots).go();
    for (final s in _maps(data['mealSlots'], 'mealSlots')) {
      await db
          .into(db.mealSlots)
          .insert(
            MealSlotsCompanion.insert(
              id: Value(_need<int>(s, 'id')),
              key: Value(s['key'] as String?),
              name: _need<String>(s, 'name'),
              position: Value((s['position'] as int?) ?? 0),
            ),
          );
    }
  }

  final aisleIds = {for (final a in await db.select(db.aisles).get()) a.id};
  final slotIds = {for (final s in await db.select(db.mealSlots).get()) s.id};
  final recipeIds = {for (final r in await db.select(db.recipes).get()) r.id};
  int? aisle(Object? v) => v is int && aisleIds.contains(v) ? v : null;
  int? recipe(Object? v) => v is int && recipeIds.contains(v) ? v : null;

  for (final l in _maps(data['shoppingLists'], 'shoppingLists')) {
    final listId = await db
        .into(db.shoppingLists)
        .insert(
          ShoppingListsCompanion.insert(
            id: Value(_need<int>(l, 'id')),
            name: _need<String>(l, 'name'),
            position: Value((l['position'] as int?) ?? 0),
            createdAt: _parse(_need<String>(l, 'createdAt')),
          ),
        );
    for (final i in _maps(l['items'], 'items')) {
      final name = _need<String>(i, 'name');
      final itemId = await db
          .into(db.shoppingItems)
          .insert(
            ShoppingItemsCompanion.insert(
              listId: listId,
              name: name,
              nameKey: foldKey(name),
              quantity: Value(_num(i['quantity'])),
              unit: Value(i['unit'] as String?),
              unitText: Value((i['unitText'] as String?) ?? ''),
              amountText: Value(i['amountText'] as String?),
              note: Value(i['note'] as String?),
              aisleId: Value(aisle(i['aisleId'])),
              checked: Value((i['checked'] as bool?) ?? false),
              checkedAt: Value(_timeOrNull(i['checkedAt'])),
              position: Value((i['position'] as int?) ?? 0),
            ),
          );
      for (final s in _maps(i['sources'], 'sources')) {
        await db
            .into(db.shoppingItemSources)
            .insert(
              ShoppingItemSourcesCompanion.insert(
                itemId: itemId,
                recipeId: Value(recipe(s['recipeId'])),
                recipeName: _need<String>(s, 'recipeName'),
              ),
            );
      }
    }
  }

  for (final k in _maps(data['knownItems'], 'knownItems')) {
    final name = _need<String>(k, 'name');
    await db
        .into(db.knownItems)
        .insertOnConflictUpdate(
          KnownItemsCompanion.insert(
            nameKey: foldKey(name),
            name: name,
            aisleId: Value(aisle(k['aisleId'])),
            useCount: Value((k['useCount'] as int?) ?? 0),
            lastUsedAt: Value(_timeOrNull(k['lastUsedAt'])),
            favorite: Value((k['favorite'] as bool?) ?? false),
            favoritePosition: Value((k['favoritePosition'] as int?) ?? 0),
          ),
        );
  }

  for (final p in _maps(data['pantry'], 'pantry')) {
    final name = _need<String>(p, 'name');
    await db
        .into(db.pantryItems)
        .insert(
          PantryItemsCompanion.insert(
            name: name,
            nameKey: foldKey(name),
            quantity: Value(_num(p['quantity'])),
            unit: Value(p['unit'] as String?),
            unitText: Value((p['unitText'] as String?) ?? ''),
            amountText: Value(p['amountText'] as String?),
            aisleId: Value(aisle(p['aisleId'])),
            purchasedOn: _date(p['purchasedOn'], 'purchasedOn'),
            expiresOn: Value(_dateOrNull(p['expiresOn'], 'expiresOn')),
            createdAt: _parse(_need<String>(p, 'createdAt')),
          ),
        );
  }

  /// Công thức và chữ của một món lịch/mẫu; null nếu phải bỏ món này.
  ({int? recipeId, String? text})? entryOf(Map<String, Object?> e) {
    if (!slotIds.contains(_need<int>(e, 'slotId'))) return null;
    final raw = e['recipeId'];
    final rid = recipe(raw);
    if (raw != null && rid == null) return null;
    final text = (e['text'] as String?)?.trim();
    if (rid == null && (text == null || text.isEmpty)) return null;
    return (recipeId: rid, text: rid == null ? text : null);
  }

  for (final e in _maps(data['mealPlan'], 'mealPlan')) {
    final date = _date(e['date'], 'date');
    final v = entryOf(e);
    if (v == null) continue;
    await db
        .into(db.mealPlanEntries)
        .insert(
          MealPlanEntriesCompanion.insert(
            date: date,
            slotId: e['slotId'] as int,
            recipeId: Value(v.recipeId),
            freeText: Value(v.text),
            servings: Value(_num(e['servings'])),
            position: Value((e['position'] as int?) ?? 0),
          ),
        );
  }

  for (final t in _maps(data['menuTemplates'], 'menuTemplates')) {
    final templateId = await db
        .into(db.menuTemplates)
        .insert(
          MenuTemplatesCompanion.insert(
            id: Value(_need<int>(t, 'id')),
            name: _need<String>(t, 'name'),
            position: Value((t['position'] as int?) ?? 0),
            createdAt: _parse(_need<String>(t, 'createdAt')),
          ),
        );
    for (final e in _maps(t['entries'], 'entries')) {
      final v = entryOf(e);
      if (v == null) continue;
      await db
          .into(db.menuTemplateEntries)
          .insert(
            MenuTemplateEntriesCompanion.insert(
              templateId: templateId,
              dayOffset: Value((e['dayOffset'] as int?) ?? 0),
              slotId: e['slotId'] as int,
              recipeId: Value(v.recipeId),
              freeText: Value(v.text),
              servings: Value(_num(e['servings'])),
              position: Value((e['position'] as int?) ?? 0),
            ),
          );
    }
  }
}
