import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/category_repository.dart';

/// Hộp chọn nhiều danh mục cho một công thức (AC-10). Trả về các id đã chọn,
/// null nếu hủy.
Future<Set<int>?> pickCategories(
  BuildContext context,
  List<Category> all,
  Set<int> selected,
) => showDialog<Set<int>>(
  context: context,
  builder: (_) => _PickerDialog(all: all, selected: selected),
);

class _PickerDialog extends StatefulWidget {
  const _PickerDialog({required this.all, required this.selected});

  final List<Category> all;
  final Set<int> selected;

  @override
  State<_PickerDialog> createState() => _PickerDialogState();
}

class _PickerDialogState extends State<_PickerDialog> {
  late final Set<int> _selected = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.chooseCategories),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.all.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.categoriesEmpty),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final c in widget.all)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.only(
                        left: 16.0 + (c.depth - 1) * 20,
                        right: 16,
                      ),
                      title: Text(c.name),
                      value: _selected.contains(c.id),
                      onChanged: (on) => setState(() {
                        on == true
                            ? _selected.add(c.id)
                            : _selected.remove(c.id);
                      }),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text(l.done),
        ),
      ],
    );
  }
}
