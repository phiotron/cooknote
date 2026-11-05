import 'package:drift/drift.dart';

import '../shopping/item_text.dart';
import '../shopping/name_match.dart';
import '../shopping/quantity_merge.dart';
import '../shopping/shopping_candidates.dart';
import '../shopping/shopping_text.dart';
import 'aisle_repository.dart';
import 'database.dart';
import 'pantry_repository.dart';

export '../shopping/quantity_merge.dart' show Quantity;
export '../shopping/shopping_candidates.dart' show ShoppingCandidate;

const maxShoppingListName = 50;
const maxShoppingItemName = 200;

enum ShoppingProblem { emptyName, nameTooLong, notFound }

class ShoppingException implements Exception {
  const ShoppingException(this.problem);

  final ShoppingProblem problem;

  @override
  String toString() => 'ShoppingException($problem)';
}

/// Một danh sách đi chợ kèm số món (AC-34).
class ShoppingListInfo {
  const ShoppingListInfo({
    required this.id,
    required this.name,
    required this.position,
    required this.itemCount,
    required this.remaining,
  });

  final int id;
  final String name;
  final int position;
  final int itemCount;

  /// Số món chưa gạch.
  final int remaining;
}

/// Công thức nguồn của một món (AC-35); [recipeId] null khi công thức đã bị
/// xóa hẳn (tên vẫn còn).
class ShoppingSource {
  const ShoppingSource(this.recipeId, this.recipeName);

  final int? recipeId;
  final String recipeName;

  @override
  bool operator ==(Object other) =>
      other is ShoppingSource &&
      other.recipeId == recipeId &&
      other.recipeName == recipeName;

  @override
  int get hashCode => Object.hash(recipeId, recipeName);
}

/// Một món trong danh sách đi chợ.
class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.amountText,
    required this.note,
    required this.aisleId,
    required this.checked,
    required this.checkedAt,
    required this.position,
    required this.sources,
  });

  final int id;
  final int listId;
  final String name;
  final Quantity quantity;
  final String? amountText;
  final String? note;
  final int? aisleId;
  final bool checked;
  final DateTime? checkedAt;
  final int position;
  final List<ShoppingSource> sources;

  /// "500 g thịt bò", "1 bó nhỏ rau muống", "sữa (không đường)".
  String label({bool decimalComma = false}) => itemLabel(
    name: name,
    quantity: quantity,
    amountText: amountText,
    note: note,
    decimalComma: decimalComma,
  );

  @override
  String toString() => 'ShoppingItem($id, ${label()}, checked=$checked)';
}

/// Một món trong "Món hay mua" hoặc gợi ý khi gõ (AC-34).
class KnownItem {
  const KnownItem({
    required this.name,
    required this.nameKey,
    required this.useCount,
    required this.favorite,
  });

  final String name;
  final String nameKey;
  final int useCount;

  /// Người dùng đã ghim.
  final bool favorite;

  @override
  String toString() => 'KnownItem($name, $useCount, favorite=$favorite)';
}

/// Kết quả thêm món: số dòng mới và số món đã gộp vào dòng có sẵn (AC-35).
class AddResult {
  const AddResult(this.added, this.merged);

  final int added;
  final int merged;
}

/// Danh sách đi chợ (F-07, AC-34..AC-37).
class ShoppingRepository {
  ShoppingRepository(
    this._db, {
    DateTime Function()? clock,
    AisleRepository? aisles,
    PantryRepository? pantry,
  }) : _clock = clock ?? DateTime.now,
       _aisles = aisles ?? AisleRepository(_db),
       _pantry =
           pantry ??
           PantryRepository(
             _db,
             clock: clock,
             aisles: aisles ?? AisleRepository(_db),
           );

  final AppDatabase _db;
  final DateTime Function() _clock;
  final AisleRepository _aisles;
  final PantryRepository _pantry;

  // ---------------------------------------------------------------- danh sách

