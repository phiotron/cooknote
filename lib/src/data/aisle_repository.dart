import 'package:drift/drift.dart';

import '../shopping/aisle_dictionary.dart';
import '../shopping/name_match.dart';
import 'database.dart';

const maxAisleName = 50;

enum AisleProblem { emptyName, nameTooLong, notFound }

class AisleException implements Exception {
  const AisleException(this.problem);

  final AisleProblem problem;

  @override
  String toString() => 'AisleException($problem)';
}

/// Một khu vực trong cửa hàng (AC-36). [key] là khóa khu vực mặc định
/// (`produce`...) hoặc null với khu vực người dùng thêm.
class Aisle {
  const Aisle({
    required this.id,
    required this.key,
    required this.name,
    required this.position,
  });

  final int id;
  final String? key;
  final String name;
  final int position;

  @override
  String toString() => 'Aisle($id, $name)';
}

/// Khu vực đi chợ: thêm, đổi tên, xóa, sắp theo đường đi trong cửa hàng; tìm
/// khu vực cho một món (nhớ lựa chọn của người dùng trước, rồi từ điển).
class AisleRepository {
  AisleRepository(this._db);

  final AppDatabase _db;

  static Aisle _from(AisleRow r) =>
      Aisle(id: r.id, key: r.key, name: r.name, position: r.position);

  SimpleSelectStatement<$AislesTable, AisleRow> _ordered() =>
      _db.select(_db.aisles)..orderBy([
        (a) => OrderingTerm.asc(a.position),
        (a) => OrderingTerm.asc(a.id),
      ]);

  /// Mọi khu vực theo thứ tự đi trong cửa hàng.
  Stream<List<Aisle>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_from).toList());

  Future<List<Aisle>> getAll() async =>
      (await _ordered().get()).map(_from).toList();

  String _validName(String name) {
    final t = name.trim();
    if (t.isEmpty) throw const AisleException(AisleProblem.emptyName);
    if (t.length > maxAisleName) {
      throw const AisleException(AisleProblem.nameTooLong);
    }
    return t;
  }

  /// Thêm khu vực vào cuối.
  Future<int> add(String name) async {
    final clean = _validName(name);
    final all = await getAll();
    final next = all.isEmpty ? 0 : all.last.position + 1;
    return _db
        .into(_db.aisles)
        .insert(AislesCompanion.insert(name: clean, position: Value(next)));
  }

  Future<void> rename(int id, String name) async {
    final clean = _validName(name);
    final n = await (_db.update(_db.aisles)..where((a) => a.id.equals(id)))
        .write(AislesCompanion(name: Value(clean)));
    if (n == 0) throw const AisleException(AisleProblem.notFound);
  }

  /// Xóa khu vực. Món trong khu vực này (đi chợ, tủ bếp) thành "không khu
  /// vực"; món đã nhớ vào khu vực này quay về theo từ điển.
  Future<void> delete(int id) =>
      (_db.delete(_db.aisles)..where((a) => a.id.equals(id))).go();

  /// Đặt thứ tự mới theo đường đi trong cửa hàng (AC-36).
  Future<void> reorder(List<int> orderedIds) => _db.transaction(() async {
    for (var i = 0; i < orderedIds.length; i++) {
      await (_db.update(_db.aisles)..where((a) => a.id.equals(orderedIds[i])))
          .write(AislesCompanion(position: Value(i)));
    }
  });

  /// Khu vực cho món tên [name] (AC-36): khu vực người dùng đã chọn cho tên
  /// này trước đó; không có thì theo từ điển vi/en; khu vực đó đã bị xóa thì
  /// "Khác"; "Khác" cũng bị xóa thì null.
  Future<int?> aisleIdFor(String name) async {
    final remembered = await (_db.select(
      _db.knownItems,
    )..where((k) => k.nameKey.equals(foldKey(name)))).getSingleOrNull();
    if (remembered?.aisleId != null) return remembered!.aisleId;
    final all = await getAll();
    final key = aisleKeyFor(name);
    final hit =
        all.where((a) => a.key == key).firstOrNull ??
        all.where((a) => a.key == 'other').firstOrNull;
    return hit?.id;
  }

  /// Nhớ rằng món tên [name] thuộc khu vực [aisleId] (AC-36).
  Future<void> remember(String name, int? aisleId) async {
    final key = foldKey(name);
    if (key.isEmpty) return;
    await _db
        .into(_db.knownItems)
        .insert(
          KnownItemsCompanion.insert(
            nameKey: key,
            name: name.trim(),
            aisleId: Value(aisleId),
          ),
          onConflict: DoUpdate(
            (old) => KnownItemsCompanion(aisleId: Value(aisleId)),
          ),
        );
  }
}
