import 'package:drift/drift.dart';

import 'category_repository.dart';
import 'database.dart';
import 'image_store.dart';
import 'recipe_lines.dart';
import 'recipe_query.dart';
import 'text_normalize.dart';
import '../web_import/source_url.dart';

/// Giới hạn của một công thức (AC-02, AC-11).
const maxRecipeName = 200;
const maxRecipePhotos = 20;
const maxTagLength = 40;

/// Số ngày công thức nằm trong thùng rác trước khi bị xóa hẳn (AC-05).
const trashDays = 30;

enum RecipeProblem {
  emptyName,
  nameTooLong,
  tooManyPhotos,
  badRating,
  tagTooLong,
}

class RecipeValidationException implements Exception {
  const RecipeValidationException(this.problem);

  final RecipeProblem problem;

  @override
  String toString() => 'RecipeValidationException($problem)';
}

/// Nội dung người dùng soạn cho một công thức (AC-02). [photos] là tên file
/// trong [ImageStore], ảnh đầu tiên là ảnh bìa.
class RecipeDraft {
  const RecipeDraft({
    required this.name,
    this.servings,
    this.servingsUnit,
    this.prepMinutes,
    this.cookMinutes,
    this.totalMinutes,
    this.source,
    this.sourceUrl,
    this.notes,
    this.nutrition,
    this.difficulty,
    this.rating = 0,
    this.favorite = false,
    this.ingredients = const [],
    this.steps = const [],
    this.photos = const [],
    this.categoryIds = const [],
    this.tags = const [],
  });

  final String name;
  final double? servings;
  final String? servingsUnit;
  final int? prepMinutes;
  final int? cookMinutes;
  final int? totalMinutes;
  final String? source;
  final String? sourceUrl;
  final String? notes;
  final String? nutrition;
  final Difficulty? difficulty;
  final int rating;
  final bool favorite;
  final List<RecipeLine> ingredients;
  final List<RecipeLine> steps;
  final List<String> photos;

  /// Danh mục công thức thuộc về (AC-10), không có thứ tự.
  final List<int> categoryIds;

  /// Thẻ tự do (AC-11).
  final List<String> tags;

  RecipeDraft copyWith({
    String? name,
    int? rating,
    bool? favorite,
    List<RecipeLine>? ingredients,
    List<RecipeLine>? steps,
    List<String>? photos,
    List<int>? categoryIds,
    List<String>? tags,
  }) => RecipeDraft(
    name: name ?? this.name,
    servings: servings,
    servingsUnit: servingsUnit,
    prepMinutes: prepMinutes,
    cookMinutes: cookMinutes,
    totalMinutes: totalMinutes,
    source: source,
    sourceUrl: sourceUrl,
    notes: notes,
    nutrition: nutrition,
    difficulty: difficulty,
    rating: rating ?? this.rating,
    favorite: favorite ?? this.favorite,
    ingredients: ingredients ?? this.ingredients,
    steps: steps ?? this.steps,
    photos: photos ?? this.photos,
    categoryIds: categoryIds ?? this.categoryIds,
    tags: tags ?? this.tags,
  );

  /// Lỗi đầu tiên khiến công thức không lưu được; null là hợp lệ.
  RecipeProblem? get problem {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return RecipeProblem.emptyName;
    if (trimmed.length > maxRecipeName) return RecipeProblem.nameTooLong;
    if (photos.length > maxRecipePhotos) return RecipeProblem.tooManyPhotos;
    if (rating < 0 || rating > 5) return RecipeProblem.badRating;
    if (tags.any((t) => t.trim().length > maxTagLength)) {
      return RecipeProblem.tagTooLong;
    }
    return null;
  }

  List<Object?> get _fields => [
    name,
    servings,
    servingsUnit,
    prepMinutes,
    cookMinutes,
    totalMinutes,
    source,
    sourceUrl,
    notes,
    nutrition,
    difficulty,
    rating,
    favorite,
  ];

