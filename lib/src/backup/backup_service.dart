import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../data/image_store.dart';
import 'backup_data.dart';
import 'backup_format.dart';
import 'backup_settings.dart';
import 'backup_target.dart';

enum BackupOutcome {
  /// Chưa chọn thư mục.
  disabled,

  /// Chưa tới chu kỳ.
  notDue,

  /// Đang có một lần sao lưu khác chạy.
  busy,

  /// Dữ liệu không đổi từ lần trước, không ghi file mới.
  unchanged,

  /// Đã ghi, đọc lại và kiểm xong.
  success,

  /// Lỗi; chi tiết ở [BackupRunResult.error].
  failed,
}

class BackupRunResult {
  const BackupRunResult(this.outcome, {this.info, this.error});

  final BackupOutcome outcome;
  final BackupInfo? info;
  final String? error;
}

/// Mã lỗi của lần sao lưu thất bại (đầu của `BackupConfig.lastError`).
class BackupErrorKind {
  /// Không ghi hoặc đọc được nơi lưu (mất quyền, hết dung lượng, ứng dụng
  /// đám mây bị gỡ) (AC-51).
  static const target = 'target';

  /// File ghi xong nhưng đọc lại không khớp (AC-51).
  static const verify = 'verify';
  static const other = 'other';
}

