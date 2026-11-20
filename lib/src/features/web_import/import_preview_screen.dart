import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';
import '../../ui/theme/theme.dart';
import '../../web_import/web_images.dart';
import '../../web_import/web_providers.dart';
import '../home/recipe_format.dart';

/// Kết quả trích công thức từ trang web, chuyển từ trình duyệt sang màn xem
/// trước (SCR-17). Ảnh chỉ được tải về khi người dùng bấm Lưu (AC-22).
class ImportPreviewData {
  const ImportPreviewData({required this.draft, this.imageUrls = const []});

  final RecipeDraft draft;
  final List<String> imageUrls;
}

/// Xem trước khi lưu (SCR-17, AC-20): tên, nguồn, nguyên liệu, các bước và số
/// ảnh sẽ tải. Người dùng lưu thẳng hoặc mở trình soạn để sửa.
class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({super.key, this.source});

  /// [ImportPreviewData] do trình duyệt gửi sang.
  final Object? source;

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  bool _saving = false;

  ImportPreviewData? get _data =>
      widget.source is ImportPreviewData ? widget.source as ImportPreviewData : null;

  Future<void> _save() async {
    final data = _data;
    if (data == null || _saving) return;
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final repo = ref.read(recipeRepositoryProvider);
    setState(() => _saving = true);
    try {
      var photos = const <String>[];
      var failed = 0;
      if (data.imageUrls.isNotEmpty) {
        final result = await _download(data.imageUrls);
        if (!mounted) return;
        photos = result.names;
        failed = result.failed;
      }
      if (!mounted) return;
      final draft = data.draft;
      final id = await repo.save(
        RecipeDraft(
          name: draft.name.trim().isEmpty ? l.untitledRecipe : draft.name,
          servings: draft.servings,
          servingsUnit: draft.servingsUnit,
          prepMinutes: draft.prepMinutes,
          cookMinutes: draft.cookMinutes,
          totalMinutes: draft.totalMinutes,
          source: draft.source,
          sourceUrl: draft.sourceUrl,
          notes: draft.notes,
          nutrition: draft.nutrition,
          difficulty: draft.difficulty,
          rating: draft.rating,
          favorite: draft.favorite,
          ingredients: draft.ingredients,
          steps: draft.steps,
          photos: photos,
          categoryIds: draft.categoryIds,
          tags: draft.tags,
        ),
      );
      if (!mounted) return;
      if (failed > 0) showMessage(l.webImagesFailed(failed));
      router.go('/recipe/$id');
    } on Object {
      if (mounted) showMessage(l.webReadFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<WebImagesResult> _download(List<String> urls) async {
    final l = AppLocalizations.of(context);
    final progress = ValueNotifier<(int, int)>((0, urls.length));
    final cancel = ImageCancel();
    final nav = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l.webDownloadingImages(0, urls.length)),
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

  void _edit() {
    final data = _data;
    if (data == null) return;
    context.push('/recipe/new', extra: data.draft);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bep = context.bep;
    final data = _data;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.previewTitle)),
        body: Center(child: Text(l.webReadFailed)),
      );
    }
    final d = data.draft;
    final ingredients = d.ingredients.where((e) => !e.isHeading).toList();
    final steps = d.steps.where((e) => !e.isHeading).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.previewTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            d.name.trim().isEmpty ? l.untitledRecipe : d.name,
            style: theme.textTheme.headlineSmall,
          ),
          if ((d.source ?? '').isNotEmpty || (d.sourceUrl ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.public,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    d.source ?? d.sourceUrl ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Fact(
                icon: Icons.restaurant_menu,
                text: l.previewSummary(ingredients.length, steps.length),
              ),
              if (d.totalMinutes != null || d.cookMinutes != null)
                _Fact(
                  icon: Icons.schedule,
                  text: formatMinutes(l, d.totalMinutes ?? d.cookMinutes!),
                ),
              if (d.servings != null)
                _Fact(
                  icon: Icons.people_outline,
                  text:
                      '${formatNumber(d.servings!)} ${d.servingsUnit ?? l.peopleUnit}',
                ),
              if (data.imageUrls.isNotEmpty)
                _Fact(
                  icon: Icons.photo_library_outlined,
                  text: l.previewPhotos(data.imageUrls.length),
                ),
            ],
          ),
          if (data.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bep.infoContainer,
                borderRadius: BepRadius.circular(BepRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.download_for_offline_outlined,
                    color: bep.onInfoContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.webDownloadNote,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: bep.onInfoContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _Section(
            title: l.ingredients,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ingredients.isEmpty)
                  Text(
                    l.previewMissingIngredients,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final line in d.ingredients)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        line.isHeading
                            ? line.text
                            : '• ${line.text}',
                        style: line.isHeading
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.bodyMedium,
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: l.steps,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (steps.isEmpty)
                  Text(
                    l.previewMissingSteps,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final (i, step) in d.steps.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!step.isHeading)
                            SizedBox(
                              width: 26,
                              child: Text(
                                '${d.steps.take(i).where((e) => !e.isHeading).length + 1}.',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              step.text,
                              style: step.isHeading
                                  ? theme.textTheme.titleSmall
                                  : theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _edit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.previewEdit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(l.previewSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BepRadius.circular(BepRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
