import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart';
import '../../data/image_store.dart';
import '../../data/recipe_lines.dart';
import '../../data/recipe_repository.dart';
import '../../data/text_normalize.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';
import '../../ui/recipe_photo.dart';
import '../recipes/recipe_detail_screen.dart' show difficultyLabel;
import 'category_picker.dart';

/// Soạn công thức mới ([id] null) hoặc sửa công thức [id] (AC-02, AC-03).
class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.id, this.initialDraft});

  final int? id;

  /// Bản nháp có sẵn cho công thức MỚI (nhập từ web, chữ được chia sẻ). Ảnh
  /// trong đó coi như vừa thêm: bỏ thay đổi thì file bị xóa. Chưa lưu mà thoát
  /// thì có hỏi bỏ (F-03, AC-20).
  final RecipeDraft? initialDraft;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _servings = TextEditingController();
  final _servingsUnit = TextEditingController();
  final _prep = TextEditingController();
  final _cook = TextEditingController();
  final _total = TextEditingController();
  final _source = TextEditingController();
  final _sourceUrl = TextEditingController();
  final _notes = TextEditingController();
  final _nutrition = TextEditingController();
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();
  late final List<TextEditingController> _controllers = [
    _name,
    _servings,
    _servingsUnit,
    _prep,
    _cook,
    _total,
    _source,
    _sourceUrl,
    _notes,
    _nutrition,
    _ingredients,
    _steps,
  ];

  Difficulty? _difficulty;
  int _rating = 0;
  bool _favorite = false;
  List<String> _photos = [];
  List<int> _categoryIds = [];
  List<String> _tags = [];
  final _tagInput = TextEditingController();
  List<String> _tagSuggestions = [];
  int _suggestSeq = 0;

  /// Ảnh vừa thêm trong lần soạn này; xóa file nếu người dùng bỏ thay đổi.
  final _added = <String>[];
  late RecipeDraft _initial;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_changed);
    }
    _tagInput.addListener(_tagInputChanged);
    _load();
  }

  Future<void> _load() async {
    final id = widget.id;
    if (id != null) {
      final r = await ref.read(recipeRepositoryProvider).getRecipe(id);
      if (!mounted) return;
      if (r == null) {
        context.pop();
        return;
      }
      _fill(r.draft);
      _initial = _draft();
    } else if (widget.initialDraft != null) {
      _fill(widget.initialDraft!);
      _added.addAll(widget.initialDraft!.photos);
      _initial = const RecipeDraft(name: '');
    } else {
      _initial = _draft();
    }
    setState(() => _loaded = true);
  }

  void _fill(RecipeDraft d) {
    _name.text = d.name;
    _servings.text = d.servings == null ? '' : _num(d.servings!);
    _servingsUnit.text = d.servingsUnit ?? '';
    _prep.text = d.prepMinutes?.toString() ?? '';
    _cook.text = d.cookMinutes?.toString() ?? '';
    _total.text = d.totalMinutes?.toString() ?? '';
    _source.text = d.source ?? '';
    _sourceUrl.text = d.sourceUrl ?? '';
    _notes.text = d.notes ?? '';
    _nutrition.text = d.nutrition ?? '';
    _ingredients.text = serializeLines(d.ingredients);
    _steps.text = serializeLines(d.steps);
    _difficulty = d.difficulty;
    _rating = d.rating;
    _favorite = d.favorite;
    _photos = [...d.photos];
    _categoryIds = [...d.categoryIds]..sort();
    _tags = [...d.tags];
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : v.toString();

  String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  RecipeDraft _draft() => RecipeDraft(
    name: _name.text,
    servings: double.tryParse(_servings.text.trim().replaceAll(',', '.')),
    servingsUnit: _text(_servingsUnit),
    prepMinutes: _int(_prep),
    cookMinutes: _int(_cook),
    totalMinutes: _int(_total),
    source: _text(_source),
    sourceUrl: _text(_sourceUrl),
    notes: _text(_notes),
    nutrition: _text(_nutrition),
    difficulty: _difficulty,
    rating: _rating,
    favorite: _favorite,
    ingredients: parseLines(_ingredients.text, LineSection.ingredient),
    steps: parseLines(_steps.text, LineSection.step),
    photos: _photos,
    categoryIds: _categoryIds,
    tags: _allTags(),
  );

  /// Thẻ đã thêm cùng chữ đang gõ dở trong ô thẻ (không bị mất khi Lưu).
  List<String> _allTags() {
    final pending = _tagInput.text.trim();
    return [..._tags, if (pending.isNotEmpty) pending];
  }

  void _addTag(String raw) {
    final tag = raw.trim();
    if (tag.isEmpty) return;
    final key = normalizeText(tag);
    if (_tags.any((t) => normalizeText(t) == key)) {
      _tagInput.clear();
      return;
    }
    setState(() => _tags = [..._tags, tag]);
    _tagInput.clear();
  }

  void _tagInputChanged() {
    final text = _tagInput.text;
    if (text.contains(',')) {
      final parts = text.split(',');
      for (final p in parts.take(parts.length - 1)) {
        _addTag(p);
      }
      _tagInput.text = parts.last;
      _tagInput.selection = TextSelection.collapsed(offset: parts.last.length);
      return;
    }
    _changed();
    final seq = ++_suggestSeq;
    ref.read(recipeRepositoryProvider).suggestTags(text).then((list) {
      if (!mounted || seq != _suggestSeq) return;
      final have = _tags.map(normalizeText).toSet();
      setState(
        () => _tagSuggestions = [
          for (final t in list)
            if (!have.contains(normalizeText(t))) t,
        ].take(8).toList(),
      );
    });
  }

  bool get _dirty => _loaded && _draft() != _initial;

  void _changed() {
    if (mounted && _loaded) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _tagInput.dispose();
    super.dispose();
  }

  Future<void> _addPhotos(
    Future<List<String>> Function(int remaining) pick,
  ) async {
    final l = AppLocalizations.of(context);
    final remaining = maxRecipePhotos - _photos.length;
    if (remaining <= 0) {
      showMessage(l.tooManyPhotos);
      return;
    }
    final store = ref.read(imageStoreProvider);
    final paths = await pick(remaining);
    var failed = false;
    for (final path in paths.take(remaining)) {
      try {
        final name = await store.importImage(path);
        _added.add(name);
        if (mounted) setState(() => _photos = [..._photos, name]);
      } on ImageImportException {
        failed = true;
      }
    }
    if (failed) showMessage(l.imageError);
  }

  void _showPhotoSheet() {
    final l = AppLocalizations.of(context);
    final picker = ref.read(photoPickerProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.fromGallery),
              onTap: () {
                Navigator.pop(sheet);
                _addPhotos((n) => picker.pickFromGallery(limit: n));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.takePhoto),
              onTap: () {
                Navigator.pop(sheet);
                _addPhotos((_) async {
                  final p = await picker.takePhoto();
                  return [?p];
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removePhoto(String name) async {
    setState(() => _photos = _photos.where((p) => p != name).toList());
    // Ảnh vừa thêm mà bỏ ngay thì xóa file luôn; ảnh đã lưu chỉ bị xóa khi Lưu.
    if (_added.remove(name)) await ref.read(imageStoreProvider).delete(name);
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(recipeRepositoryProvider)
          .save(_draft(), id: widget.id);
      _added.clear();
      _initial = _draft();
      if (!mounted) return;
      if (widget.initialDraft != null) {
        // Từ màn nhập web: bỏ luôn trình duyệt khỏi ngăn xếp.
        context.go('/recipe/$id');
      } else if (widget.id == null) {
        context.pushReplacement('/recipe/$id');
      } else {
        context.pop();
      }
    } on RecipeValidationException {
      if (mounted) setState(() => _saving = false);
      _formKey.currentState?.validate();
    }
  }

  Future<void> _confirmDiscard() async {
    final l = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.discardTitle),
        content: Text(l.discardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.discard),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    // Đóng màn trước rồi mới xóa file: ảnh còn đang hiện thì Windows giữ file.
    final store = ref.read(imageStoreProvider);
    final added = [..._added];
    _added.clear();
    context.pop();
    for (final name in added) {
      await store.delete(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dirty = _dirty;
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.id == null ? l.newRecipe : l.editRecipe),
          actions: [
            TextButton(
              onPressed: _loaded && !_saving ? _save : null,
              child: Text(l.save),
            ),
          ],
        ),
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(labelText: l.name),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return l.nameRequired;
                        if (t.length > maxRecipeName) return l.nameTooLong;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _photoStrip(l),
                    const SizedBox(height: 16),
                    _categoryField(l),
                    const SizedBox(height: 16),
                    _tagField(l),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ingredients,
                      decoration: InputDecoration(
                        labelText: l.ingredients,
                        helperText: l.ingredientsHint,
                        helperMaxLines: 2,
                        alignLabelWithHint: true,
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _steps,
                      decoration: InputDecoration(
                        labelText: l.steps,
                        helperText: l.stepsHint,
                        helperMaxLines: 2,
                        alignLabelWithHint: true,
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _servings,
                            decoration: InputDecoration(labelText: l.servings),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _servingsUnit,
                            decoration: InputDecoration(
                              labelText: l.servingsUnit,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        for (final (c, label) in [
                          (_prep, l.prepTime),
                          (_cook, l.cookTime),
                          (_total, l.totalTime),
                        ])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: TextField(
                                controller: c,
                                decoration: InputDecoration(labelText: label),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Difficulty?>(
                      initialValue: _difficulty,
                      decoration: InputDecoration(labelText: l.difficulty),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l.difficultyNone),
                        ),
                        for (final d in Difficulty.values)
                          DropdownMenuItem(
                            value: d,
                            child: Text(difficultyLabel(l, d)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _difficulty = v),
                    ),
                    const SizedBox(height: 16),
                    _ratingRow(l),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.favorite),
                      value: _favorite,
                      onChanged: (v) => setState(() => _favorite = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _source,
                      decoration: InputDecoration(labelText: l.source),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _sourceUrl,
                      decoration: InputDecoration(labelText: l.sourceUrl),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notes,
                      decoration: InputDecoration(
                        labelText: l.notes,
                        alignLabelWithHint: true,
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nutrition,
                      decoration: InputDecoration(labelText: l.nutrition),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _categoryField(AppLocalizations l) {
    final all = ref.watch(categoriesProvider).value ?? const [];
    final names = {for (final c in all) c.id: c.name};
    return InputDecorator(
      decoration: InputDecoration(labelText: l.filterCategories),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final id in _categoryIds)
            if (names[id] != null)
              InputChip(
                label: Text(names[id]!),
                onDeleted: () => setState(
                  () => _categoryIds = _categoryIds
                      .where((x) => x != id)
                      .toList(),
                ),
              ),
          if (_categoryIds.isEmpty) Text(l.noCategories),
          ActionChip(
            avatar: const Icon(Icons.folder_open, size: 18),
            label: Text(l.chooseCategories),
            onPressed: () async {
              final picked = await pickCategories(
                context,
                all,
                _categoryIds.toSet(),
              );
              if (picked != null) {
                setState(() => _categoryIds = picked.toList()..sort());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _tagField(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _tagInput,
        decoration: InputDecoration(
          labelText: l.tagsLabel,
          helperText: l.tagsHint,
          helperMaxLines: 2,
          errorText: _tagInput.text.trim().length > maxTagLength
              ? l.tagTooLong
              : null,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: _addTag,
      ),
      if (_tags.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            children: [
              for (final t in _tags)
                InputChip(
                  label: Text(t),
                  deleteButtonTooltipMessage: l.removeTag(t),
                  onDeleted: () => setState(
                    () => _tags = _tags.where((x) => x != t).toList(),
                  ),
                ),
            ],
          ),
        ),
      if (_tagSuggestions.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            children: [
              for (final t in _tagSuggestions)
                ActionChip(label: Text(t), onPressed: () => _addTag(t)),
            ],
          ),
        ),
    ],
  );

  Widget _ratingRow(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l.rating, style: Theme.of(context).textTheme.labelLarge),
      Row(
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              tooltip: l.ratingStars(i),
              icon: Icon(
                i <= _rating ? Icons.star : Icons.star_border,
                color: Colors.amber.shade700,
              ),
              // Bấm lại đúng số sao đang chọn thì về 0.
              onPressed: () => setState(() => _rating = _rating == i ? 0 : i),
            ),
        ],
      ),
    ],
  );

  Widget _photoStrip(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l.photos, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      SizedBox(
        height: 104,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var i = 0; i < _photos.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 104,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: RecipePhoto(_photos[i], cacheWidth: 300),
                      ),
                      if (i == 0)
                        Positioned(
                          left: 4,
                          bottom: 4,
                          child: Chip(
                            label: Text(l.coverPhoto),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton.filledTonal(
                          tooltip: l.removePhoto,
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removePhoto(_photos[i]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: 104,
              child: OutlinedButton(
                onPressed: _showPhotoSheet,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined),
                    const SizedBox(height: 4),
                    Text(
                      l.addPhotos,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
