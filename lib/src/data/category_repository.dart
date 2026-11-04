import 'package:drift/drift.dart';

import 'database.dart';

/// Số cấp danh mục tối đa (AC-10).
const maxCategoryDepth = 3;
const maxCategoryName = 50;

enum CategoryProblem { emptyName, nameTooLong, tooDeep, notFound }

class CategoryException implements Exception {
  const CategoryException(this.problem);

  final CategoryProblem problem;

  @override
  String toString() => 'CategoryException($problem)';
}

/// Một danh mục kèm cấp (1 là cấp đầu), theo thứ tự hiển thị: cha rồi tới
/// con của nó.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.parentId,
    required this.position,
    required this.depth,
  });

  final int id;
  final String name;
  final int? parentId;
  final int position;
  final int depth;
}

/// [id] cùng mọi danh mục con cháu của nó.
Set<int> descendantIds(List<Category> all, int id) {
  final result = {id};
  var added = true;
  while (added) {
    added = false;
    for (final c in all) {
      if (c.parentId != null &&
          result.contains(c.parentId) &&
          result.add(c.id)) {
        added = true;
      }
    }
  }
  return result;
}

const _seedKey = 'categoriesSeeded';

const _defaultsVi = [
  'Món chính',
  'Món phụ',
  'Canh/Súp',
  'Tráng miệng',
  'Đồ uống',
  'Bánh',
];
const _defaultsEn = [
  'Main dishes',
  'Side dishes',
  'Soups',
  'Desserts',
  'Drinks',
  'Baking',
];

/// Danh mục công thức, lồng tối đa 3 cấp (F-02, AC-10).
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  /// Mọi danh mục theo thứ tự hiển thị (cha rồi con), có cấp.
  Stream<List<Category>> watchAll() =>
      _db.select(_db.categories).watch().map(_flatten);

  Future<List<Category>> getAll() async =>
      _flatten(await _db.select(_db.categories).get());

  static List<Category> _flatten(List<CategoryRow> rows) {
    final byParent = <int?, List<CategoryRow>>{};
    for (final r in rows) {
      byParent.putIfAbsent(r.parentId, () => []).add(r);
    }
    for (final list in byParent.values) {
      list.sort((a, b) {
        final p = a.position.compareTo(b.position);
        return p != 0 ? p : a.id.compareTo(b.id);
      });
    }
    final out = <Category>[];
    void walk(int? parent, int depth) {
      for (final r in byParent[parent] ?? const <CategoryRow>[]) {
        out.add(
          Category(
            id: r.id,
            name: r.name,
            parentId: r.parentId,
            position: r.position,
            depth: depth,
          ),
        );
        walk(r.id, depth + 1);
      }
    }

    walk(null, 1);
    return out;
  }

  String _validName(String name) {
    final t = name.trim();
    if (t.isEmpty) throw const CategoryException(CategoryProblem.emptyName);
    if (t.length > maxCategoryName) {
      throw const CategoryException(CategoryProblem.nameTooLong);
    }
    return t;
  }

  /// Thêm danh mục vào cuối cấp của [parentId] (null là cấp đầu).
  Future<int> add(String name, {int? parentId}) async {
    final clean = _validName(name);
    final all = await getAll();
    if (parentId != null) {
      final parent = all.where((c) => c.id == parentId).firstOrNull;
      if (parent == null) {
        throw const CategoryException(CategoryProblem.notFound);
      }
      if (parent.depth >= maxCategoryDepth) {
        throw const CategoryException(CategoryProblem.tooDeep);
      }
    }
    final siblings = all.where((c) => c.parentId == parentId);
    final next = siblings.isEmpty
        ? 0
        : siblings.map((c) => c.position).reduce((a, b) => a > b ? a : b) + 1;
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: clean,
            parentId: Value(parentId),
            position: Value(next),
          ),
        );
  }

  Future<void> rename(int id, String name) async {
    final clean = _validName(name);
    final updated =
        await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
          CategoriesCompanion(name: Value(clean)),
        );
    if (updated == 0) throw const CategoryException(CategoryProblem.notFound);
  }

  /// Xóa danh mục cùng mọi danh mục con. Công thức không bị xóa, chỉ mất liên
  /// kết tới các danh mục này.
  Future<void> delete(int id) async {
    final all = await getAll();
    final ids = descendantIds(all, id);
    await _db.transaction(() async {
      await (_db.delete(
        _db.recipeCategories,
      )..where((r) => r.categoryId.isIn(ids))).go();
      // Xóa từ con tới cha để không vi phạm khóa ngoại.
      for (final c in all.reversed.where((c) => ids.contains(c.id))) {
        await (_db.delete(
          _db.categories,
        )..where((t) => t.id.equals(c.id))).go();
      }
    });
  }

  /// Đặt thứ tự mới cho các danh mục con của [parentId] (null là cấp đầu).
  Future<void> reorder(int? parentId, List<int> orderedIds) =>
      _db.transaction(() async {
        for (var i = 0; i < orderedIds.length; i++) {
          await (_db.update(_db.categories)..where(
                (c) =>
                    c.id.equals(orderedIds[i]) &
                    (parentId == null
                        ? c.parentId.isNull()
                        : c.parentId.equals(parentId)),
              ))
              .write(CategoriesCompanion(position: Value(i)));
        }
      });

  /// Tạo danh mục mặc định theo ngôn ngữ ở lần đầu; trả về true nếu đã tạo.
  /// Người dùng xóa hết rồi thì không tạo lại.
  Future<bool> seedDefaults(String languageCode) async {
    final done = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_seedKey))).getSingleOrNull();
    if (done != null) return false;
    final names = languageCode == 'vi' ? _defaultsVi : _defaultsEn;
    await _db.transaction(() async {
      for (final n in names) {
        await add(n);
      }
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: _seedKey, value: '1'),
          );
    });
    return true;
  }
}
