import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/recipe_lines.dart';
import '../data/recipe_repository.dart';
import 'browser_engine.dart';
import 'browser_input.dart';
import 'recipe_extractor.dart';

/// Thời gian chờ mỗi lần tải trang (AC-21).
const pageLoadTimeout = Duration(seconds: 20);

enum SelectionKind { name, ingredients, steps }

/// Các đoạn chữ người dùng bôi đen ở chế độ "Chọn đoạn" (AC-19).
class SelectionParts {
  String? name;
  final List<String> ingredients = [];
  final List<String> steps = [];

  bool get isEmpty => name == null && ingredients.isEmpty && steps.isEmpty;

  void clear() {
    name = null;
    ingredients.clear();
    steps.clear();
  }
}

/// Gom các đoạn đã chọn thành bản nháp (AC-19, AC-20). Tên thiếu thì lấy tên
/// trang; URL nguồn và tên trang được giữ lại.
RecipeDraft draftFromSelection(
  SelectionParts parts, {
  String? pageUrl,
  String? pageTitle,
}) {
  final title = pageTitle?.replaceAll(RegExp(r'\s+'), ' ').trim();
  final name = parts.name ?? title ?? '';
  return RecipeDraft(
    name: name.length > maxRecipeName ? name.substring(0, maxRecipeName) : name,
    source: title == null || title.isEmpty ? null : title,
    sourceUrl: pageUrl,
    ingredients: parseLines(
      parts.ingredients.join('\n'),
      LineSection.ingredient,
    ),
    steps: parseLines(parts.steps.join('\n'), LineSection.step),
  );
}

sealed class CaptureOutcome {
  const CaptureOutcome();
}

/// Trang có dữ liệu công thức.
class CaptureFound extends CaptureOutcome {
  const CaptureFound(this.recipe);
  final WebRecipe recipe;
}

/// Trang không có dữ liệu Recipe: chuyển sang chế độ "Chọn đoạn".
class CaptureNeedsSelection extends CaptureOutcome {
  const CaptureNeedsSelection();
}

/// Đã chọn đoạn xong: bản nháp gom từ các đoạn.
class CaptureFromSelection extends CaptureOutcome {
  const CaptureFromSelection(this.draft);
  final RecipeDraft draft;
}

class CaptureFailed extends CaptureOutcome {
  const CaptureFailed(this.failure);
  final LoadFailure failure;
}

/// Trạng thái của trình duyệt trong app, không phụ thuộc WebView thật (F-03).
/// Thời gian chờ 20 giây (AC-21), lỗi kèm lý do, thử lại, và các đoạn chọn
/// được giữ nguyên qua lỗi tải.
class BrowserSession extends ChangeNotifier implements BrowserEvents {
  BrowserSession(this.engine, {this.timeout = pageLoadTimeout}) {
    engine.attach(this);
  }

  final BrowserEngine engine;
  final Duration timeout;

  Uri? url;
  String? title;
  bool loading = false;
  LoadFailure? failure;
  bool canGoBack = false;
  bool canGoForward = false;

  /// Chế độ "Chọn đoạn" đang bật (AC-19).
  bool selectionMode = false;
  final SelectionParts parts = SelectionParts();

  Uri? _requested;
  Timer? _timer;
  bool _disposed = false;

  /// Mở địa chỉ hoặc tìm từ khóa người dùng gõ (AC-16).
  Future<void> submit(String input) async {
    final uri = resolveBrowserInput(input);
    if (uri != null) await open(uri);
  }

  Future<void> open(Uri uri) async {
    _requested = uri;
    _begin(uri);
    try {
      await engine.load(uri);
    } catch (_) {
      onFailure(const LoadFailure(LoadFailureKind.other));
    }
  }

  /// Nút "Thử lại" (AC-21): tải lại trang vừa lỗi.
  Future<void> retry() async {
    final target = failure == null ? null : (_requested ?? url);
    if (target == null) {
      await engine.reload();
      return;
    }
    await open(target);
  }

  Future<void> goBack() => engine.goBack();
  Future<void> goForward() => engine.goForward();
  Future<void> reload() => engine.reload();

