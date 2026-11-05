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

  // --- Phiên bản 3: lịch, đơn vị, tủ bếp, đi chợ (AC-37, AC-38, AC-43, AC-58).

  static const weekStartKey = 'weekStart';
  static const unitSystemKey = 'unitSystem';
  static const ignoreBasicsKey = 'ignoreBasics';
  static const shoppingToPantryKey = 'shoppingToPantry';

  static const _weekStarts = {
    'monday': DateTime.monday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  /// Ngày đầu tuần: `DateTime.monday` (mặc định), `DateTime.saturday` hoặc
  /// `DateTime.sunday` (AC-38, AC-58).
  Stream<int> watchWeekStart() =>
      _watch(weekStartKey).map((v) => _weekStarts[v] ?? DateTime.monday);

  Future<void> setWeekStart(int weekday) {
    final name = _weekStarts.entries
        .where((e) => e.value == weekday)
        .firstOrNull
        ?.key;
    if (name == null) {
      throw ArgumentError.value(weekday, 'weekday', 'chỉ thứ Hai, Bảy, CN');
    }
    return _write(weekStartKey, name);
  }

  /// Hệ đơn vị mặc định: `metric` (mặc định) hoặc `us` (AC-58). Trả về chữ để
  /// lớp dữ liệu không phụ thuộc `cooking/`; dùng `UnitSystem.values.byName`.
  Stream<String> watchUnitSystem() =>
      _watch(unitSystemKey).map((v) => v == 'us' ? 'us' : 'metric');

  Future<void> setUnitSystem(String system) =>
      _write(unitSystemKey, system == 'us' ? 'us' : 'metric');

  Stream<bool> _watchFlag(String key, {required bool fallback}) =>
      _watch(key).map((v) => v == null ? fallback : v == '1');

  Future<void> _writeFlag(String key, bool on) => _write(key, on ? '1' : '0');

  /// "Gia vị cơ bản không tính là thiếu" trong "Nấu được gì?" (AC-43).
  /// Mặc định tắt (SPEC: "nếu người dùng bật").
  Stream<bool> watchIgnoreBasics() =>
      _watchFlag(ignoreBasicsKey, fallback: false);

  Future<void> setIgnoreBasics(bool on) => _writeFlag(ignoreBasicsKey, on);

  /// Lựa chọn lần trước của "chuyển món đã mua vào Tủ bếp" khi xóa món đã
  /// gạch (AC-37). Mặc định tắt.
  Stream<bool> watchShoppingToPantry() =>
      _watchFlag(shoppingToPantryKey, fallback: false);

  Future<void> setShoppingToPantry(bool on) =>
      _writeFlag(shoppingToPantryKey, on);
}
