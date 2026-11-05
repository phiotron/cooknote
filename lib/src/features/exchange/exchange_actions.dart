import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../cookbook/cookbook_pdf.dart';
import '../../exchange/export_service.dart';
import '../../exchange/exchange_providers.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';

/// Nhãn trong PDF theo ngôn ngữ đang dùng.
CookbookLabels cookbookLabels(AppLocalizations l) => CookbookLabels(
  contents: l.pdfContents,
  ingredients: l.ingredients,
  steps: l.steps,
  notes: l.notes,
  source: l.source,
  servings: l.pdfServings,
  prep: l.pdfPrep,
  cook: l.pdfCook,
  total: l.pdfTotal,
  minutes: l.pdfMinutes,
  page: l.pdfPage,
);

/// Hộp tiến độ có nút Hủy. Trả về null nếu người dùng hủy ([isCancel] nhận
/// ra ngoại lệ hủy của việc đang chạy).
Future<T?> runWithProgress<T>(
  BuildContext context,
  String title,
  Future<T> Function(
    void Function(double) onProgress,
    bool Function() cancelled,
  )
  task, {
  bool cancellable = true,
}) async {
  final l = AppLocalizations.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  final progress = ValueNotifier<double?>(null);
  var cancel = false;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(title),
        content: ValueListenableBuilder<double?>(
          valueListenable: progress,
          builder: (_, v, _) => LinearProgressIndicator(value: v),
        ),
        actions: [
          if (cancellable)
            TextButton(onPressed: () => cancel = true, child: Text(l.cancel)),
        ],
      ),
    ),
  );
  try {
    return await task((v) => progress.value = v, () => cancel);
  } on ExportCancelled {
    showMessage(l.exportCancelled);
    return null;
  } finally {
    navigator.pop();
    progress.dispose();
  }
}

Future<void> _deleteQuietly(File f) async {
  try {
    if (await f.exists()) await f.delete();
  } on FileSystemException {
    // Lần mở app sau dọn thư mục tạm (AC-48).
  }
}

/// Xuất JSON schema.org các công thức [ids] rồi mở bảng chia sẻ (AC-45).
Future<void> exportRecipesJson(
  BuildContext context,
  WidgetRef ref,
  List<int> ids,
) async {
  final l = AppLocalizations.of(context);
  if (ids.isEmpty) {
    showMessage(l.cookbookNone);
    return;
  }
  final service = ref.read(exportServiceProvider);
  final sharer = ref.read(sharerProvider);
  File? file;
  try {
    file = await runWithProgress(
      context,
      l.exportWorking,
      (onProgress, cancelled) =>
          service.exportSchemaOrg(ids, onProgress: onProgress, cancelled: cancelled),
    );
    if (file != null) await sharer.shareFile(file.path);
  } on Object {
    showMessage(l.exportFailed);
  } finally {
    if (file != null) await _deleteQuietly(file);
  }
}

/// Hỏi tên sách, tạo PDF rồi cho chia sẻ/lưu hoặc in (AC-47).
Future<void> makeCookbook(
  BuildContext context,
  WidgetRef ref,
  List<int> ids, {
  String? initialTitle,
}) async {
  final l = AppLocalizations.of(context);
  if (ids.isEmpty) {
    showMessage(l.cookbookNone);
    return;
  }
  final controller = TextEditingController(
    text: initialTitle ?? l.cookbookDefaultTitle,
  );
  final title = await showDialog<String>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l.cookbookMake),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l.cookbookTitleLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialog, controller.text.trim()),
          child: Text(l.cookbookCreate),
        ),
      ],
    ),
  );
  controller.dispose();
  if (title == null || !context.mounted) return;
  final service = ref.read(exportServiceProvider);
  final sharer = ref.read(sharerProvider);
  final printer = ref.read(pdfPrinterProvider);
  final labels = cookbookLabels(l);
  final bookTitle = title.isEmpty ? l.cookbookDefaultTitle : title;
  File? file;
  try {
    file = await runWithProgress(
      context,
      l.exportWorking,
      (onProgress, cancelled) => service.cookbookPdf(
        ids,
        bookTitle,
        labels,
        onProgress: onProgress,
        cancelled: cancelled,
      ),
    );
    if (file == null || !context.mounted) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l.cookbookReady,
                style: Theme.of(sheet).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l.cookbookShare),
              onTap: () => Navigator.pop(sheet, 'share'),
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: Text(l.printRecipe),
              onTap: () => Navigator.pop(sheet, 'print'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'share') {
      await sharer.shareFile(file.path, subject: bookTitle);
    } else if (choice == 'print') {
      final Uint8List bytes = await file.readAsBytes();
      await printer.printPdf(bytes, bookTitle);
    }
  } on Object {
    showMessage(l.exportFailed);
  } finally {
    if (file != null) await _deleteQuietly(file);
  }
}

/// Chia sẻ một công thức dạng chữ, PDF hoặc `.cooknote` (AC-46), hoặc in.
Future<void> shareRecipeSheet(
  BuildContext context,
  WidgetRef ref,
  int id,
  String name,
) async {
  final l = AppLocalizations.of(context);
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(l.shareAsText),
            onTap: () => Navigator.pop(sheet, 'text'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l.shareAsPdf),
            onTap: () => Navigator.pop(sheet, 'pdf'),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(l.shareAsCooknote),
            onTap: () => Navigator.pop(sheet, 'cooknote'),
          ),
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: Text(l.printRecipe),
            onTap: () => Navigator.pop(sheet, 'print'),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  final service = ref.read(exportServiceProvider);
  final sharer = ref.read(sharerProvider);
  final printer = ref.read(pdfPrinterProvider);
  final labels = cookbookLabels(l);
  File? file;
  try {
    switch (choice) {
      case 'text':
        final text = await service.recipeText(id, labels);
        if (text != null) await sharer.shareText(text, subject: name);
      case 'pdf':
        file = await runWithProgress(
          context,
          l.exportWorking,
          (_, _) => service.recipePdf(id, labels),
          cancellable: false,
        );
        if (file != null) await sharer.shareFile(file.path, subject: name);
      case 'print':
        file = await runWithProgress(
          context,
          l.exportWorking,
          (_, _) => service.recipePdf(id, labels),
          cancellable: false,
        );
        if (file != null) await printer.printPdf(await file.readAsBytes(), name);
      case 'cooknote':
        file = await runWithProgress(
          context,
          l.exportWorking,
          (onProgress, cancelled) => service.createCooknote(
            [id],
            name: name,
            onProgress: onProgress,
            cancelled: cancelled,
          ),
          cancellable: false,
        );
        if (file != null) await sharer.shareFile(file.path, subject: name);
    }
  } on Object {
    showMessage(l.exportFailed);
  } finally {
    if (file != null) await _deleteQuietly(file);
  }
}

/// Mọi công thức đang dùng (không tính thùng rác) để xuất cả kho.
Future<List<int>> allRecipeIds(WidgetRef ref) async => [
  for (final r in await ref.read(recipeRepositoryProvider).search(
    ref.read(recipeQueryProvider).cleared(),
  ))
    r.id,
];
