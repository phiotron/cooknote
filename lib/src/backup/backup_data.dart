import 'package:drift/drift.dart';

import '../data/database.dart';
import '../data/text_normalize.dart';
import 'backup_errors.dart';

/// Các khóa cài đặt đi theo bản sao lưu. Cài đặt của chính tính năng sao lưu
/// (thư mục, lịch) không đi theo: đổi máy thì chọn lại.
const _portableSettings = ['locale', 'themeMode', 'viewMode'];

String _iso(DateTime t) => t.toUtc().toIso8601String();
DateTime _parse(Object? v) => DateTime.parse(v as String).toLocal();

/// Toàn bộ dữ liệu dạng JSON thuần, không phụ thuộc phiên bản bảng của cơ sở
/// dữ liệu (D-007). Chỉ được THÊM khóa, không đổi nghĩa khóa cũ (AC-55).
///
/// [recipeIds] khác null thì chỉ xuất các công thức đó (chia sẻ một vài công
/// thức, F-10) cùng các danh mục chúng dùng và danh mục cha của chúng.
Future<Map<String, Object?>> exportData(
  AppDatabase db, {
  Set<int>? recipeIds,
}) async {
  final recipes = [
    for (final r
        in await (db.select(
          db.recipes,
        )..orderBy([(r) => OrderingTerm.asc(r.id)])).get())
      if (recipeIds == null || recipeIds.contains(r.id)) r,
  ];
  final lines = await (db.select(
    db.recipeLines,
  )..orderBy([(l) => OrderingTerm.asc(l.position)])).get();
  final photos = await (db.select(
    db.recipePhotos,
  )..orderBy([(p) => OrderingTerm.asc(p.position)])).get();
  final links = await db.select(db.recipeCategories).get();
  final tags = await (db.select(
    db.recipeTags,
  )..orderBy([(t) => OrderingTerm.asc(CustomExpression<int>('rowid'))])).get();
  final cooked =
      await (db.select(db.cookLog)..orderBy([
            (c) => OrderingTerm.asc(c.cookedAt),
            (c) => OrderingTerm.asc(c.id),
          ]))
          .get();
  var categories = await (db.select(
    db.categories,
  )..orderBy([(c) => OrderingTerm.asc(c.id)])).get();
  if (recipeIds != null) {
    final byId = {for (final c in categories) c.id: c};
    final keep = <int>{};
    for (final l in links) {
      if (!recipeIds.contains(l.recipeId)) continue;
      int? id = l.categoryId;
      while (id != null && byId.containsKey(id) && keep.add(id)) {
        id = byId[id]!.parentId;
      }
    }
    categories = [
      for (final c in categories)
        if (keep.contains(c.id)) c,
    ];
  }
  final settings = await db.select(db.settings).get();

  Map<int, List<T>> group<T>(Iterable<T> rows, int Function(T) key) {
    final m = <int, List<T>>{};
    for (final r in rows) {
      m.putIfAbsent(key(r), () => []).add(r);
    }
    return m;
  }

  final linesBy = group(lines, (l) => l.recipeId);
  final photosBy = group(photos, (p) => p.recipeId);
  final linksBy = group(links, (l) => l.recipeId);
  final tagsBy = group(tags, (t) => t.recipeId);
  final cookedBy = group(cooked, (c) => c.recipeId);

  List<Map<String, Object?>> linesOf(int id, LineSection s) => [
    for (final l in linesBy[id] ?? const <RecipeLineRow>[])
      if (l.section == s) {'text': l.body, 'heading': l.isHeading},
  ];

  return {
    'recipes': [
      for (final r in recipes)
        {
          'id': r.id,
          'name': r.name,
          'servings': r.servings,
          'servingsUnit': r.servingsUnit,
          'prepMinutes': r.prepMinutes,
          'cookMinutes': r.cookMinutes,
          'totalMinutes': r.totalMinutes,
          'source': r.source,
          'sourceUrl': r.sourceUrl,
          'notes': r.notes,
          'nutrition': r.nutrition,
          'difficulty': r.difficulty?.name,
          'rating': r.rating,
          'favorite': r.favorite,
          'createdAt': _iso(r.createdAt),
          'updatedAt': _iso(r.updatedAt),
          'deletedAt': r.deletedAt == null ? null : _iso(r.deletedAt!),
          'ingredients': linesOf(r.id, LineSection.ingredient),
          'steps': linesOf(r.id, LineSection.step),
          'photos': [
            for (final p in photosBy[r.id] ?? const <RecipePhotoRow>[])
              p.fileName,
          ],
          'categoryIds': [
            for (final l in linksBy[r.id] ?? const <RecipeCategory>[])
              l.categoryId,
          ]..sort(),
          'tags': [for (final t in tagsBy[r.id] ?? const <RecipeTag>[]) t.tag],
          'cooked': [
            for (final c in cookedBy[r.id] ?? const <CookLogRow>[])
              _iso(c.cookedAt),
          ],
        },
    ],
    'categories': [
      for (final c in categories)
        {
          'id': c.id,
          'name': c.name,
          'parentId': c.parentId,
          'position': c.position,
        },
    ],
    'settings': {
      for (final s in settings)
        if (_portableSettings.contains(s.key)) s.key: s.value,
    },
  };
}

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

