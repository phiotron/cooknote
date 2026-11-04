import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';
import '../../web_import/browser_engine.dart';
import '../../web_import/browser_session.dart';
import '../../web_import/web_images.dart';
import '../../web_import/web_providers.dart';

enum _Duplicate { openOld, saveNew }

/// Trình duyệt trong app để nhập công thức từ web (F-03, AC-16 tới AC-22).
class WebBrowserScreen extends ConsumerStatefulWidget {
  const WebBrowserScreen({super.key, this.initialUrl});

  /// URL mở sẵn, ví dụ từ "Chia sẻ" (AC-17).
  final String? initialUrl;

  @override
  ConsumerState<WebBrowserScreen> createState() => _WebBrowserScreenState();
}

class _WebBrowserScreenState extends ConsumerState<WebBrowserScreen> {
  late final BrowserSession _session;
  final _address = TextEditingController();
  final _addressFocus = FocusNode();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _session = BrowserSession(ref.read(browserEngineFactoryProvider)());
    _session.addListener(_onSession);
    final url = widget.initialUrl;
    if (url != null && url.isNotEmpty) {
      _address.text = url;
      _session.submit(url);
    }
  }

  void _onSession() {
    final url = _session.url;
    if (url != null && !_addressFocus.hasFocus) _address.text = url.toString();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    _session.dispose();
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  String _failureText(AppLocalizations l, LoadFailure f) => switch (f.kind) {
    LoadFailureKind.network => l.webErrorNetwork,
    LoadFailureKind.timeout => l.webErrorTimeout,
    LoadFailureKind.http => l.webErrorHttp(f.httpCode ?? 0),
    LoadFailureKind.other => l.webErrorOther,
  };

  Future<void> _pick(SelectionKind kind) async {
    final ok = await _session.addSelection(kind);
    if (!ok && mounted) {
      showMessage(AppLocalizations.of(context).webSelectionEmpty);
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final outcome = await _session.capture();
      if (!mounted) return;
      switch (outcome) {
        case CaptureFailed(:final failure):
          showMessage(
            failure.kind == LoadFailureKind.other
                ? l.webReadFailed
                : _failureText(l, failure),
          );
        case CaptureNeedsSelection():
          showMessage(l.webNoRecipe);
        case CaptureFound(:final recipe):
          await _continue(recipe.draft, recipe.imageUrls);
        case CaptureFromSelection(:final draft):
          await _continue(draft, const []);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Phát hiện trùng (AC-20), tải ảnh (AC-22), rồi mở màn xem trước để sửa.
  Future<void> _continue(RecipeDraft draft, List<String> imageUrls) async {
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final repo = ref.read(recipeRepositoryProvider);
    final sourceUrl = draft.sourceUrl;
    if (sourceUrl != null) {
      final existing = await repo.findBySourceUrl(sourceUrl);
      if (!mounted) return;
      if (existing != null) {
        final choice = await showDialog<_Duplicate>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: Text(l.webDuplicateTitle),
            content: Text(l.webDuplicateBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog, _Duplicate.openOld),
                child: Text(l.webOpenExisting),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialog, _Duplicate.saveNew),
                child: Text(l.webSaveNew),
              ),
            ],
          ),
        );
        if (!mounted || choice == null) return;
        if (choice == _Duplicate.openOld) {
          router.go('/recipe/$existing');
          return;
        }
      }
    }
    var photos = <String>[];
    var failed = 0;
    if (imageUrls.isNotEmpty) {
      final result = await _downloadImages(imageUrls);
      if (!mounted) return;
      photos = result.names;
      failed = result.failed;
    }
    final withPhotos = RecipeDraft(
      name: draft.name,
      servings: draft.servings,
      servingsUnit: draft.servingsUnit,
      prepMinutes: draft.prepMinutes,
      cookMinutes: draft.cookMinutes,
      totalMinutes: draft.totalMinutes,
      source: draft.source,
      sourceUrl: draft.sourceUrl,
      notes: draft.notes,
      nutrition: draft.nutrition,
      ingredients: draft.ingredients,
      steps: draft.steps,
      photos: photos,
    );
    if (failed > 0) showMessage(l.webImagesFailed(failed));
    router.push('/recipe/new', extra: withPhotos);
  }

  Future<WebImagesResult> _downloadImages(List<String> urls) async {
    final progress = ValueNotifier<(int, int)>((0, urls.length));
    final cancel = ImageCancel();
    final l = AppLocalizations.of(context);
    final nav = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: ValueListenableBuilder<(int, int)>(
            valueListenable: progress,
            builder: (context, p, _) => Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(l.webDownloadingImages(p.$1, p.$2))),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => cancel.cancelled = true,
              child: Text(l.webSkipImages),
            ),
          ],
        ),
      ),
    );
    try {
      return await importWebImages(
        urls: urls,
        downloader: ref.read(imageDownloaderProvider),
        store: ref.read(imageStoreProvider),
        tempDir: ref.read(appDirsProvider).temp,
        cancel: cancel,
        onProgress: (done, total) => progress.value = (done, total),
      );
    } finally {
      nav.pop();
      progress.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _session;
    final failure = s.failure;
    return PopScope(
      canPop: !s.canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) s.goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.webTitle),
          actions: [
            IconButton(
              tooltip: l.webBack,
              icon: const Icon(Icons.arrow_back),
              onPressed: s.canGoBack ? s.goBack : null,
            ),
            IconButton(
              tooltip: l.webForward,
              icon: const Icon(Icons.arrow_forward),
              onPressed: s.canGoForward ? s.goForward : null,
            ),
            IconButton(
              tooltip: l.webReload,
              icon: const Icon(Icons.refresh),
              onPressed: s.url == null ? null : s.reload,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _address,
                focusNode: _addressFocus,
                decoration: InputDecoration(
                  hintText: l.webAddressHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                onSubmitted: (v) {
                  _addressFocus.unfocus();
                  s.submit(v);
                },
              ),
            ),
            if (s.loading)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: s.engine.buildView(context)),
                  if (s.url == null && failure == null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              l.webStartHint,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (failure != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _failureText(l, failure),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: s.retry,
                                icon: const Icon(Icons.refresh),
                                label: Text(l.webRetry),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (s.selectionMode) _selectionPanel(l),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(l.webSave),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionPanel(AppLocalizations l) {
    final parts = _session.parts;
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.webNoRecipe),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: Text(l.webSelectName),
                  onPressed: () => _pick(SelectionKind.name),
                ),
                ActionChip(
                  label: Text(l.webSelectIngredients),
                  onPressed: () => _pick(SelectionKind.ingredients),
                ),
                ActionChip(
                  label: Text(l.webSelectSteps),
                  onPressed: () => _pick(SelectionKind.steps),
                ),
              ],
            ),
            if (!parts.isEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.webPartsSummary(
                        parts.ingredients.length,
                        parts.steps.length,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _session.clearParts,
                    child: Text(l.webClearParts),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
