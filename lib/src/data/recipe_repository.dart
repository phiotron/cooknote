import 'package:drift/drift.dart';

import 'database.dart';
import 'image_store.dart';
import 'recipe_lines.dart';

/// Giới hạn của một công thức (AC-02).
const maxRecipeName = 200;
const maxRecipePhotos = 20;

/// Số ngày công thức nằm trong thùng rác trước khi bị xóa hẳn (AC-05).
const trashDays = 30;

enum RecipeProblem { emptyName, nameTooLong, tooManyPhotos, badRating }

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

  RecipeDraft copyWith({
    String? name,
    int? rating,
    bool? favorite,
    List<RecipeLine>? ingredients,
    List<RecipeLine>? steps,
    List<String>? photos,
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
  );

  /// Lỗi đầu tiên khiến công thức không lưu được; null là hợp lệ.
  RecipeProblem? get problem {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return RecipeProblem.emptyName;
    if (trimmed.length > maxRecipeName) return RecipeProblem.nameTooLong;
    if (photos.length > maxRecipePhotos) return RecipeProblem.tooManyPhotos;
    if (rating < 0 || rating > 5) return RecipeProblem.badRating;
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
      _listEquals(other.photos, photos);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(_fields),
    Object.hashAll(ingredients),
    Object.hashAll(steps),
    Object.hashAll(photos),
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
  });

  final int id;
  final RecipeDraft draft;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String? get coverPhoto => draft.photos.isEmpty ? null : draft.photos.first;
}

/// Dòng trong danh sách công thức.
class RecipeSummary {
  const RecipeSummary({
    required this.id,
    required this.name,
    required this.rating,
    required this.favorite,
    required this.updatedAt,
    this.totalMinutes,
    this.coverPhoto,
    this.deletedAt,
  });

  final int id;
  final String name;
  final int rating;
  final bool favorite;
  final DateTime updatedAt;
  final int? totalMinutes;
  final String? coverPhoto;
  final DateTime? deletedAt;
}

/// Đọc, ghi công thức (F-01). Mỗi lần lưu là một giao dịch (AC-04).
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
      ]),
    );
  }

  /// Công thức đang dùng, mới sửa ở trên.
  Stream<List<RecipeSummary>> watchRecipes() =>
      _changes().asyncMap((_) => _summaries(trashed: false));

  /// Công thức trong thùng rác, mới xóa ở trên (AC-05).
  Stream<List<RecipeSummary>> watchTrash() =>
      _changes().asyncMap((_) => _summaries(trashed: true));

  Stream<RecipeDetail?> watchRecipe(int id) =>
      _changes().asyncMap((_) => getRecipe(id));

  Future<List<RecipeSummary>> _summaries({required bool trashed}) async {
    final query = _db.select(_db.recipes)
      ..where((r) => trashed ? r.deletedAt.isNotNull() : r.deletedAt.isNull())
      ..orderBy([
        (r) => OrderingTerm.desc(trashed ? r.deletedAt : r.updatedAt),
        (r) => OrderingTerm.desc(r.id),
      ]);
    final rows = await query.get();
    final covers = await (_db.select(
      _db.recipePhotos,
    )..where((p) => p.position.equals(0))).get();
    final coverOf = {for (final c in covers) c.recipeId: c.fileName};
    return [
      for (final r in rows)
        RecipeSummary(
          id: r.id,
          name: r.name,
          rating: r.rating,
          favorite: r.favorite,
          updatedAt: r.updatedAt,
          totalMinutes: r.totalMinutes,
          coverPhoto: coverOf[r.id],
          deletedAt: r.deletedAt,
        ),
    ];
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
    return RecipeDetail(
      id: r.id,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
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

  RecipesCompanion _companion(RecipeDraft d) => RecipesCompanion(
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
  );

  /// Lưu công thức mới ([id] null) hoặc thay toàn bộ nội dung công thức [id].
  /// Ảnh bị gỡ khỏi công thức thì file ảnh bị xóa sau khi lưu xong (AC-07).
  Future<int> save(RecipeDraft draft, {int? id}) async {
    final problem = draft.problem;
    if (problem != null) throw RecipeValidationException(problem);
    final now = _clock();
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
        await (_db.delete(
          _db.recipeLines,
        )..where((l) => l.recipeId.equals(id))).go();
        await (_db.delete(
          _db.recipePhotos,
        )..where((p) => p.recipeId.equals(id))).go();
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
      });
      return rid;
    });
    for (final f in removed) {
      await _images.delete(f);
    }
    return recipeId;
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

  /// Xóa hẳn công thức cùng ảnh của nó.
  Future<void> deleteForever(int id) async {
    final photos = await _photosOf(id);
    await _db.transaction(() async {
      await (_db.delete(
        _db.recipeLines,
      )..where((l) => l.recipeId.equals(id))).go();
      await (_db.delete(
        _db.recipePhotos,
      )..where((p) => p.recipeId.equals(id))).go();
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
}