  void _begin(Uri? at) {
    failure = null;
    loading = true;
    if (at != null) url = at;
    _timer?.cancel();
    _timer = Timer(timeout, () {
      if (!loading) return;
      loading = false;
      failure = const LoadFailure(LoadFailureKind.timeout);
      _notify();
    });
    _notify();
  }

  @override
  void onPageStarted(Uri? at) => _begin(at);

  @override
  void onPageFinished(Uri? at) {
    _timer?.cancel();
    loading = false;
    if (at != null) url = at;
    // Trang tới chậm sau khi đã báo hết giờ thì vẫn dùng được.
    if (failure?.kind == LoadFailureKind.timeout) failure = null;
    _notify();
    _refreshNav();
  }

  @override
  void onFailure(LoadFailure f) {
    _timer?.cancel();
    loading = false;
    failure = f;
    _notify();
  }

  @override
  void onUrlChanged(Uri at) {
    url = at;
    _notify();
    _refreshNav();
  }

  Future<void> _refreshNav() async {
    try {
      final back = await engine.canGoBack();
      final fwd = await engine.canGoForward();
      final t = await engine.title();
      if (_disposed) return;
      canGoBack = back;
      canGoForward = fwd;
      if (t != null && t.trim().isNotEmpty) title = t.trim();
      notifyListeners();
    } catch (_) {
      // Chỉ là trạng thái nút; bỏ qua.
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Nút "Lưu công thức" (AC-16): có đoạn đã chọn thì gom thành bản nháp; chưa
  /// thì đọc HTML trang hiện tại và trích công thức (AC-18); trang không có
  /// công thức thì bật chế độ "Chọn đoạn" (AC-19).
  Future<CaptureOutcome> capture() async {
    if (!parts.isEmpty) {
      return CaptureFromSelection(
        draftFromSelection(
          parts,
          pageUrl: url?.toString(),
          pageTitle: title,
        ),
      );
    }
    final current = failure;
    if (current != null) return CaptureFailed(current);
    final String html;
    try {
      final at = await engine.currentUrl();
      if (at != null) url = at;
      html = await engine.outerHtml().timeout(timeout);
    } catch (_) {
      const f = LoadFailure(LoadFailureKind.other);
      failure = f;
      _notify();
      return const CaptureFailed(f);
    }
    final found = extractRecipeFromHtml(html, pageUrl: url);
    if (found != null) {
      final t = title;
      if (found.draft.source == null && t != null && t.isNotEmpty) {
        return CaptureFound(
          WebRecipe(
            draft: RecipeDraft(
              name: found.draft.name,
              servings: found.draft.servings,
              servingsUnit: found.draft.servingsUnit,
              prepMinutes: found.draft.prepMinutes,
              cookMinutes: found.draft.cookMinutes,
              totalMinutes: found.draft.totalMinutes,
              source: t,
              sourceUrl: found.draft.sourceUrl,
              notes: found.draft.notes,
              nutrition: found.draft.nutrition,
              ingredients: found.draft.ingredients,
              steps: found.draft.steps,
            ),
            imageUrls: found.imageUrls,
          ),
        );
      }
      return CaptureFound(found);
    }
    selectionMode = true;
    _notify();
    return const CaptureNeedsSelection();
  }

  /// Lấy chữ đang bôi đen trên trang gán vào [kind]; false nếu chưa chọn gì.
  Future<bool> addSelection(SelectionKind kind) async {
    final String raw;
    try {
      raw = await engine.selectedText();
    } catch (_) {
      return false;
    }
    final lines = [
      for (final l in raw.split(RegExp(r'\r?\n|\r')))
        if (l.replaceAll(RegExp(r'\s+'), ' ').trim().isNotEmpty)
          l.replaceAll(RegExp(r'\s+'), ' ').trim(),
    ];
    if (lines.isEmpty) return false;
    switch (kind) {
      case SelectionKind.name:
        parts.name = lines.join(' ');
      case SelectionKind.ingredients:
        parts.ingredients.addAll(lines);
      case SelectionKind.steps:
        parts.steps.addAll(lines);
    }
    _notify();
    return true;
  }

  void clearParts() {
    parts.clear();
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    engine.dispose();
    super.dispose();
  }
}
