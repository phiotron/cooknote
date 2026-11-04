import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../cookbook/cookbook_pdf.dart';
import '../providers.dart';
import 'export_service.dart';
import 'import_service.dart';

/// Bảng chia sẻ của hệ điều hành; test ghi đè bằng bản giả.
abstract class Sharer {
  Future<void> shareFile(String path, {String? subject});
  Future<void> shareText(String text, {String? subject});
}

class SystemSharer implements Sharer {
  @override
  Future<void> shareFile(String path, {String? subject}) => SharePlus.instance
      .share(ShareParams(files: [XFile(path)], subject: subject));

  @override
  Future<void> shareText(String text, {String? subject}) =>
      SharePlus.instance.share(ShareParams(text: text, subject: subject));
}

/// Hộp thoại in của hệ điều hành; test ghi đè bằng bản giả.
abstract class PdfPrinter {
  Future<void> printPdf(Uint8List bytes, String name);
}

class SystemPdfPrinter implements PdfPrinter {
  @override
  Future<void> printPdf(Uint8List bytes, String name) =>
      Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
}

/// Trình chọn file của hệ điều hành; trả về đường dẫn hoặc null nếu hủy.
abstract class ImportFilePicker {
  Future<String?> pick();
}

class SystemImportFilePicker implements ImportFilePicker {
  @override
  Future<String?> pick() async {
    final picked = await FilePicker.pickFiles();
    return picked.isEmpty ? null : picked.first.path;
  }
}

final sharerProvider = Provider<Sharer>((ref) => SystemSharer());
final pdfPrinterProvider = Provider<PdfPrinter>((ref) => SystemPdfPrinter());
final importFilePickerProvider = Provider<ImportFilePicker>(
  (ref) => SystemImportFilePicker(),
);

/// Font Noto Sans nhúng trong app (tiếng Việt hiển thị đúng trong PDF).
Future<CookbookFonts> loadCookbookFonts() async {
  final regular = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
  final bold = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
  return CookbookFonts(
    regular: regular.buffer.asUint8List(
      regular.offsetInBytes,
      regular.lengthInBytes,
    ),
    bold: bold.buffer.asUint8List(bold.offsetInBytes, bold.lengthInBytes),
  );
}

/// Đọc PDF/IO nặng chạy ở isolate; test đặt false.
final exchangeUseIsolateProvider = Provider<bool>((ref) => true);

final importServiceProvider = Provider<ImportService>((ref) {
  final dirs = ref.watch(appDirsProvider);
  return ImportService(
    db: ref.watch(databaseProvider),
    images: ref.watch(imageStoreProvider),
    recipes: ref.watch(recipeRepositoryProvider),
    tempDir: Directory(p.join(dirs.temp.path, 'import')),
    useIsolate: ref.watch(exchangeUseIsolateProvider),
  );
});

final cookbookFontsLoaderProvider = Provider<Future<CookbookFonts> Function()>(
  (ref) => loadCookbookFonts,
);

final exportServiceProvider = Provider<ExportService>((ref) {
  final dirs = ref.watch(appDirsProvider);
  return ExportService(
    db: ref.watch(databaseProvider),
    images: ref.watch(imageStoreProvider),
    recipes: ref.watch(recipeRepositoryProvider),
    exportDir: Directory(p.join(dirs.temp.path, 'export')),
    appVersion: ref.watch(appVersionProvider),
    loadFonts: ref.watch(cookbookFontsLoaderProvider),
    useIsolate: ref.watch(exchangeUseIsolateProvider),
    clock: ref.watch(clockProvider),
  );
});
