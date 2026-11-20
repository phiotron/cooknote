import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../exchange/exchange_providers.dart';
import '../../providers.dart';
import '../../scan/ocr_engine.dart';
import '../../scan/ocr_providers.dart';
import '../../scan/scan_pipeline.dart';
import '../../ui/messenger.dart';
import '../../ui/theme/theme.dart';

/// Kết quả quét chuyển sang màn gán dòng.
class ScanPayload {
  const ScanPayload(this.result);

  final ScanResult result;
}

/// Quét công thức từ ảnh hoặc PDF (SCR-19/20, AC-23..AC-25).
///
/// Mọi bước nhận chữ chạy trên máy; không gửi ảnh đi đâu (D-003).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _busy = false;

  OcrEngine? _engine() {
    final engine = ref.read(ocrEngineProvider);
    if (engine == null) showMessage(AppLocalizations.of(context).scanNotAvailable);
    return engine;
  }

  Future<void> _scanImages(List<String> paths) async {
    if (paths.isEmpty) return;
    final engine = _engine();
    if (engine == null) return;
    final result = await _run(
      (onProgress) => scanImages(engine, paths, onProgress: onProgress),
    );
    if (result != null && mounted) _openAssign(result);
  }

  Future<void> _scanPdf(String path) async {
    final engine = _engine();
    if (engine == null) return;
    final l = AppLocalizations.of(context);
    final result = await _run(
      (onProgress) => scanPdf(engine, path, onProgress: onProgress),
    );
    if (result == null || !mounted) return;
    final (pdf, scanned) = result;
    if (pdf.truncated) {
      showMessage(l.scanPdfPagesLimited(pdf.pageCount, pdf.imagePaths.length));
    }
    _openAssign(scanned);
  }

  Future<T?> _run<T>(
    Future<T> Function(void Function(int done, int total) onProgress) task,
  ) async {
    if (_busy) return null;
    final l = AppLocalizations.of(context);
    final engine = ref.read(ocrEngineProvider);
    final progress = ValueNotifier<(int, int)>((0, 1));
    final nav = Navigator.of(context, rootNavigator: true);
    setState(() => _busy = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l.scanReading),
          content: ValueListenableBuilder<(int, int)>(
            valueListenable: progress,
            builder: (context, p, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: p.$2 == 0 ? null : p.$1 / p.$2,
                ),
                const SizedBox(height: 12),
                Text(l.scanProgress(p.$1, p.$2)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => engine?.cancel(),
              child: Text(l.cancel),
            ),
          ],
        ),
      ),
    );
    try {
      return await task((done, total) => progress.value = (done, total));
    } on OcrException catch (e) {
      if (!mounted) return null;
      if (!e.isCancelled) showMessage(l.scanFailed);
      return null;
    } on ArgumentError {
      if (mounted) showMessage(l.scanTooManyPages);
      return null;
    } on Object {
      if (mounted) showMessage(l.scanFailed);
      return null;
    } finally {
      nav.pop();
      progress.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openAssign(ScanResult result) {
    if (result.lines.isEmpty) {
      showMessage(AppLocalizations.of(context).scanNoLines);
      return;
    }
    context.push('/scan/assign', extra: ScanPayload(result));
  }

  Future<void> _pickGallery() async {
    final paths = await ref
        .read(photoPickerProvider)
        .pickFromGallery(limit: kMaxScanPages);
    await _scanImages(paths);
  }

  Future<void> _takePhoto() async {
    final path = await ref.read(photoPickerProvider).takePhoto();
    if (path != null) await _scanImages([path]);
  }

  Future<void> _pickPdf() async {
    final path = await ref.read(importFilePickerProvider).pick();
    if (path != null) await _scanPdf(path);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final engine = ref.watch(ocrEngineProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.scanPhoto)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.bep.infoContainer,
              borderRadius: BepRadius.circular(BepRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: context.bep.onInfoContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.scanPrivacy,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: context.bep.onInfoContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (engine == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.scanNotAvailable),
              ),
            )
          else ...[
            _Choice(
              icon: Icons.photo_library_outlined,
              title: l.scanFromGallery,
              subtitle: l.scanMaxPages,
              onTap: _busy ? null : _pickGallery,
            ),
            const SizedBox(height: 12),
            _Choice(
              icon: Icons.photo_camera_outlined,
              title: l.scanTakePhoto,
              subtitle: l.scanOnePage,
              onTap: _busy ? null : _takePhoto,
            ),
            const SizedBox(height: 12),
            _Choice(
              icon: Icons.picture_as_pdf_outlined,
              title: l.scanPickPdf,
              subtitle: l.scanPdfHint,
              onTap: _busy ? null : _pickPdf,
            ),
            const SizedBox(height: 24),
            Text(
              l.scanHandwritingWarning,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
