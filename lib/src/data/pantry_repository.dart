import 'package:drift/drift.dart';

import '../menu/meal_planner.dart' show dateKey;
import '../pantry/cookable.dart';
import '../pantry/expiry.dart';
import '../shopping/item_text.dart';
import '../shopping/name_match.dart';
import '../shopping/quantity_merge.dart';
import 'aisle_repository.dart';
import 'database.dart';
import 'text_normalize.dart';

export '../pantry/cookable.dart' show CookableRecipe;
export '../pantry/expiry.dart' show ExpiryStatus;

const maxPantryName = 200;

/// Đọc ngày dạng `YYYY-MM-DD` (giờ địa phương, 00:00); sai dạng thì null.
DateTime? parseDateKey(String? s) {
  if (s == null) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return null;
  return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}

/// Bộ lọc danh sách Tủ bếp (AC-42).
enum PantryFilter { all, soon, expired }

enum PantryProblem { emptyName, nameTooLong }

class PantryException implements Exception {
  const PantryException(this.problem);

  final PantryProblem problem;

  @override
  String toString() => 'PantryException($problem)';
}

/// Nội dung người dùng nhập cho một món trong Tủ bếp (AC-42). [amount] là ô
/// số lượng tự do ("500 g", "2 củ", "1 bó nhỏ"), tách được thì thành số
/// lượng có cấu trúc. [aisleId] null thì tự xếp theo từ điển khi thêm mới.
class PantryDraft {
  const PantryDraft({
    required this.name,
    this.amount,
    this.aisleId,
    this.purchasedOn,
    this.expiresOn,
  });

  final String name;
  final String? amount;
  final int? aisleId;

  /// Ngày mua; null là hôm nay.
  final DateTime? purchasedOn;
  final DateTime? expiresOn;
}

/// Một món trong Tủ bếp.
class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.amountText,
    required this.aisleId,
    required this.purchasedOn,
    required this.expiresOn,
    required this.status,
  });

  final int id;
  final String name;
  final Quantity quantity;
  final String? amountText;
  final int? aisleId;
  final DateTime purchasedOn;
  final DateTime? expiresOn;

  /// Trạng thái hạn dùng tính lúc đọc (AC-42).
  final ExpiryStatus status;

  /// Số lượng để hiện ("500 g", "1 bó nhỏ"), rỗng nếu không ghi.
  String amountLabel({bool decimalComma = false}) => itemLabel(
    name: '',
    quantity: quantity,
    amountText: amountText,
    decimalComma: decimalComma,
  ).trim();

  @override
  String toString() => 'PantryItem($id, $name, $status)';
}

/// Tủ bếp (F-09): nguyên liệu đang có, hạn dùng, "Nấu được gì?".
class PantryRepository {
  PantryRepository(
    this._db, {
    DateTime Function()? clock,
    AisleRepository? aisles,
  }) : _clock = clock ?? DateTime.now,
       _aisles = aisles ?? AisleRepository(_db);

  final AppDatabase _db;
  final DateTime Function() _clock;
  final AisleRepository _aisles;

  PantryItem _from(PantryItemRow r, DateTime now) {
    final expires = parseDateKey(r.expiresOn);
    return PantryItem(
      id: r.id,
      name: r.name,
      quantity: Quantity(
        r.quantity,
        unitFromDb(r.unit),
        _nullIfEmpty(r.unitText),
      ),
      amountText: r.amountText,
      aisleId: r.aisleId,
      purchasedOn: parseDateKey(r.purchasedOn) ?? r.createdAt,
      expiresOn: expires,
      status: expiryStatus(expires, now),
    );
  }

  /// Các món theo [filter], món hết hạn sớm nhất ở trên, món không hạn dùng
  /// ở cuối theo tên (AC-42).
  Stream<List<PantryItem>> watchItems({
    PantryFilter filter = PantryFilter.all,
  }) => _db.select(_db.pantryItems).watch().map((rows) => _list(rows, filter));

  Future<List<PantryItem>> getItems({
    PantryFilter filter = PantryFilter.all,
  }) async => _list(await _db.select(_db.pantryItems).get(), filter);

  List<PantryItem> _list(List<PantryItemRow> rows, PantryFilter filter) {
    final now = _clock();
    final items = [
      for (final r in rows)
        if (_passes(_from(r, now), filter)) _from(r, now),
    ];
    items.sort((a, b) {
      final ea = a.expiresOn;
      final eb = b.expiresOn;
      if (ea != null && eb != null) {
        final c = ea.compareTo(eb);
        if (c != 0) return c;
      } else if (ea != null) {
        return -1;
      } else if (eb != null) {
        return 1;
      }
      final n = normalizeText(a.name).compareTo(normalizeText(b.name));
      return n != 0 ? n : a.id.compareTo(b.id);
    });
    return items;
  }

  static bool _passes(PantryItem i, PantryFilter f) => switch (f) {
    PantryFilter.all => true,
    PantryFilter.soon => i.status == ExpiryStatus.soon,
    PantryFilter.expired => i.status == ExpiryStatus.expired,
  };