  Stream<void> _changes(List<TableInfo<Table, dynamic>> tables) async* {
    yield null;
    yield* _db.tableUpdates(TableUpdateQuery.onAllTables(tables));
  }

  /// Mọi danh sách theo thứ tự, kèm số món.
  Stream<List<ShoppingListInfo>> watchLists() =>
      _changes([_db.shoppingLists, _db.shoppingItems])
          .asyncMap((_) => getLists());

  Future<List<ShoppingListInfo>> getLists() async {
    final lists =
        await (_db.select(_db.shoppingLists)..orderBy([
              (l) => OrderingTerm.asc(l.position),
              (l) => OrderingTerm.asc(l.id),
            ]))
            .get();
    final items = await _db.select(_db.shoppingItems).get();
    return [
      for (final l in lists)
        ShoppingListInfo(
          id: l.id,
          name: l.name,
          position: l.position,
          itemCount: items.where((i) => i.listId == l.id).length,
          remaining: items.where((i) => i.listId == l.id && !i.checked).length,
        ),
    ];
  }

  String _validListName(String name) {
    final t = name.trim();
    if (t.isEmpty) throw const ShoppingException(ShoppingProblem.emptyName);
    if (t.length > maxShoppingListName) {
      throw const ShoppingException(ShoppingProblem.nameTooLong);
    }
    return t;
  }

  /// Tạo danh sách mới ở cuối (AC-34).
  Future<int> createList(String name) async {
    final clean = _validListName(name);
    final lists = await getLists();
    return _db
        .into(_db.shoppingLists)
        .insert(
          ShoppingListsCompanion.insert(
            name: clean,
            position: Value(lists.isEmpty ? 0 : lists.last.position + 1),
            createdAt: _clock(),
          ),
        );
  }

  Future<void> renameList(int id, String name) async {
    final clean = _validListName(name);
    final n =
        await (_db.update(_db.shoppingLists)..where((l) => l.id.equals(id)))
            .write(ShoppingListsCompanion(name: Value(clean)));
    if (n == 0) throw const ShoppingException(ShoppingProblem.notFound);
  }

  /// Xóa danh sách cùng mọi món của nó.
  Future<void> deleteList(int id) =>
      (_db.delete(_db.shoppingLists)..where((l) => l.id.equals(id))).go();

  Future<void> reorderLists(List<int> orderedIds) => _db.transaction(() async {
    for (var i = 0; i < orderedIds.length; i++) {
      await (_db.update(_db.shoppingLists)
            ..where((l) => l.id.equals(orderedIds[i])))
          .write(ShoppingListsCompanion(position: Value(i)));
    }
  });

  // --------------------------------------------------------------------- món

  /// Món của danh sách [listId] (AC-37): món chưa gạch trước, theo thứ tự
  /// khu vực (món không khu vực ở cuối) rồi thứ tự thêm; món đã gạch xuống
  /// cuối, gạch trước ở trên.
  Stream<List<ShoppingItem>> watchItems(int listId) =>
      _changes([_db.shoppingItems, _db.shoppingItemSources, _db.aisles])
          .asyncMap((_) => getItems(listId));

