import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/recipe_lines.dart';
import '../../data/recipe_repository.dart';

enum _Target { name, ingredients, steps, notes }

/// Chọn chữ trên trang (SCR-16, AC-19) khi trang không có dữ liệu Recipe.
///
/// Trình duyệt đã có bảng chọn đoạn ngay trên trang; màn này là đường dự
/// phòng cho chữ dán tay: dán chữ, chọn phần rồi mở trình soạn để sửa.
class PickTextScreen extends StatefulWidget {
  const PickTextScreen({super.key, this.source});

  final Object? source;

  @override
  State<PickTextScreen> createState() => _PickTextScreenState();
}

class _PickTextScreenState extends State<PickTextScreen> {
  late final TextEditingController _text = TextEditingController(
    text: switch (widget.source) {
      final String s => s,
      final RecipeDraft d => d.notes ?? '',
      _ => '',
    },
  );
  _Target _target = _Target.ingredients;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _continue() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final draft = switch (_target) {
      _Target.name => RecipeDraft(name: text),
      _Target.ingredients => RecipeDraft(
        name: '',
        ingredients: [
          for (final line in text.split('\n'))
            if (line.trim().isNotEmpty) RecipeLine(line.trim()),
        ],
      ),
      _Target.steps => RecipeDraft(
        name: '',
        steps: [
          for (final line in text.split('\n'))
            if (line.trim().isNotEmpty) RecipeLine(line.trim()),
        ],
      ),
      _Target.notes => RecipeDraft(name: '', notes: text),
    };
    context.push('/recipe/new', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final targets = {
      _Target.name: l.name,
      _Target.ingredients: l.ingredients,
      _Target.steps: l.steps,
      _Target.notes: l.notes,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.pickText)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.pickTextHint),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            minLines: 6,
            maxLines: 12,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l.pickTextContent,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.pickTextTarget, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in targets.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _target == entry.key,
                  onSelected: (_) => setState(() => _target = entry.key),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _text.text.trim().isEmpty ? null : _continue,
            icon: const Icon(Icons.arrow_forward),
            label: Text(l.continueLabel),
          ),
        ),
      ),
    );
  }
}