  /// Số món sắp hết hạn và đã hết hạn, cho nhãn của bộ lọc (AC-42).
  Stream<({int soon, int expired})> watchExpiryCounts() => watchItems().map(
    (items) => (
      soon: items.where((i) => i.status == ExpiryStatus.soon).length,
      expired: items.where((i) => i.status == ExpiryStatus.expired).length,
    ),
  );

  String _validName(String name) {
    final t = name.trim();
    if (t.isEmpty) throw const PantryException(PantryProblem.emptyName);
    if (t.length > maxPantryName) {
      throw const PantryException(PantryProblem.nameTooLong);
    }
    return t;
  }

  Future<int> add(PantryDraft d) async {
    final name = _validName(d.name);
    final amount = parseAmount(d.amount);
    return _db
        .into(_db.pantryItems)
        .insert(
          PantryItemsCompanion.insert(
            name: name,
            nameKey: foldKey(name),
            quantity: Value(amount.quantity.value),
            unit: Value(unitToDb(amount.quantity.unit)),
            unitText: Value(amount.quantity.text ?? ''),
            amountText: Value(amount.amountText),
            aisleId: Value(d.aisleId ?? await _aisles.aisleIdFor(name)),
            purchasedOn: dateKey(d.purchasedOn ?? _clock()),
            expiresOn: Value(
              d.expiresOn == null ? null : dateKey(d.expiresOn!),
            ),
            createdAt: _clock(),
          ),
        );
  }

  /// Sửa món; [PantryDraft.aisleId] null nghĩa là bỏ khu vực.
  Future<void> update(int id, PantryDraft d) async {
    final name = _validName(d.name);
    final amount = parseAmount(d.amount);
    await (_db.update(_db.pantryItems)..where((p) => p.id.equals(id))).write(
      PantryItemsCompanion(
        name: Value(name),
        nameKey: Value(foldKey(name)),
        quantity: Value(amount.quantity.value),
        unit: Value(unitToDb(amount.quantity.unit)),
        unitText: Value(amount.quantity.text ?? ''),
        amountText: Value(amount.amountText),
        aisleId: Value(d.aisleId),
        purchasedOn: Value(dateKey(d.purchasedOn ?? _clock())),
        expiresOn: Value(d.expiresOn == null ? null : dateKey(d.expiresOn!)),
      ),
    );
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.pantryItems)..where((p) => p.id.equals(id))).go();

  /// Thêm các món vừa mua từ danh sách đi chợ, ngày mua hôm nay (AC-37).
  /// Mỗi món một dòng mới (ngày mua khác nhau thì hạn dùng khác nhau).
  Future<void> addFromShopping(List<ShoppingItemRow> items) async {
    final today = dateKey(_clock());
    for (final i in items) {
      await _db
          .into(_db.pantryItems)
          .insert(
            PantryItemsCompanion.insert(
              name: i.name,
              nameKey: i.nameKey,
              quantity: Value(i.quantity),
              unit: Value(i.unit),
              unitText: Value(i.unitText),
              amountText: Value(i.amountText),
              aisleId: Value(i.aisleId),
              purchasedOn: today,
              createdAt: _clock(),
            ),
          );
    }
  }

  /// Tên mọi món trong tủ, để bỏ chọn khi thêm vào đi chợ (AC-35) và cho
  /// "Nấu được gì?" (AC-43).
  Future<List<String>> names() async => [
    for (final r in await _db.select(_db.pantryItems).get()) r.name,
  ];

  /// "Nấu được gì?" (AC-43): công thức đang dùng (không tính thùng rác) xếp
  /// theo tỉ lệ nguyên liệu đang có.
  Future<List<CookableRecipe>> cookable({required bool ignoreBasics}) async {
    final recipes = await (_db.select(
      _db.recipes,
    )..where((r) => r.deletedAt.isNull())).get();
    final lines =
        await (_db.select(_db.recipeLines)
              ..where(
                (l) =>
                    l.section.equalsValue(LineSection.ingredient) &
                    l.isHeading.equals(false),
              )
              ..orderBy([(l) => OrderingTerm.asc(l.position)]))
            .get();
    final byRecipe = <int, List<String>>{};
    for (final l in lines) {
      byRecipe.putIfAbsent(l.recipeId, () => []).add(l.body);
    }
    return rankCookable(
      recipes: [
        for (final r in recipes)
          RecipeIngredients(
            id: r.id,
            name: r.name,
            lines: byRecipe[r.id] ?? const [],
          ),
      ],
      pantryNames: await names(),
      ignoreBasics: ignoreBasics,
    );
  }

  /// Như [cookable], tính lại khi tủ bếp hoặc công thức đổi.
  Stream<List<CookableRecipe>> watchCookable({required bool ignoreBasics}) =>
      _changes().asyncMap((_) => cookable(ignoreBasics: ignoreBasics));

  Stream<void> _changes() async* {
    yield null;
    yield* _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.pantryItems,
        _db.recipes,
        _db.recipeLines,
      ]),
    );
  }
}

String? _nullIfEmpty(String s) => s.isEmpty ? null : s;
