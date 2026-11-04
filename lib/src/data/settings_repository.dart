import 'package:flutter/material.dart';

import 'database.dart';

/// Đọc, ghi cài đặt trong bảng khóa-giá trị, nằm cùng cơ sở dữ liệu.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const themeModeKey = 'themeMode';
  static const localeKey = 'locale';

  Stream<String?> _watch(String key) =>
      (_db.select(_db.settings)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> _write(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<void> _remove(String key) =>
      (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();

  /// Giao diện sáng, tối hoặc theo hệ thống; mặc định theo hệ thống.
  Stream<ThemeMode> watchThemeMode() =>
      _watch(themeModeKey)
          .map((v) => ThemeMode.values.asNameMap()[v] ?? ThemeMode.system);

  Future<void> setThemeMode(ThemeMode mode) => _write(themeModeKey, mode.name);

  /// Mã ngôn ngữ đã chọn; null là theo ngôn ngữ máy.
  Stream<String?> watchLocaleCode() => _watch(localeKey);

  Future<void> setLocaleCode(String? code) =>
      code == null ? _remove(localeKey) : _write(localeKey, code);

  static const viewModeKey = 'viewMode';

  /// Mã ngôn ngữ đã chọn một lần, không theo dõi thay đổi.
  Future<String?> readLocaleCode() => watchLocaleCode().first;

  /// Cách xem danh sách công thức: `list` (mặc định) hoặc `grid` (AC-14).
  Stream<String> watchViewMode() =>
      _watch(viewModeKey).map((v) => v == 'grid' ? 'grid' : 'list');

  Future<void> setViewMode(String mode) =>
      _write(viewModeKey, mode == 'grid' ? 'grid' : 'list');
}