  Future<List<ShoppingItem>> getItems(int listId) async {
    final rows = await (_db.select(
      _db.shoppingItems,
    )..where((i) => i.listId.equals(listId))).get();
    final sources =
        await (_db.select(_db.shoppingItemSources)
              ..where((s) => s.itemId.isIn(rows.map((r) => r.id)))
              ..orderBy([(s) => OrderingTerm.asc(s.id)]))
            .get();
    final aislePos = {for (final a in await _aisles.getAll()) a.id: a.position};
    final items = [
      for (final r in rows)
        ShoppingItem(
          id: r.id,
          listId: r.listId,
          name: r.name,
          quantity: Quantity(
            r.quantity,
            unitFromDb(r.unit),
            r.unitText.isEmpty ? null : r.unitText,
          ),
          amountText: r.amountText,
          note: r.note,
          aisleId: r.aisleId,
          checked: r.checked,
          checkedAt: r.checkedAt,
          position: r.position,
          sources: [
            for (final s in sources)
              if (s.itemId == r.id) ShoppingSource(s.recipeId, s.recipeName),
          ],
        ),
    ];
    // Khu vực không còn (hoặc null) xếp sau mọi khu vực.
    const last = 1 << 30;
    items.sort((a, b) {
      if (a.checked != b.checked) return a.checked ? 1 : -1;
      if (a.checked) {
        final c = (a.checkedAt ?? DateTime(0)).compareTo(
          b.checkedAt ?? DateTime(0),
        );
        return c != 0 ? c : a.id.compareTo(b.id);
      }
      final pa = aislePos[a.aisleId] ?? last;
      final pb = aislePos[b.aisleId] ?? last;
      if (pa != pb) return pa.compareTo(pb);
      final p = a.position.compareTo(b.position);
      return p != 0 ? p : a.id.compareTo(b.id);
    });
    return items;
  }

  /// Thêm một món gõ tay ("500 g thịt bò", "sữa") (AC-34). Gộp với món trùng
  /// như [addCandidates].
  Future<AddResult> addText(int listId, String line) {
    final item = parseItemText(line);
    if (item.name.trim().isEmpty) {
      throw const ShoppingException(ShoppingProblem.emptyName);
    }
    return addCandidates(listId, [
      ShoppingCandidate(
        name: item.name,
        quantity: item.quantity,
        amountText: item.amountText,
        note: item.note,
      ),
    ]);
  }

  /// Thêm các ứng viên đang được chọn vào danh sách [listId] (AC-35, AC-40).
  /// Món trùng tên ([namesMatch]) với một món CHƯA gạch và cùng loại đơn vị
  /// thì cộng số lượng vào món đó; khác loại đơn vị thì thành dòng mới. Mỗi
  /// món ghi các công thức nguồn. Món mới tự xếp khu vực (AC-36).
  Future<AddResult> addCandidates(
    int listId,
    List<ShoppingCandidate> candidates,
  ) => _db.transaction(() async {
    var added = 0;
    var merged = 0;
    final now = _clock();
    for (final c in candidates.where((c) => c.selected)) {
      final name = c.name.trim();
      if (name.isEmpty) continue;
      if (name.length > maxShoppingItemName) {
        throw const ShoppingException(ShoppingProblem.nameTooLong);
      }
      final key = foldKey(name);
      final open =
          await (_db.select(_db.shoppingItems)..where(
                (i) =>
                    i.listId.equals(listId) &
                    i.nameKey.equals(key) &
                    i.checked.equals(false),
              ))
              .get();
      ShoppingItemRow? target;
      Quantity? sum;
      for (final o in open) {
        if (!namesMatch(o.name, name)) continue;
        final existing = Quantity(
          o.quantity,
          unitFromDb(o.unit),
          o.unitText.isEmpty ? null : o.unitText,
        );
        final m = mergeQuantities(existing, c.quantity);
        if (m != null) {
          target = o;
          sum = m;
          break;
        }
      }
      final int itemId;
      if (target != null) {
        itemId = target.id;
        await (_db.update(
          _db.shoppingItems,
        )..where((i) => i.id.equals(itemId))).write(
          ShoppingItemsCompanion(
            quantity: Value(sum!.value),
            unit: Value(unitToDb(sum.unit)),
            unitText: Value(sum.text ?? ''),
            amountText: Value(
              sum.value == null ? (target.amountText ?? c.amountText) : null,
            ),
            note: Value(target.note ?? c.note),
          ),
        );
        merged++;
      } else {
        itemId = await _db
            .into(_db.shoppingItems)
            .insert(
              ShoppingItemsCompanion.insert(
                listId: listId,
                name: name,
                nameKey: key,
                quantity: Value(c.quantity.value),
                unit: Value(unitToDb(c.quantity.unit)),
                unitText: Value(c.quantity.text ?? ''),
                amountText: Value(c.amountText),
                note: Value(c.note),
                aisleId: Value(await _aisles.aisleIdFor(name)),
                position: Value(await _nextPosition(listId)),
              ),
            );
        added++;
      }
      if (c.recipeName != null) {
        final already =
            await (_db.select(_db.shoppingItemSources)..where(
                  (s) =>
                      s.itemId.equals(itemId) &
                      (c.recipeId == null
                          ? s.recipeName.equals(c.recipeName!)
                          : s.recipeId.equals(c.recipeId!)),
                ))
                .get();
        if (already.isEmpty) {
          await _db
              .into(_db.shoppingItemSources)
              .insert(
                ShoppingItemSourcesCompanion.insert(
                  itemId: itemId,
                  recipeId: Value(c.recipeId),
                  recipeName: c.recipeName!,
                ),
              );
        }
      }
      await _touchKnown(name, key, now);
    }
    return AddResult(added, merged);
  });