/// Nạp [data] vào cơ sở dữ liệu trong MỘT giao dịch: lỗi giữa chừng thì không
/// đổi gì. [replace] xóa dữ liệu cũ và giữ nguyên id; không thì chỉ thêm công
/// thức chưa có (AC-54).
Future<ImportSummary> importData(
  AppDatabase db,
  Map<String, Object?> data, {
  required bool replace,
}) async {
  final recipes = _maps(data['recipes'], 'recipes');
  final categories = _maps(data['categories'], 'categories');
  final settings = data['settings'];

  return db.transaction(() async {
    if (replace) {
      for (final t in <TableInfo<Table, dynamic>>[
        db.cookLog,
        db.recipeTags,
        db.recipeCategories,
        db.recipePhotos,
        db.recipeLines,
        db.recipes,
      ]) {
        await db.delete(t).go();
      }
      await db.delete(db.categories).go();
    }

    // Danh mục: cha trước con. Ánh xạ id trong file -> id trong máy này.
    final byId = {for (final c in categories) _need<int>(c, 'id'): c};
    final depthOf = <int, int>{};
    int depth(int id) => depthOf[id] ??= () {
      final p = byId[id]?['parentId'];
      return p is int && byId.containsKey(p) ? depth(p) + 1 : 1;
    }();
    final ordered = byId.keys.toList()
      ..sort((a, b) => depth(a).compareTo(depth(b)));

    final idMap = <int, int>{};
    if (replace) {
      for (final id in ordered) {
        final c = byId[id]!;
        final parent = c['parentId'];
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: Value(id),
                name: _need<String>(c, 'name'),
                parentId: Value(parent is int ? parent : null),
                position: Value((c['position'] as int?) ?? 0),
              ),
            );
        idMap[id] = id;
      }
    } else {
      final local = await db.select(db.categories).get();
      final localById = {for (final c in local) c.id: c};
      String pathOf(CategoryRow c) {
        final names = [normalizeText(c.name)];
        var p = c.parentId;
        while (p != null && localById[p] != null) {
          names.insert(0, normalizeText(localById[p]!.name));
          p = localById[p]!.parentId;
        }
        return names.join('/');
      }

      final pathToId = {for (final c in local) pathOf(c): c.id};
      final fileNames = <int, String>{};
      for (final id in ordered) {
        final c = byId[id]!;
        final parent = c['parentId'];
        final parentFileId = parent is int && byId.containsKey(parent)
            ? parent
            : null;
        final path = parentFileId == null
            ? normalizeText(_need<String>(c, 'name'))
            : '${fileNames[parentFileId]}/${normalizeText(_need<String>(c, 'name'))}';
        fileNames[id] = path;
        final existing = pathToId[path];
        if (existing != null) {
          idMap[id] = existing;
          continue;
        }
        final newId = await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                name: _need<String>(c, 'name'),
                parentId: Value(
                  parentFileId == null ? null : idMap[parentFileId],
                ),
                position: Value((c['position'] as int?) ?? 0),
              ),
            );
        pathToId[path] = newId;
        idMap[id] = newId;
      }
    }

    // Công thức đã có trong máy (chỉ khi gộp): cùng tên và cùng thời điểm tạo.
    final have = <String>{};
    if (!replace) {
      for (final r in await db.select(db.recipes).get()) {
        have.add(
          '${normalizeText(r.name)}|${r.createdAt.millisecondsSinceEpoch ~/ 1000}',
        );
      }
    }

    var added = 0;
    var skipped = 0;
    for (final r in recipes) {
      final created = _parse(_need<String>(r, 'createdAt'));
      final name = _need<String>(r, 'name');
      final key =
          '${normalizeText(name)}|${created.millisecondsSinceEpoch ~/ 1000}';
      if (!replace && !have.add(key)) {
        skipped++;
        continue;
      }
      final ingredients = _maps(r['ingredients'], 'ingredients');
      final steps = _maps(r['steps'], 'steps');
      final keys = buildSearchKeys(
        name: name,
        ingredients: ingredients.map((l) => '${l['text']}').join('\n'),
        steps: steps.map((l) => '${l['text']}').join('\n'),
        notes: r['notes'] as String?,
        source: r['source'] as String?,
      );
      final id = await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              id: replace ? Value(_need<int>(r, 'id')) : const Value.absent(),
              name: name,
              servings: Value((r['servings'] as num?)?.toDouble()),
              servingsUnit: Value(r['servingsUnit'] as String?),
              prepMinutes: Value(r['prepMinutes'] as int?),
              cookMinutes: Value(r['cookMinutes'] as int?),
              totalMinutes: Value(r['totalMinutes'] as int?),
              source: Value(r['source'] as String?),
              sourceUrl: Value(r['sourceUrl'] as String?),
              notes: Value(r['notes'] as String?),
              nutrition: Value(r['nutrition'] as String?),
              difficulty: Value(Difficulty.values.asNameMap()[r['difficulty']]),
              rating: Value((r['rating'] as int?) ?? 0),
              favorite: Value((r['favorite'] as bool?) ?? false),
              createdAt: created,
              updatedAt: _parse(_need<String>(r, 'updatedAt')),
              deletedAt: Value(
                r['deletedAt'] == null ? null : _parse(r['deletedAt']),
              ),
              searchKey: Value(keys.search),
              ingredientsKey: Value(keys.ingredients),
            ),
          );
      var position = 0;
      for (final (section, list) in [
        (LineSection.ingredient, ingredients),
        (LineSection.step, steps),
      ]) {
        for (final l in list) {
          await db
              .into(db.recipeLines)
              .insert(
                RecipeLinesCompanion.insert(
                  recipeId: id,
                  section: section,
                  position: position++,
                  isHeading: Value((l['heading'] as bool?) ?? false),
                  body: _need<String>(l, 'text'),
                ),
              );
        }
      }
      final photos = (r['photos'] as List? ?? const []).cast<String>();
      for (var i = 0; i < photos.length; i++) {
        await db
            .into(db.recipePhotos)
            .insert(
              RecipePhotosCompanion.insert(
                recipeId: id,
                fileName: photos[i],
                position: i,
              ),
            );
      }
      for (final c
          in (r['categoryIds'] as List? ?? const []).cast<int>().toSet()) {
        final mapped = idMap[c];
        if (mapped == null) continue;
        await db
            .into(db.recipeCategories)
            .insert(
              RecipeCategoriesCompanion.insert(
                recipeId: id,
                categoryId: mapped,
              ),
            );
      }
      final seenTags = <String>{};
      for (final t in (r['tags'] as List? ?? const []).cast<String>()) {
        final tagKey = normalizeText(t);
        if (t.trim().isEmpty || !seenTags.add(tagKey)) continue;
        await db
            .into(db.recipeTags)
            .insert(
              RecipeTagsCompanion.insert(recipeId: id, tag: t, tagKey: tagKey),
            );
      }
      for (final c in (r['cooked'] as List? ?? const []).cast<String>()) {
        await db
            .into(db.cookLog)
            .insert(CookLogCompanion.insert(recipeId: id, cookedAt: _parse(c)));
      }
      added++;
    }

    if (replace && settings is Map) {
      for (final e in settings.entries) {
        if (_portableSettings.contains(e.key) && e.value is String) {
          await db
              .into(db.settings)
              .insertOnConflictUpdate(
                SettingsCompanion.insert(
                  key: e.key as String,
                  value: e.value as String,
                ),
              );
        }
      }
    }
    return ImportSummary(recipesAdded: added, recipesSkipped: skipped);
  });
}
