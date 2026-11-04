import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';

/// Các dòng đã gạch của một công thức trong chế độ nấu (AC-26).
class CookProgress {
  const CookProgress({
    this.ingredients = const {},
    this.steps = const {},
    this.fontScale,
  });

  /// Vị trí (trong danh sách nguyên liệu, tính cả dòng tiêu đề) đã gạch.
  final Set<int> ingredients;
  final Set<int> steps;
  final double? fontScale;

  static const empty = CookProgress();

  CookProgress toggleIngredient(int i) =>
      CookProgress(ingredients: _toggle(ingredients, i), steps: steps);

  CookProgress toggleStep(int i) =>
      CookProgress(ingredients: ingredients, steps: _toggle(steps, i));

  static Set<int> _toggle(Set<int> s, int i) =>
      s.contains(i) ? ({...s}..remove(i)) : {...s, i};

  /// Bước đang làm: bước đầu tiên chưa gạch; null nếu đã gạch hết.
  int? currentStep(int stepCount, {Set<int> skip = const {}}) {
    for (var i = 0; i < stepCount; i++) {
      if (!steps.contains(i) && !skip.contains(i)) return i;
    }
    return null;
  }

  bool get isEmpty => ingredients.isEmpty && steps.isEmpty;
}

/// Lưu trạng thái chế độ nấu và các ghim ở bảng `settings` có sẵn (không thêm
/// bảng). Khóa `cook.strike.<id>` hết hạn sau [strikeLifetime] kể từ lần đổi
/// cuối. Các khóa này không nằm trong danh sách khóa đi theo sao lưu.
class CookStore {
  CookStore(this._db, this._clock);

  final AppDatabase _db;
  final DateTime Function() _clock;

  static const strikeLifetime = Duration(hours: 12);
  static const maxPins = 5;
  static const pinsKey = 'cook.pins';
  static const fontKey = 'cook.fontScale';
  static const minFontScale = 1.0;
  static const maxFontScale = 2.0;
  static const defaultFontScale = 1.3;
  static const notifAskedKey = 'cook.notifAsked';

  static String strikeKey(int id) => 'cook.strike.$id';

  Future<String?> _read(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _write(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<void> _remove(String key) =>
      (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();

  /// Đọc các dòng đã gạch; quá 12 giờ thì bỏ và xóa khỏi bảng.
  Future<CookProgress> loadProgress(int recipeId) async {
    final raw = await _read(strikeKey(recipeId));
    if (raw == null) return CookProgress.empty;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.fromMillisecondsSinceEpoch(m['at'] as int);
      final age = _clock().difference(at);
      if (age > strikeLifetime || age.isNegative) {
        await _remove(strikeKey(recipeId));
        return CookProgress.empty;
      }
      return CookProgress(
        ingredients: {for (final i in (m['ing'] as List)) i as int},
        steps: {for (final i in (m['steps'] as List)) i as int},
      );
    } on Object {
      await _remove(strikeKey(recipeId));
      return CookProgress.empty;
    }
  }

  Future<void> saveProgress(int recipeId, CookProgress p) {
    if (p.isEmpty) return _remove(strikeKey(recipeId));
    return _write(
      strikeKey(recipeId),
      jsonEncode({
        'at': _clock().millisecondsSinceEpoch,
        'ing': p.ingredients.toList()..sort(),
        'steps': p.steps.toList()..sort(),
      }),
    );
  }

  Future<void> clearProgress(int recipeId) => _remove(strikeKey(recipeId));

  // ---- Ghim (AC-29) ----

  List<int> _decodePins(String? raw) {
    if (raw == null) return const [];
    try {
      return [
        for (final v in jsonDecode(raw) as List)
          if (v is int) v,
      ].take(maxPins).toList();
    } on Object {
      return const [];
    }
  }

  Stream<List<int>> watchPins() =>
      (_db.select(_db.settings)..where((s) => s.key.equals(pinsKey)))
          .watchSingleOrNull()
          .map((row) => _decodePins(row?.value));

  Future<List<int>> pins() async => _decodePins(await _read(pinsKey));

  /// Ghim [id]; false nếu đã đủ [maxPins] ghim khác.
  Future<bool> pin(int id) async {
    final now = await pins();
    if (now.contains(id)) return true;
    if (now.length >= maxPins) return false;
    await _write(pinsKey, jsonEncode([...now, id]));
    return true;
  }

  Future<void> unpin(int id) async {
    final now = await pins();
    if (!now.contains(id)) return;
    await _write(pinsKey, jsonEncode([...now]..remove(id)));
  }

  // ---- Cỡ chữ ----

  Future<double> fontScale() async {
    final v = double.tryParse(await _read(fontKey) ?? '');
    return (v ?? defaultFontScale).clamp(minFontScale, maxFontScale);
  }

  Future<void> setFontScale(double v) => _write(
    fontKey,
    v.clamp(minFontScale, maxFontScale).toStringAsFixed(2),
  );

  // ---- Đã hỏi quyền thông báo chưa ----

  Future<bool> notificationAsked() async => await _read(notifAskedKey) == '1';

  Future<void> setNotificationAsked() => _write(notifAskedKey, '1');
}
