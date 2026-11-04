/// Cách sắp xếp danh sách công thức (AC-13).
enum RecipeSort { name, created, updated, rating, cookTime, lastCooked }

/// Ô tìm chữ, bộ lọc và cách sắp xếp của danh sách công thức (AC-12, AC-13).
/// Mặc định: mới sửa trước, không lọc.
class RecipeQuery {
  const RecipeQuery({
    this.text = '',
    this.categoryIds = const {},
    this.tags = const {},
    this.minRating = 0,
    this.favoriteOnly = false,
    this.maxTotalMinutes,
    this.ingredient = '',
    this.sort = RecipeSort.updated,
    this.ascending = false,
  });

  final String text;
  final Set<int> categoryIds;
  final Set<String> tags;
  final int minRating;
  final bool favoriteOnly;
  final int? maxTotalMinutes;

  /// Chữ cần có trong nguyên liệu ("có nguyên liệu X").
  final String ingredient;
  final RecipeSort sort;

  /// Tăng dần; mặc định giảm dần (mới nhất, cao nhất, lâu nhất trước).
  final bool ascending;

  /// Có ô tìm hoặc bộ lọc nào đang bật không (cách sắp xếp không tính).
  bool get isFiltering =>
      text.trim().isNotEmpty ||
      categoryIds.isNotEmpty ||
      tags.isNotEmpty ||
      minRating > 0 ||
      favoriteOnly ||
      maxTotalMinutes != null ||
      ingredient.trim().isNotEmpty;

  /// Số bộ lọc đang bật, để hiện trên nút Lọc (ô tìm không tính).
  int get filterCount =>
      (categoryIds.isEmpty ? 0 : 1) +
      (tags.isEmpty ? 0 : 1) +
      (minRating > 0 ? 1 : 0) +
      (favoriteOnly ? 1 : 0) +
      (maxTotalMinutes == null ? 0 : 1) +
      (ingredient.trim().isEmpty ? 0 : 1);

  RecipeQuery copyWith({
    String? text,
    Set<int>? categoryIds,
    Set<String>? tags,
    int? minRating,
    bool? favoriteOnly,
    int? maxTotalMinutes,
    bool clearMaxTotalMinutes = false,
    String? ingredient,
    RecipeSort? sort,
    bool? ascending,
  }) => RecipeQuery(
    text: text ?? this.text,
    categoryIds: categoryIds ?? this.categoryIds,
    tags: tags ?? this.tags,
    minRating: minRating ?? this.minRating,
    favoriteOnly: favoriteOnly ?? this.favoriteOnly,
    maxTotalMinutes: clearMaxTotalMinutes
        ? null
        : maxTotalMinutes ?? this.maxTotalMinutes,
    ingredient: ingredient ?? this.ingredient,
    sort: sort ?? this.sort,
    ascending: ascending ?? this.ascending,
  );

  /// Bỏ mọi bộ lọc và ô tìm, giữ cách sắp xếp.
  RecipeQuery cleared() => RecipeQuery(sort: sort, ascending: ascending);

  @override
  bool operator ==(Object other) =>
      other is RecipeQuery &&
      other.text == text &&
      _setEquals(other.categoryIds, categoryIds) &&
      _setEquals(other.tags, tags) &&
      other.minRating == minRating &&
      other.favoriteOnly == favoriteOnly &&
      other.maxTotalMinutes == maxTotalMinutes &&
      other.ingredient == ingredient &&
      other.sort == sort &&
      other.ascending == ascending;

  @override
  int get hashCode => Object.hash(
    text,
    Object.hashAllUnordered(categoryIds),
    Object.hashAllUnordered(tags),
    minRating,
    favoriteOnly,
    maxTotalMinutes,
    ingredient,
    sort,
    ascending,
  );
}

bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