  @override
  bool operator ==(Object other) =>
      other is RecipeDraft &&
      _listEquals(other._fields, _fields) &&
      _listEquals(other.ingredients, ingredients) &&
      _listEquals(other.steps, steps) &&
      _listEquals(other.photos, photos) &&
      _listEquals(other.categoryIds, categoryIds) &&
      _listEquals(other.tags, tags);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(_fields),
    Object.hashAll(ingredients),
    Object.hashAll(steps),
    Object.hashAll(photos),
    Object.hashAll(categoryIds),
    Object.hashAll(tags),
  );
}

bool _listEquals(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Một công thức đã lưu cùng nội dung đầy đủ.
class RecipeDetail {
  const RecipeDetail({
    required this.id,
    required this.draft,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.cookCount = 0,
    this.lastCookedAt,
  });

  final int id;
  final RecipeDraft draft;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Số lần "Đã nấu" và lần gần nhất (AC-15).
  final int cookCount;
  final DateTime? lastCookedAt;

  String? get coverPhoto => draft.photos.isEmpty ? null : draft.photos.first;
}

/// Dòng trong danh sách công thức.
class RecipeSummary {
  const RecipeSummary({
    required this.id,
    required this.name,
    required this.rating,
    required this.favorite,
    required this.createdAt,
    required this.updatedAt,
    this.totalMinutes,
    this.cookMinutes,
    this.coverPhoto,
    this.deletedAt,
    this.cookCount = 0,
    this.lastCookedAt,
  });

  final int id;
  final String name;
  final int rating;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? totalMinutes;
  final int? cookMinutes;
  final String? coverPhoto;
  final DateTime? deletedAt;
  final int cookCount;
  final DateTime? lastCookedAt;
}

/// Một thẻ kèm số công thức đang dùng.
class TagCount {
  const TagCount(this.tag, this.count);

  final String tag;
  final int count;
}

/// Đọc, ghi, tìm công thức (F-01, F-02). Mỗi lần lưu là một giao dịch (AC-04).
class RecipeRepository {
  RecipeRepository(this._db, this._images, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final ImageStore _images;
  final DateTime Function() _clock;

  Stream<void> _changes() async* {
    yield null;
    yield* _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.recipes,
        _db.recipeLines,
        _db.recipePhotos,
        _db.recipeCategories,
        _db.recipeTags,
        _db.cookLog,
        _db.categories,
      ]),
    );
  }

  /// Công thức đang dùng khớp [query] (mặc định: tất cả, mới sửa ở trên).
  Stream<List<RecipeSummary>> watchRecipes({
    RecipeQuery query = const RecipeQuery(),
  }) => _changes().asyncMap((_) => search(query));

  /// Số công thức đang dùng, không tính thùng rác.
  Stream<int> watchCount() {
    final count = _db.recipes.id.count();
    return (_db.selectOnly(_db.recipes)
          ..addColumns([count])
          ..where(_db.recipes.deletedAt.isNull()))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

  /// Công thức trong thùng rác, mới xóa ở trên (AC-05).
  Stream<List<RecipeSummary>> watchTrash() =>
      _changes().asyncMap((_) => _summaries(trashed: true));

  Stream<RecipeDetail?> watchRecipe(int id) =>
      _changes().asyncMap((_) => getRecipe(id));

  /// Tìm và lọc công thức đang dùng (AC-12, AC-13).
  Future<List<RecipeSummary>> search(RecipeQuery query) =>
      _summaries(trashed: false, query: query);

  Future<List<RecipeSummary>> _summaries({
    required bool trashed,
    RecipeQuery query = const RecipeQuery(),
  }) async {
    Set<int>? categoryIds;
    if (!trashed && query.categoryIds.isNotEmpty) {
      final all = await CategoryRepository(_db).getAll();
      categoryIds = {
        for (final id in query.categoryIds) ...descendantIds(all, id),
      };
    }
    final stmt = _db.select(_db.recipes)
      ..where((r) {
        Expression<bool> cond = trashed
            ? r.deletedAt.isNotNull()
            : r.deletedAt.isNull();
        if (trashed) return cond;
        for (final t in searchTerms(query.text)) {
          cond = cond & r.searchKey.like('%$t%');
        }
        for (final t in searchTerms(query.ingredient)) {
          cond = cond & r.ingredientsKey.like('%$t%');
        }
        if (query.minRating > 0) {
          cond = cond & r.rating.isBiggerOrEqualValue(query.minRating);
        }
        if (query.favoriteOnly) cond = cond & r.favorite.equals(true);
        final maxTotal = query.maxTotalMinutes;
        if (maxTotal != null) {
          cond = cond & r.totalMinutes.isSmallerOrEqualValue(maxTotal);
        }
        if (categoryIds != null) {
          final inCategory = _db.selectOnly(_db.recipeCategories)
            ..addColumns([_db.recipeCategories.recipeId])
            ..where(_db.recipeCategories.categoryId.isIn(categoryIds));
          cond = cond & r.id.isInQuery(inCategory);
        }
        for (final tag in query.tags) {
          final withTag = _db.selectOnly(_db.recipeTags)
            ..addColumns([_db.recipeTags.recipeId])
            ..where(_db.recipeTags.tagKey.equals(normalizeText(tag)));
          cond = cond & r.id.isInQuery(withTag);
        }
        return cond;
      });
    final rows = await stmt.get();
    final covers = await (_db.select(
      _db.recipePhotos,
    )..where((p) => p.position.equals(0))).get();
    final coverOf = {for (final c in covers) c.recipeId: c.fileName};

    final cookCount = _db.cookLog.id.count();
    final lastCooked = _db.cookLog.cookedAt.max();
    final stats =
        await (_db.selectOnly(_db.cookLog)
              ..addColumns([_db.cookLog.recipeId, cookCount, lastCooked])
              ..groupBy([_db.cookLog.recipeId]))
            .get();
    final statOf = {
      for (final s in stats)
        s.read(_db.cookLog.recipeId)!: (
          s.read(cookCount) ?? 0,
          s.read(lastCooked),
        ),
    };

    final list = [
      for (final r in rows)
        RecipeSummary(
          id: r.id,
          name: r.name,
          rating: r.rating,
          favorite: r.favorite,
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
          totalMinutes: r.totalMinutes,
          cookMinutes: r.cookMinutes,
          coverPhoto: coverOf[r.id],
          deletedAt: r.deletedAt,
          cookCount: statOf[r.id]?.$1 ?? 0,
          lastCookedAt: statOf[r.id]?.$2,
        ),
    ];
    if (trashed) {
      list.sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
    } else {
      _sort(list, query);
    }
    return list;
  }

  /// Sắp xếp theo [query]. Mục thiếu giá trị (chưa ghi thời gian, chưa nấu)
  /// luôn xếp cuối; bằng nhau thì theo tên không dấu (AC-13).
  void _sort(List<RecipeSummary> list, RecipeQuery query) {
    final dir = query.ascending ? 1 : -1;
    final keys = {for (final r in list) r.id: normalizeText(r.name)};
    int byName(RecipeSummary a, RecipeSummary b) {
      final c = keys[a.id]!.compareTo(keys[b.id]!);
      return c != 0 ? c : a.id.compareTo(b.id);
    }

    int nullsLast<T extends Comparable<Object>>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b) * dir;
    }

    list.sort((a, b) {
      final c = switch (query.sort) {
        RecipeSort.name => byName(a, b) * dir,
        RecipeSort.created => a.createdAt.compareTo(b.createdAt) * dir,
        RecipeSort.updated => a.updatedAt.compareTo(b.updatedAt) * dir,
        RecipeSort.rating => a.rating.compareTo(b.rating) * dir,
        RecipeSort.cookTime => nullsLast(a.cookMinutes, b.cookMinutes),
        RecipeSort.lastCooked => nullsLast(a.lastCookedAt, b.lastCookedAt),
      };
      return c != 0 ? c : byName(a, b);
    });
  }

  Future<RecipeDetail?> getRecipe(int id) async {
    final r = await (_db.select(
      _db.recipes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (r == null) return null;
    final lines =
        await (_db.select(_db.recipeLines)
              ..where((l) => l.recipeId.equals(id))
              ..orderBy([(l) => OrderingTerm.asc(l.position)]))
            .get();
    List<RecipeLine> of(LineSection s) => [
      for (final l in lines.where((l) => l.section == s))
        RecipeLine(l.body, isHeading: l.isHeading),
    ];
    final categoryRows = await (_db.select(
      _db.recipeCategories,
    )..where((c) => c.recipeId.equals(id))).get();
    final tagRows =
        await (_db.select(_db.recipeTags)
              ..where((t) => t.recipeId.equals(id))
              ..orderBy([
                (t) => OrderingTerm.asc(CustomExpression<int>('rowid')),
              ]))
            .get();
    final history = await cookHistory(id);
    return RecipeDetail(
      id: r.id,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
      cookCount: history.length,
      lastCookedAt: history.isEmpty ? null : history.first,
      draft: RecipeDraft(
        name: r.name,
        servings: r.servings,
        servingsUnit: r.servingsUnit,
        prepMinutes: r.prepMinutes,
        cookMinutes: r.cookMinutes,
        totalMinutes: r.totalMinutes,
        source: r.source,
        sourceUrl: r.sourceUrl,
        notes: r.notes,
        nutrition: r.nutrition,
        difficulty: r.difficulty,
        rating: r.rating,
        favorite: r.favorite,
        ingredients: of(LineSection.ingredient),
        steps: of(LineSection.step),
        photos: await _photosOf(id),
        categoryIds: [for (final c in categoryRows) c.categoryId]..sort(),
        tags: [for (final t in tagRows) t.tag],
      ),
    );
  }

  Future<List<String>> _photosOf(int id) async {
    final rows =
        await (_db.select(_db.recipePhotos)
              ..where((p) => p.recipeId.equals(id))
              ..orderBy([(p) => OrderingTerm.asc(p.position)]))
            .get();
    return [for (final p in rows) p.fileName];
  }

  RecipesCompanion _companion(RecipeDraft d) {
    final keys = buildSearchKeys(
      name: d.name,
      ingredients: d.ingredients.map((l) => l.text).join('\n'),
      steps: d.steps.map((l) => l.text).join('\n'),
      notes: d.notes,
      source: d.source,
    );
    return RecipesCompanion(
      name: Value(d.name.trim()),
      servings: Value(d.servings),
      servingsUnit: Value(d.servingsUnit),
      prepMinutes: Value(d.prepMinutes),
      cookMinutes: Value(d.cookMinutes),
      totalMinutes: Value(d.totalMinutes),
      source: Value(d.source),
      sourceUrl: Value(d.sourceUrl),
      notes: Value(d.notes),
      nutrition: Value(d.nutrition),
      difficulty: Value(d.difficulty),
      rating: Value(d.rating),
      favorite: Value(d.favorite),
      searchKey: Value(keys.search),
      ingredientsKey: Value(keys.ingredients),
    );
  }

  /// Thẻ đã bỏ khoảng trắng hai đầu, bỏ thẻ trống và thẻ trùng (không phân
  /// biệt hoa thường và dấu); giữ cách viết của lần đầu.
  List<(String, String)> _cleanTags(List<String> tags) {
    final seen = <String>{};
    final out = <(String, String)>[];
    for (final raw in tags) {
      final tag = raw.trim();
      if (tag.isEmpty) continue;
      final key = normalizeText(tag);
      if (seen.add(key)) out.add((tag, key));
    }
    return out;
  }

  /// Lưu công thức mới ([id] null) hoặc thay toàn bộ nội dung công thức [id].
  /// Ảnh bị gỡ khỏi công thức thì file ảnh bị xóa sau khi lưu xong (AC-07).
  Future<int> save(RecipeDraft draft, {int? id}) async {
    final problem = draft.problem;
    if (problem != null) throw RecipeValidationException(problem);
    final now = _clock();
    final tags = _cleanTags(draft.tags);
    final categoryIds = draft.categoryIds.toSet();
    var removed = <String>[];
    final recipeId = await _db.transaction(() async {
      final int rid;
      if (id == null) {
        rid = await _db
            .into(_db.recipes)
            .insert(
              _companion(draft)
                  .copyWith(createdAt: Value(now), updatedAt: Value(now)),
            );
      } else {
        final updated =
            await (_db.update(_db.recipes)..where((r) => r.id.equals(id)))
                .write(_companion(draft).copyWith(updatedAt: Value(now)));
        if (updated == 0) throw StateError('Không có công thức $id');
        final old = await _photosOf(id);
        removed = old.where((f) => !draft.photos.contains(f)).toList();
        await _clearChildren(id);
        rid = id;
      }
      await _db.batch((b) {
        var position = 0;
        for (final (section, lines) in [
          (LineSection.ingredient, draft.ingredients),
          (LineSection.step, draft.steps),
        ]) {
          for (final line in lines) {
            b.insert(
              _db.recipeLines,
              RecipeLinesCompanion.insert(
                recipeId: rid,
                section: section,
                position: position++,
                isHeading: Value(line.isHeading),
                body: line.text,
              ),
            );
          }
        }
        for (var i = 0; i < draft.photos.length; i++) {
          b.insert(
            _db.recipePhotos,
            RecipePhotosCompanion.insert(
              recipeId: rid,
              fileName: draft.photos[i],
              position: i,
            ),
          );
        }
        for (final c in categoryIds) {
          b.insert(
            _db.recipeCategories,
            RecipeCategoriesCompanion.insert(recipeId: rid, categoryId: c),
          );
        }
        for (final (tag, key) in tags) {
          b.insert(
            _db.recipeTags,
            RecipeTagsCompanion.insert(recipeId: rid, tag: tag, tagKey: key),
          );
        }
      });
      return rid;
    });
    for (final f in removed) {
      await _images.delete(f);
    }
    return recipeId;
  }

  /// Xóa dòng, ảnh, danh mục, thẻ của công thức (giữ lịch sử nấu).
  Future<void> _clearChildren(int id) async {
    await (_db.delete(
      _db.recipeLines,
    )..where((l) => l.recipeId.equals(id))).go();
    await (_db.delete(
      _db.recipePhotos,
    )..where((p) => p.recipeId.equals(id))).go();
    await (_db.delete(
      _db.recipeCategories,
    )..where((c) => c.recipeId.equals(id))).go();
    await (_db.delete(
      _db.recipeTags,
    )..where((t) => t.recipeId.equals(id))).go();
  }

  /// Đánh dấu yêu thích; không tính là sửa nội dung nên giữ ngày sửa.
  Future<void> setFavorite(int id, bool favorite) =>
      (_db.update(_db.recipes)..where((r) => r.id.equals(id))).write(
        RecipesCompanion(favorite: Value(favorite)),
      );

  Future<void> moveToTrash(int id) =>
      (_db.update(_db.recipes)..where((r) => r.id.equals(id))).write(
        RecipesCompanion(deletedAt: Value(_clock())),
      );

  Future<void> restore(int id) =>
      (_db.update(_db.recipes)..where((r) => r.id.equals(id))).write(
        const RecipesCompanion(deletedAt: Value(null)),
      );

  /// Xóa hẳn công thức cùng ảnh, danh mục, thẻ và lịch sử nấu của nó.
  Future<void> deleteForever(int id) async {
    final photos = await _photosOf(id);
    await _db.transaction(() async {
      await _clearChildren(id);
      await (_db.delete(_db.cookLog)..where((c) => c.recipeId.equals(id))).go();
      await (_db.delete(_db.recipes)..where((r) => r.id.equals(id))).go();
    });
    for (final f in photos) {
      await _images.delete(f);
    }
  }

  /// Xóa hẳn công thức đã nằm trong thùng rác đủ [trashDays] ngày; trả về số
  /// công thức đã xóa (AC-05).
  Future<int> purgeTrash() async {
    final cutoff = _clock().subtract(const Duration(days: trashDays));
    final expired = await (_db.select(
      _db.recipes,
    )..where((r) => r.deletedAt.isSmallerOrEqualValue(cutoff))).get();
    for (final r in expired) {
      await deleteForever(r.id);
    }
    return expired.length;
  }

  /// Tạo bản sao tên `<tên> (<copyLabel>)`, ảnh chép thành file riêng (AC-06).
  Future<int> duplicate(int id, {required String copyLabel}) async {
    final original = await getRecipe(id);
    if (original == null) throw StateError('Không có công thức $id');
    final suffix = ' ($copyLabel)';
    var base = original.draft.name;
    if (base.length + suffix.length > maxRecipeName) {
      base = base.substring(0, maxRecipeName - suffix.length).trimRight();
    }
    final photos = [
      for (final f in original.draft.photos) await _images.copy(f),
    ];
    return save(original.draft.copyWith(name: '$base$suffix', photos: photos));
  }

  /// Tên mọi file ảnh đang được công thức dùng, kể cả trong thùng rác.
  Future<Set<String>> referencedPhotos() async {
    final rows = await _db.select(_db.recipePhotos).get();
    return {for (final r in rows) r.fileName};
  }

  /// Id công thức (không ở thùng rác) có cùng URL nguồn sau khi chuẩn hóa
  /// bằng `normalizeSourceUrl` (AC-20); null nếu chưa có.
  Future<int?> findBySourceUrl(String url) async {
    final key = normalizeSourceUrl(url);
    if (key.isEmpty) return null;
    final rows =
        await (_db.select(_db.recipes)
              ..where((r) => r.sourceUrl.isNotNull() & r.deletedAt.isNull())
              ..orderBy([(r) => OrderingTerm.asc(r.id)]))
            .get();
    for (final r in rows) {
      if (normalizeSourceUrl(r.sourceUrl!) == key) return r.id;
    }
    return null;
  }

  /// Ghi một lần "Đã nấu" tại thời điểm hiện tại (AC-15). Không đổi ngày sửa.
  Future<void> markCooked(int id) => _db
      .into(_db.cookLog)
      .insert(CookLogCompanion.insert(recipeId: id, cookedAt: _clock()));

  /// Các lần đã nấu, mới nhất trước (AC-15).
  Future<List<DateTime>> cookHistory(int id) async {
    final rows =
        await (_db.select(_db.cookLog)
              ..where((c) => c.recipeId.equals(id))
              ..orderBy([
                (c) => OrderingTerm.desc(c.cookedAt),
                (c) => OrderingTerm.desc(c.id),
              ]))
            .get();
    return [for (final r in rows) r.cookedAt];
  }

  /// Thẻ đang dùng ở công thức chưa xóa, nhiều công thức nhất trước, rồi
  /// theo thứ tự không dấu. Cách viết hiển thị là cách viết phổ biến nhất.
  Future<List<TagCount>> allTags() async {
    final rows =
        await (_db.select(_db.recipeTags).join([
                innerJoin(
                  _db.recipes,
                  _db.recipes.id.equalsExp(_db.recipeTags.recipeId),
                ),
              ])
              ..where(_db.recipes.deletedAt.isNull())
              ..orderBy([
                OrderingTerm.asc(CustomExpression<int>('recipe_tags.rowid')),
              ]))
            .get();
    final spellings = <String, Map<String, int>>{};
    for (final row in rows) {
      final t = row.readTable(_db.recipeTags);
      final m = spellings.putIfAbsent(t.tagKey, () => {});
      m[t.tag] = (m[t.tag] ?? 0) + 1;
    }
    final list =
        [
          for (final e in spellings.entries)
            (
              e.key,
              // Cách viết nhiều nhất; bằng nhau thì cách viết gặp trước.
              e.value.entries.reduce((a, b) => b.value > a.value ? b : a).key,
              e.value.values.reduce((a, b) => a + b),
            ),
        ]..sort(
          (a, b) => b.$3 != a.$3 ? b.$3.compareTo(a.$3) : a.$1.compareTo(b.$1),
        );
    return [for (final (_, tag, n) in list) TagCount(tag, n)];
  }

  /// Gợi ý thẻ đã có khi gõ [prefix] (không phân biệt hoa thường và dấu).
  Future<List<String>> suggestTags(String prefix, {int limit = 20}) async {
    final key = normalizeText(prefix);
    return [
      for (final t in await allTags())
        if (normalizeText(t.tag).startsWith(key)) t.tag,
    ].take(limit).toList();
  }
}