  Future<int> _nextPosition(int listId) async {
    final max = _db.shoppingItems.position.max();
    final row =
        await (_db.selectOnly(_db.shoppingItems)
              ..addColumns([max])
              ..where(_db.shoppingItems.listId.equals(listId)))
            .getSingle();
    final m = row.read(max);
    return m == null ? 0 : m + 1;
  }

  Future<void> _touchKnown(String name, String key, DateTime now) => _db
      .into(_db.knownItems)
      .insert(
        KnownItemsCompanion.insert(
          nameKey: key,
          name: name,
          useCount: const Value(1),
          lastUsedAt: Value(now),
        ),
        onConflict: DoUpdate(
          (old) => KnownItemsCompanion.custom(
            name: Constant(name),
            useCount: old.useCount + const Constant(1),
            lastUsedAt: Constant(now),
          ),
        ),
      );

  /// Gạch hoặc bỏ gạch một món (AC-37).
  Future<void> setChecked(int itemId, bool checked) =>
      (_db.update(_db.shoppingItems)..where((i) => i.id.equals(itemId))).write(
        ShoppingItemsCompanion(
          checked: Value(checked),
          checkedAt: Value(checked ? _clock() : null),
        ),
      );

  /// Sửa món bằng một dòng chữ mới ("700 g thịt bò"). Khu vực giữ nguyên.
  Future<void> editItem(int itemId, String line) async {
    final item = parseItemText(line);
    final name = item.name.trim();
    if (name.isEmpty) throw const ShoppingException(ShoppingProblem.emptyName);
    if (name.length > maxShoppingItemName) {
      throw const ShoppingException(ShoppingProblem.nameTooLong);
    }
    final n =
        await (_db.update(
          _db.shoppingItems,
        )..where((i) => i.id.equals(itemId))).write(
          ShoppingItemsCompanion(
            name: Value(name),
            nameKey: Value(foldKey(name)),
            quantity: Value(item.quantity.value),
            unit: Value(unitToDb(item.quantity.unit)),
            unitText: Value(item.quantity.text ?? ''),
            amountText: Value(item.amountText),
            note: Value(item.note),
          ),
        );
    if (n == 0) throw const ShoppingException(ShoppingProblem.notFound);
  }

  /// Chuyển món sang khu vực khác; app nhớ cho lần sau (AC-36).
  Future<void> moveToAisle(int itemId, int? aisleId) =>
      _db.transaction(() async {
        final row = await (_db.select(
          _db.shoppingItems,
        )..where((i) => i.id.equals(itemId))).getSingleOrNull();
        if (row == null) {
          throw const ShoppingException(ShoppingProblem.notFound);
        }
        await (_db.update(_db.shoppingItems)..where((i) => i.id.equals(itemId)))
            .write(ShoppingItemsCompanion(aisleId: Value(aisleId)));
        await _aisles.remember(row.name, aisleId);
      });

