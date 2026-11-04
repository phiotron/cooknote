/// Vì sao một file sao lưu không dùng được (AC-54).
enum BackupProblem {
  /// Không phải file zip, hoặc thiếu manifest.
  notABackup,

  /// Do bản app mới hơn tạo; cần cập nhật CookNote (AC-55).
  newerFormat,

  /// Mã băm của một file trong gói không khớp manifest.
  checksumMismatch,

  /// Manifest khai một file mà gói không có.
  missingFile,

  /// Nội dung `data.json` sai cấu trúc.
  badData,
}

class BackupException implements Exception {
  const BackupException(this.problem, [this.detail]);

  final BackupProblem problem;
  final String? detail;

  @override
  String toString() =>
      'BackupException($problem${detail == null ? '' : ': $detail'})';
}

/// Người dùng hủy giữa chừng (AC-57).
class BackupCancelled implements Exception {
  const BackupCancelled();
}

enum RestoreMode {
  /// Xóa dữ liệu hiện có rồi nạp lại toàn bộ từ file.
  replace,

  /// Chỉ thêm công thức chưa có (cùng tên và cùng thời điểm tạo là "đã có").
  merge,
}

class ImportSummary {
  const ImportSummary({this.recipesAdded = 0, this.recipesSkipped = 0});

  final int recipesAdded;
  final int recipesSkipped;
}

/// Số liệu của một file sao lưu đã kiểm tra.
class BackupInfo {
  const BackupInfo({
    required this.formatVersion,
    required this.appVersion,
    required this.createdAt,
    required this.recipes,
    required this.photos,
    required this.categories,
    required this.bytes,
    required this.dataHash,
  });

  final int formatVersion;
  final String appVersion;
  final DateTime createdAt;
  final int recipes;
  final int photos;
  final int categories;

  /// Dung lượng file zip.
  final int bytes;

  /// SHA-256 của `data.json`; hai lần sao lưu cùng dữ liệu cho cùng mã này.
  final String dataHash;
}
