import 'package:drift/drift.dart';

import '../data/database.dart';

enum BackupInterval { daily, weekly }

/// Số lần giữ mặc định và giới hạn (AC-50).
const defaultBackupKeep = 5;
const minBackupKeep = 1;
const maxBackupKeep = 30;

/// Quá số ngày này chưa có lần sao lưu thành công thì nhắc (AC-53).
const backupReminderDays = 7;

/// Số công thức tối thiểu để gợi ý bật sao lưu lần đầu (AC-53).
const suggestBackupAtRecipes = 10;

/// Cài đặt và kết quả sao lưu tự động, lưu trong bảng `settings` (D-007).
class BackupConfig {
  const BackupConfig({
    this.treeUri,
    this.treeName,
    this.interval = BackupInterval.daily,
    this.keep = defaultBackupKeep,
    this.lastSuccess,
    this.lastChecked,
    this.lastError,
    this.lastHash,
    this.lastBytes,
  });

  /// Thư mục đã chọn; null là chưa bật sao lưu tự động.
  final String? treeUri;
  final String? treeName;
  final BackupInterval interval;
  final int keep;

  /// Lần sao lưu thành công gần nhất (có ghi file mới).
  final DateTime? lastSuccess;

  /// Lần gần nhất app kiểm và thấy không cần hoặc đã sao lưu xong.
  final DateTime? lastChecked;

  /// Lỗi của lần thử gần nhất, dạng `mã|chi tiết`; null là không lỗi.
  final String? lastError;

  /// Mã băm dữ liệu của lần sao lưu thành công gần nhất.
  final String? lastHash;
  final int? lastBytes;

  bool get enabled => treeUri != null;
}

class BackupSettingsRepository {
  BackupSettingsRepository(this._db);

  final AppDatabase _db;

  static const _prefix = 'backup.';

  BackupConfig _fromRows(List<Setting> rows) {
    final m = {for (final r in rows) r.key.substring(_prefix.length): r.value};
    DateTime? time(String k) =>
        m[k] == null ? null : DateTime.tryParse(m[k]!)?.toLocal();
    return BackupConfig(
      treeUri: m['treeUri'],
      treeName: m['treeName'],
      interval: m['interval'] == 'weekly'
          ? BackupInterval.weekly
          : BackupInterval.daily,
      keep: (int.tryParse(m['keep'] ?? '') ?? defaultBackupKeep).clamp(
        minBackupKeep,
        maxBackupKeep,
      ),
      lastSuccess: time('lastSuccess'),
      lastChecked: time('lastChecked'),
      lastError: m['lastError'],
      lastHash: m['lastHash'],
      lastBytes: int.tryParse(m['lastBytes'] ?? ''),
    );
  }

  Stream<BackupConfig> watch() => (_db.select(
    _db.settings,
  )..where((s) => s.key.like('$_prefix%'))).watch().map(_fromRows);

  Future<BackupConfig> read() async => _fromRows(
    await (_db.select(
      _db.settings,
    )..where((s) => s.key.like('$_prefix%'))).get(),
  );

  Future<void> _write(String key, String? value) async {
    final k = '$_prefix$key';
    if (value == null) {
      await (_db.delete(_db.settings)..where((s) => s.key.equals(k))).go();
    } else {
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: k, value: value),
          );
    }
  }

  /// Chọn thư mục mới: xóa kết quả cũ để lần đầu sao lưu ngay.
  Future<void> setTarget(String uri, String name) async {
    await _write('treeUri', uri);
    await _write('treeName', name);
    await _write('lastError', null);
    await _write('lastChecked', null);
    await _write('lastHash', null);
  }

  /// Tắt sao lưu tự động. Giữ lần thành công gần nhất để còn hiện.
  Future<void> clearTarget() async {
    await _write('treeUri', null);
    await _write('treeName', null);
    await _write('lastError', null);
  }

  Future<void> setInterval(BackupInterval i) => _write('interval', i.name);

  Future<void> setKeep(int n) =>
      _write('keep', '${n.clamp(minBackupKeep, maxBackupKeep)}');

  Future<void> recordSuccess({
    required DateTime at,
    required String hash,
    required int bytes,
  }) async {
    await _write('lastSuccess', at.toUtc().toIso8601String());
    await _write('lastChecked', at.toUtc().toIso8601String());
    await _write('lastHash', hash);
    await _write('lastBytes', '$bytes');
    await _write('lastError', null);
  }

  /// Dữ liệu không đổi từ lần trước nên không ghi file mới.
  Future<void> recordUnchanged(DateTime at) async {
    await _write('lastChecked', at.toUtc().toIso8601String());
    await _write('lastError', null);
  }

  Future<void> recordError(String error) => _write('lastError', error);
}

/// Đã tới lúc tự sao lưu chưa (AC-50): quá chu kỳ kể từ lần kiểm gần nhất.
/// Chu kỳ hằng ngày tính 23 giờ, hằng tuần 6 ngày 23 giờ, để mở app lúc nào
/// trong ngày cũng không bị lệch một ngày.
bool backupDue({
  required DateTime now,
  required BackupInterval interval,
  DateTime? lastChecked,
}) {
  if (lastChecked == null) return true;
  final gap = interval == BackupInterval.daily
      ? const Duration(hours: 23)
      : const Duration(days: 6, hours: 23);
  return now.difference(lastChecked) >= gap;
}

/// Thông báo hiện trong app về tình trạng sao lưu (AC-51, AC-53).
enum BackupNotice { none, suggestEnable, overdue, targetError }

BackupNotice backupNotice({
  required BackupConfig config,
  required int recipeCount,
  required DateTime now,
}) {
  if (config.enabled && config.lastError != null) {
    return BackupNotice.targetError;
  }
  final last = config.lastSuccess;
  if (last == null) {
    return !config.enabled && recipeCount >= suggestBackupAtRecipes
        ? BackupNotice.suggestEnable
        : BackupNotice.none;
  }
  if (recipeCount > 0 &&
      now.difference(last) > const Duration(days: backupReminderDays)) {
    return BackupNotice.overdue;
  }
  return BackupNotice.none;
}