  /// Đặt thứ tự các món (kéo thả trong một khu vực).
  Future<void> reorderItems(List<int> orderedIds) => _db.transaction(() async {
    for (var i = 0; i < orderedIds.length; i++) {
      await (_db.update(_db.shoppingItems)
            ..where((it) => it.id.equals(orderedIds[i])))
          .write(ShoppingItemsCompanion(position: Value(i)));
    }
  });

  Future<void> deleteItem(int itemId) =>
      (_db.delete(_db.shoppingItems)..where((i) => i.id.equals(itemId))).go();

  /// "Xóa các món đã gạch" (AC-37); [toPantry] thì chuyển chúng vào Tủ bếp
  /// trước, ngày mua hôm nay. Trả về số món đã xóa.
  Future<int> clearChecked(
    int listId, {
    bool toPantry = false,
  }) => _db.transaction(() async {
    final done = await (_db.select(
      _db.shoppingItems,
    )..where((i) => i.listId.equals(listId) & i.checked.equals(true))).get();
    if (toPantry) await _pantry.addFromShopping(done);
    await (_db.delete(
      _db.shoppingItems,
    )..where((i) => i.listId.equals(listId) & i.checked.equals(true))).go();
    return done.length;
  });

  /// Danh sách dạng chữ để chia sẻ (AC-37): chỉ món chưa gạch, nhóm theo khu
  /// vực theo thứ tự cửa hàng. [noAisleLabel] là tên nhóm của món không khu
  /// vực (chuỗi dịch "Khác"/"Other").
  Future<String> exportText(
    int listId, {
    required String noAisleLabel,
    bool decimalComma = false,
  }) async {
    final list = await (_db.select(
      _db.shoppingLists,
    )..where((l) => l.id.equals(listId))).getSingleOrNull();
    if (list == null) throw const ShoppingException(ShoppingProblem.notFound);
    final items = (await getItems(listId)).where((i) => !i.checked).toList();
    final aisles = await _aisles.getAll();
    final known = {for (final a in aisles) a.id};
    final groups = <({String aisle, List<String> lines})>[
      for (final a in aisles)
        (
          aisle: a.name,
          lines: [
            for (final i in items)
              if (i.aisleId == a.id) i.label(decimalComma: decimalComma),
          ],
        ),
      (
        aisle: noAisleLabel,
        lines: [
          for (final i in items)
            if (!known.contains(i.aisleId)) i.label(decimalComma: decimalComma),
        ],
      ),
    ];
    return shoppingListToText(title: list.name, groups: groups);
  }

  // -------------------------------------------------- gợi ý và món hay mua

  static KnownItem _known(KnownItemRow r) => KnownItem(
    name: r.name,
    nameKey: r.nameKey,
    useCount: r.useCount,
    favorite: r.favorite,
  );

  /// Gợi ý khi gõ (AC-34): món đã từng thêm có tên bắt đầu bằng [text] hoặc
  /// có một từ bắt đầu bằng [text] (không phân biệt dấu), dùng nhiều trước.
  Future<List<KnownItem>> suggest(String text, {int limit = 8}) async {
    final q = foldKey(text);
    if (q.isEmpty) return const [];
    final like = q.replaceAll(RegExp('[%_]'), ' ');
    final rows =
        await (_db.select(_db.knownItems)
              ..where(
                (k) =>
                    k.useCount.isBiggerThanValue(0) &
                    (k.nameKey.like('$like%') | k.nameKey.like('% $like%')),
              )
              ..orderBy([
                (k) => OrderingTerm.desc(k.useCount),
                (k) => OrderingTerm.desc(k.lastUsedAt),
              ])
              ..limit(limit))
            .get();
    return rows.map(_known).toList();
  }

  /// "Món hay mua" (AC-34): món đã ghim (theo thứ tự ghim), rồi món đã mua
  /// từ [minUses] lần trở lên, nhiều trước; tối đa [limit] món.
  Stream<List<KnownItem>> watchFrequent({int limit = 30, int minUses = 2}) =>
      _changes([_db.knownItems])
          .asyncMap((_) => frequent(limit: limit, minUses: minUses));

