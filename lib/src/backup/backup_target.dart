import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';

/// Phần mở rộng của file sao lưu.
const backupExtension = '.cooknote';

final _ownName = RegExp(r'^CookNote-\d{4}-\d{2}-\d{2}-\d{6}\.cooknote$');

/// Tên do chính app đặt; chỉ những file này bị xoay vòng xóa (AC-50).
bool isOwnBackupName(String name) => _ownName.hasMatch(name);

String _two(int n) => n.toString().padLeft(2, '0');

/// `CookNote-2026-11-04-153000.cooknote`: sắp theo tên là sắp theo thời gian.
String backupFileName(DateTime t) =>
    'CookNote-${t.year.toString().padLeft(4, '0')}-${_two(t.month)}-${_two(t.day)}-'
    '${_two(t.hour)}${_two(t.minute)}${_two(t.second)}$backupExtension';

class BackupFileInfo {
  const BackupFileInfo({
    required this.name,
    required this.id,
    required this.size,
    required this.modified,
  });

  final String name;

  /// Đường dẫn hoặc URI để đọc, xóa.
  final String id;
  final int size;
  final DateTime modified;
}

/// Nơi lưu các file sao lưu: thư mục do người dùng chọn một lần (AC-50).
abstract class BackupTarget {
  /// Tên hiển thị của nơi lưu.
  String get label;

  /// Các file (không gồm thư mục) trong nơi lưu.
  Future<List<BackupFileInfo>> list();

  /// Ghi [local] vào nơi lưu với tên [name], ghi đè nếu đã có.
  Future<void> put(File local, String name);

  /// Chép [file] về thư mục tạm [tempDir] để đọc.
  Future<File> fetch(BackupFileInfo file, Directory tempDir);

  Future<void> delete(BackupFileInfo file);
}

/// Thư mục thường (dart:io). Dùng cho test; trên Android chỉ ghi được vào
/// thư mục riêng của app nên bản chạy thật dùng [SafTarget].
class LocalDirTarget implements BackupTarget {
  LocalDirTarget(this.directory);

  final Directory directory;

  @override
  String get label => directory.path;

  @override
  Future<List<BackupFileInfo>> list() async {
    if (!await directory.exists()) {
      throw FileSystemException('Không có thư mục', directory.path);
    }
    final out = <BackupFileInfo>[];
    await for (final e in directory.list()) {
      if (e is File) {
        final stat = await e.stat();
        out.add(
          BackupFileInfo(
            name: p.basename(e.path),
            id: e.path,
            size: stat.size,
            modified: stat.modified,
          ),
        );
      }
    }
    return out;
  }

  @override
  Future<void> put(File local, String name) async {
    await directory.create(recursive: true);
    await local.copy(p.join(directory.path, name));
  }

  @override
  Future<File> fetch(BackupFileInfo file, Directory tempDir) async {
    await tempDir.create(recursive: true);
    return File(file.id).copy(p.join(tempDir.path, file.name));
  }

  @override
  Future<void> delete(BackupFileInfo file) => File(file.id).delete();
}

/// Thư mục chọn bằng trình chọn thư mục của Android (Storage Access
/// Framework), có thể là thư mục của Google Drive hay OneDrive nếu ứng dụng đó
/// cho phép. Quyền ghi được giữ lâu dài sau khi chọn một lần (AC-50).
///
/// CHƯA kiểm chứng trên máy thật: ứng dụng đám mây có cho ghi định kỳ vào
/// thư mục hay không phải thử ở G3 (SPEC mục 7).
class SafTarget implements BackupTarget {
  SafTarget(this.treeUri, this.name);

  final String treeUri;
  final String name;
  final _util = SafUtil();
  final _stream = SafStream();

  @override
  String get label => name;

  @override
  Future<List<BackupFileInfo>> list() async => [
    for (final f in await _util.list(treeUri))
      if (!f.isDir)
        BackupFileInfo(
          name: f.name,
          id: f.uri,
          size: f.length,
          modified: DateTime.fromMillisecondsSinceEpoch(f.lastModified),
        ),
  ];

  @override
  Future<void> put(File local, String name) async {
    await _stream.pasteLocalFile(
      local.path,
      treeUri,
      name,
      'application/octet-stream',
      overwrite: true,
    );
  }

  @override
  Future<File> fetch(BackupFileInfo file, Directory tempDir) async {
    await tempDir.create(recursive: true);
    final dest = p.join(tempDir.path, file.name);
    await _stream.copyToLocalFile(file.id, dest);
    return File(dest);
  }

  @override
  Future<void> delete(BackupFileInfo file) => _util.delete(file.id, false);
}
