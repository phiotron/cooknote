import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_lines.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../scan/line_classifier.dart';
import '../../ui/messenger.dart';
import 'scan_screen.dart';

/// Gán dòng chữ nhận được từ ảnh vào tên, nguyên liệu, các bước hoặc ghi chú
/// (SCR-21, AC-24). Chạm để chọn nhiều dòng, giữ để sửa chữ.
class ScanAssignScreen extends ConsumerStatefulWidget {
  const ScanAssignScreen({super.key, this.pages});

  /// [ScanPayload] do màn quét gửi sang.
  final Object? pages;

  @override
  ConsumerState<ScanAssignScreen> createState() => _ScanAssignScreenState();
}

class _Line {
  _Line({
    required this.text,
    required this.role,
    required this.page,
    required this.doubtful,
    this.selected = true,
  });

  String text;
  LineRole role;
  final int page;
  final bool doubtful;
  bool selected;
}

class _ScanAssignScreenState extends ConsumerState<ScanAssignScreen> {
  final List<_Line> _lines = [];
  bool _keepPhotos = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final payload = widget.pages;
    if (payload is ScanPayload) {
      for (final line in payload.result.lines) {
        final role = line.suggestion.role;
        _lines.add(
          _Line(
            text: line.suggestion.text,
            role: role,
            page: line.page,
            doubtful: line.isDoubtful,
            selected: role != LineRole.noise,
          ),
        );
      }
    }
  }

  List<_Line> get _selected => [for (final l in _lines) if (l.selected) l];

  void _assign(LineRole role) {
    final chosen = _selected;
    if (chosen.isEmpty) {
      showMessage(AppLocalizations.of(context).scanSelectFirst);
      return;
    }
    setState(() {
      for (final l in chosen) {
        l.role = role;
        l.selected = false;
      }
    });
  }

  Future<void> _edit(_Line line) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: line.text);
    var role = line.role;
    final result = await showDialog<(String, LineRole)>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setDialogState) => AlertDialog(
          title: Text(l.scanEditLine),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.scanLineText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LineRole>(
                initialValue: role,
                decoration: InputDecoration(labelText: l.scanLineRole),
                items: [
                  for (final r in LineRole.values)
                    DropdownMenuItem(value: r, child: Text(_roleName(l, r))),
                ],
                onChanged: (r) => setDialogState(() => role = r ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialog, (controller.text.trim(), role)),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result == null || result.$1.isEmpty || !mounted) return;
    setState(() {
      line.text = result.$1;
      line.role = result.$2;
      line.selected = false;
    });
  }

  Future<void> _continue() async {
    if (_saving) return;
    final l = AppLocalizations.of(context);
    final chosen = [
      for (final l in _lines)
        if (l.role != LineRole.noise && l.text.trim().isNotEmpty) l,
    ];
    if (chosen.isEmpty) {
      showMessage(l.scanSelectFirst);
      return;
    }
    setState(() => _saving = true);
    try {
      var photos = const <String>[];
      final payload = widget.pages;
      if (_keepPhotos && payload is ScanPayload) {
        photos = await _importPhotos(payload.result.imagePaths);
      }
      if (!mounted) return;
      final titles = [
        for (final l in chosen)
          if (l.role == LineRole.title) l.text.trim(),
      ];
      final name = titles.isNotEmpty ? titles.first : '';
      final otherTitles = titles.skip(1).toList();
      final ingredients = <RecipeLine>[];
      final steps = <RecipeLine>[];
      final notes = <String>[];
      for (final l in chosen) {
        switch (l.role) {
          case LineRole.ingredient:
            ingredients.add(RecipeLine(l.text.trim()));
          case LineRole.heading:
            ingredients.add(RecipeLine(l.text.trim(), isHeading: true));
          case LineRole.step:
            steps.add(RecipeLine(l.text.trim()));
          case LineRole.note:
            notes.add(l.text.trim());
          case LineRole.title:
            break;
          case LineRole.noise:
            break;
        }
      }
      steps.addAll([
        for (final t in otherTitles)
          if (t.isNotEmpty) RecipeLine(t),
      ]);
      context.push(
        '/recipe/new',
        extra: RecipeDraft(
          name: name,
          ingredients: ingredients,
          steps: steps,
          notes: notes.isEmpty ? null : notes.join('\n'),
          photos: photos,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<List<String>> _importPhotos(List<String> paths) async {
    final store = ref.read(imageStoreProvider);
    final out = <String>[];
    for (final path in paths.take(10)) {
      try {
        out.add(await store.importImage(path));
      } on Object {
        // Ảnh không đọc được thì bỏ, không chặn việc lưu công thức.
      }
    }
    return out;
  }

  static String _roleName(AppLocalizations l, LineRole role) => switch (role) {
    LineRole.title => l.scanLineName,
    LineRole.ingredient || LineRole.heading => l.scanLineIngredients,
    LineRole.step => l.scanLineSteps,
    LineRole.note => l.scanLineNote,
    LineRole.noise => l.scanLineSkip,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final count = _selected.length;
    return Scaffold(
      appBar: AppBar(title: Text(l.scanAssignTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l.scanAssignHint,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: _lines.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.scanNoLines),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: _lines.length,
                    itemBuilder: (context, i) {
                      final line = _lines[i];
                      final newPage =
                          i == 0 || _lines[i - 1].page != line.page;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (newPage)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(
                                l.scanPage(line.page + 1),
                                style: theme.textTheme.labelLarge!.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          _LineTile(
                            line: line,
                            onTap: () =>
                                setState(() => line.selected = !line.selected),
                            onLongPress: () => _edit(line),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Material(
          elevation: 8,
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  value: _keepPhotos,
                  onChanged: (v) => setState(() => _keepPhotos = v ?? false),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.scanKeepPhotos),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        count == 0 ? l.scanAssignHint : l.scanSelected(count),
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _saving ? null : _continue,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l.continueLabel),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final role in const [
                      LineRole.title,
                      LineRole.ingredient,
                      LineRole.step,
                      LineRole.note,
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: OutlinedButton(
                            onPressed: () => _assign(role),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 10,
                              ),
                              textStyle: theme.textTheme.labelMedium,
                            ),
                            child: Text(
                              _roleName(l, role),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({
    required this.line,
    required this.onTap,
    required this.onLongPress,
  });

  final _Line line;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final role = _ScanAssignScreenState._roleName(l, line.role);
    return Material(
      color: line.selected
          ? theme.colorScheme.secondaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                line.selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: line.selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.text,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (line.doubtful)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Tooltip(
                    message: l.scanDoubtful,
                    child: Icon(
                      Icons.spellcheck,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