/// Sao lưu tự động, sao lưu ngay và khôi phục (F-11).
class BackupService {
  BackupService({
    required this.db,
    required this.images,
    required this.settings,
    required this.tempDir,
    required this.safetyDir,
    required this.appVersion,
    required this.targetFor,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final ImageStore images;
  final BackupSettingsRepository settings;

  /// Thư mục tạm; file tạm bị xóa sau mỗi lần dùng.
  final Directory tempDir;

  /// Nơi giữ bản sao lưu an toàn tự tạo trước khi thay thế dữ liệu (AC-54).
  final Directory safetyDir;
  final String appVersion;

  /// Nơi lưu ứng với cấu hình hiện tại; null nếu chưa chọn.
  final BackupTarget? Function(BackupConfig config) targetFor;
  final DateTime Function() _clock;

  bool _running = false;
  bool get isRunning => _running;

  /// Mã băm dữ liệu hiện tại, để biết có thay đổi từ lần sao lưu trước không.
  Future<String> currentDataHash() async =>
      sha256.convert(utf8.encode(jsonEncode(await exportData(db)))).toString();

  /// Tự sao lưu nếu đã bật và tới chu kỳ (AC-50). Gọi lúc mở app và lúc app
  /// vào nền; không ném lỗi, kết quả ghi vào cài đặt.
  Future<BackupRunResult> runIfDue() async {
    final config = await settings.read();
    if (!config.enabled) return const BackupRunResult(BackupOutcome.disabled);
    if (!backupDue(
      now: _clock(),
      interval: config.interval,
      lastChecked: config.lastChecked,
    )) {
      return const BackupRunResult(BackupOutcome.notDue);
    }
    return runNow();
  }

  /// Sao lưu vào thư mục đã chọn ngay, dù chưa tới chu kỳ. [force] ghi file
  /// mới cả khi dữ liệu không đổi.
  Future<BackupRunResult> runNow({
    bool force = false,
    void Function(double progress)? onProgress,
    bool Function()? cancelled,
  }) async {
    if (_running) return const BackupRunResult(BackupOutcome.busy);
    _running = true;
    try {
      final config = await settings.read();
      final target = targetFor(config);
      if (target == null) return const BackupRunResult(BackupOutcome.disabled);
      return await _backupTo(
        target,
        config,
        force: force,
        onProgress: onProgress,
        cancelled: cancelled,
      );
    } finally {
      _running = false;
    }
  }

  Future<BackupRunResult> _backupTo(
    BackupTarget target,
    BackupConfig config, {
    required bool force,
    void Function(double)? onProgress,
    bool Function()? cancelled,
  }) async {
    final now = _clock();
    await tempDir.create(recursive: true);
    final temp = File(
      p.join(
        tempDir.path,
        'backup-${now.microsecondsSinceEpoch}$backupExtension',
      ),
    );
    Directory? fetched;
    try {
      final hash = await currentDataHash();
      if (!force && config.lastHash == hash) {
        await settings.recordUnchanged(now);
        return const BackupRunResult(BackupOutcome.unchanged);
      }

      final info = await createBackupFile(
        db: db,
        images: images,
        out: temp,
        appVersion: appVersion,
        now: now,
        onProgress: onProgress,
        cancelled: cancelled,
      );
      await verifyBackupFile(temp);

      final name = backupFileName(now);
      try {
        await target.put(temp, name);
      } catch (e) {
        return await _fail(BackupErrorKind.target, e);
      }

      // Đọc lại đúng file vừa ghi ở nơi lưu và kiểm mã băm (AC-51).
      fetched = Directory(
        p.join(tempDir.path, 'verify-${now.microsecondsSinceEpoch}'),
      );
      try {
        final listed = await target.list();
        final written = listed.where((f) => f.name == name).firstOrNull;
        if (written == null) {
          return await _fail(
            BackupErrorKind.target,
            'file không thấy sau khi ghi',
          );
        }
        final back = await target.fetch(written, fetched);
        try {
          await verifyBackupFile(back);
        } on BackupException catch (e) {
          await target.delete(written);
          return await _fail(BackupErrorKind.verify, e);
        }
        // Xoay vòng: giữ [keep] bản mới nhất do app tạo, không đụng file khác.
        final own = listed.where((f) => isOwnBackupName(f.name)).toList()
          ..sort((a, b) => b.name.compareTo(a.name));
        for (final old in own.skip(config.keep)) {
          await target.delete(old);
        }
      } on BackupException {
        rethrow;
      } catch (e) {
        return await _fail(BackupErrorKind.target, e);
      }

      await settings.recordSuccess(at: now, hash: hash, bytes: info.bytes);
      return BackupRunResult(BackupOutcome.success, info: info);
    } on BackupCancelled {
      rethrow;
    } catch (e) {
      return await _fail(BackupErrorKind.other, e);
    } finally {
      if (await temp.exists()) await temp.delete();
      if (fetched != null && await fetched.exists()) {
        try {
          await fetched.delete(recursive: true);
        } on FileSystemException {
          // Không quan trọng; lần sau dọn.
        }
      }
    }
  }

  Future<BackupRunResult> _fail(String kind, Object e) async {
    final text = '$kind|$e';
    await settings.recordError(text);
    return BackupRunResult(BackupOutcome.failed, error: text);
  }

  /// Tạo file sao lưu tại [out] để người dùng tự lưu hoặc chia sẻ (AC-52).
  Future<BackupInfo> createFile(
    File out, {
    void Function(double)? onProgress,
    bool Function()? cancelled,
  }) => createBackupFile(
    db: db,
    images: images,
    out: out,
    appVersion: appVersion,
    now: _clock(),
    onProgress: onProgress,
    cancelled: cancelled,
  );

  /// Khôi phục từ [file]. Thay thế thì tự sao lưu dữ liệu hiện tại vào
  /// [safetyDir] trước (giữ 2 bản gần nhất); file hỏng thì không đụng gì
  /// (AC-54).
  Future<ImportSummary> restore(
    File file,
    RestoreMode mode, {
    void Function(double)? onProgress,
  }) async {
    await verifyBackupFile(file);
    if (mode == RestoreMode.replace) {
      await safetyDir.create(recursive: true);
      final now = _clock();
      await createBackupFile(
        db: db,
        images: images,
        out: File(
          p.join(
            safetyDir.path,
            'before-restore-${now.microsecondsSinceEpoch}$backupExtension',
          ),
        ),
        appVersion: appVersion,
        now: now,
      );
      final all =
          await safetyDir
                .list()
                .where((e) => e is File && e.path.endsWith(backupExtension))
                .map((e) => e.path)
                .toList()
            ..sort();
      for (final old in all.take(all.length > 2 ? all.length - 2 : 0)) {
        await File(old).delete();
      }
    }
    return restoreBackupFile(
      db: db,
      images: images,
      file: file,
      mode: mode,
      onProgress: onProgress,
    );
  }
}