  Future<List<KnownItem>> frequent({int limit = 30, int minUses = 2}) async {
    final pinned =
        await (_db.select(_db.knownItems)
              ..where((k) => k.favorite.equals(true))
              ..orderBy([
                (k) => OrderingTerm.asc(k.favoritePosition),
                (k) => OrderingTerm.asc(k.name),
              ]))
            .get();
    final used =
        await (_db.select(_db.knownItems)
              ..where(
                (k) =>
                    k.favorite.equals(false) &
                    k.useCount.isBiggerOrEqualValue(minUses),
              )
              ..orderBy([
                (k) => OrderingTerm.desc(k.useCount),
                (k) => OrderingTerm.desc(k.lastUsedAt),
              ])
              ..limit(limit))
            .get();
    return [...pinned, ...used].take(limit).map(_known).toList();
  }

  /// Ghim hoặc bỏ ghim một món vào "Món hay mua" (AC-34).
  Future<void> setFavorite(String name, bool favorite) async {
    final key = foldKey(name);
    if (key.isEmpty) return;
    final max = _db.knownItems.favoritePosition.max();
    final row =
        await (_db.selectOnly(_db.knownItems)
              ..addColumns([max])
              ..where(_db.knownItems.favorite.equals(true)))
            .getSingle();
    final next = (row.read(max) ?? -1) + 1;
    await _db
        .into(_db.knownItems)
        .insert(
          KnownItemsCompanion.insert(
            nameKey: key,
            name: name.trim(),
            favorite: Value(favorite),
            favoritePosition: Value(next),
          ),
          onConflict: DoUpdate(
            (old) => KnownItemsCompanion(
              favorite: Value(favorite),
              favoritePosition: Value(next),
            ),
          ),
        );
  }

  Future<void> reorderFavorites(List<String> orderedNameKeys) =>
      _db.transaction(() async {
        for (var i = 0; i < orderedNameKeys.length; i++) {
          await (_db.update(_db.knownItems)
                ..where((k) => k.nameKey.equals(orderedNameKeys[i])))
              .write(KnownItemsCompanion(favoritePosition: Value(i)));
        }
      });

  /// Quên một món khỏi gợi ý, "Món hay mua" và khu vực đã nhớ.
  Future<void> forget(String nameKey) => (_db.delete(
    _db.knownItems,
  )..where((k) => k.nameKey.equals(nameKey))).go();

  // ------------------------------------------ từ công thức (AC-35)

  /// Nguyên liệu của công thức [recipeId] để chọn thêm vào đi chợ (AC-35),
  /// nhân theo [servings] (khẩu phần đang chọn; null là khẩu phần gốc). Món
  /// đang có trong Tủ bếp được bỏ chọn sẵn. Công thức không có thì rỗng.
  Future<List<ShoppingCandidate>> candidatesForRecipe(
    int recipeId, {
    double? servings,
  }) async {
    final recipe = await (_db.select(
      _db.recipes,
    )..where((r) => r.id.equals(recipeId))).getSingleOrNull();
    if (recipe == null) return const [];
    return candidatesFromLines(
      lines: await ingredientLines(_db, recipeId),
      recipeId: recipe.id,
      recipeName: recipe.name,
      factor: servingsFactor(servings, recipe.servings),
      pantryNames: await _pantry.names(),
    );
  }
}

/// Các dòng nguyên liệu (không gồm tiêu đề nhóm) của một công thức.
Future<List<String>> ingredientLines(AppDatabase db, int recipeId) async {
  final rows =
      await (db.select(db.recipeLines)
            ..where(
              (l) =>
                  l.recipeId.equals(recipeId) &
                  l.section.equalsValue(LineSection.ingredient) &
                  l.isHeading.equals(false),
            )
            ..orderBy([(l) => OrderingTerm.asc(l.position)]))
          .get();
  return [for (final r in rows) r.body];
}
