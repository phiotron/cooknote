import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../cook/cook_providers.dart';
import '../../cook/cook_store.dart';
import '../../cook/platform_services.dart';
import '../../cook/recipe_view.dart';
import '../../cook/timer_engine.dart';
import '../../cooking/step_timers.dart';
import '../../data/recipe_lines.dart';
import '../../data/recipe_repository.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';
import '../../ui/theme/theme.dart';

/// Tên công thức cho thanh ghim.
final _recipeNameProvider = StreamProvider.family<String?, int>(
  (ref, id) => ref
      .watch(recipeRepositoryProvider)
      .watchRecipe(id)
      .map((r) => r?.draft.name),
);

/// Chế độ nấu (SCR-23, AC-26..AC-30).
///
/// Toàn màn hình, không có thanh dưới; rời màn thì hẹn giờ vẫn chạy. Nguyên
/// liệu và bước đã gạch được lưu 12 giờ (AC-26).
class CookScreen extends ConsumerStatefulWidget {
  const CookScreen({super.key, required this.recipeId});

  final int recipeId;

  @override
  ConsumerState<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends ConsumerState<CookScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  late final ScreenAwake _awake;
  late final SpeechService _speech;
  CookProgress _progress = CookProgress.empty;
  double _fontScale = CookStore.defaultFontScale;
  bool _loaded = false;
  bool _speaking = false;

  int get _id => widget.recipeId;

  @override
  void initState() {
    super.initState();
    _awake = ref.read(screenAwakeProvider);
    _speech = ref.read(speechProvider);
    final store = ref.read(cookStoreProvider);
    store.loadProgress(_id).then((p) {
      if (mounted) setState(() => _progress = p);
    });
    store.fontScale().then((v) {
      if (mounted) setState(() => _fontScale = v);
    });
    _awake.enable();
    ref.read(timersProvider.notifier).refreshPermission();
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _awake.disable();
    _speech.stop();
    super.dispose();
  }

  void _saveProgress(CookProgress p) {
    setState(() => _progress = p);
    ref.read(cookStoreProvider).saveProgress(_id, p);
  }

  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.cookStartOver),
        content: Text(l.cookStartOverHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.cookStartOver),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(cookStoreProvider).clearProgress(_id);
    if (mounted) setState(() => _progress = CookProgress.empty);
  }

  Future<void> _togglePin() async {
    final l = AppLocalizations.of(context);
    final store = ref.read(cookStoreProvider);
    final pins = ref.read(cookPinsProvider).value ?? const <int>[];
    if (pins.contains(_id)) {
      await store.unpin(_id);
      return;
    }
    final ok = await store.pin(_id);
    if (!ok && mounted) showMessage(l.cookPinLimit(CookStore.maxPins));
  }

  Future<void> _cycleFont() async {
    const steps = [1.0, 1.3, 1.6, 2.0];
    final i = steps.indexWhere((s) => s >= _fontScale - 0.01);
    final next = steps[(i < 0 ? 0 : i + 1) % steps.length];
    setState(() => _fontScale = next);
    await ref.read(cookStoreProvider).setFontScale(next);
  }

  Future<void> _read(String text) async {
    if (_speaking) {
      await ref.read(speechProvider).stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    final l = AppLocalizations.of(context);
    final language = detectSpeechLanguage(text);
    setState(() => _speaking = true);
    final result = await ref.read(speechProvider).speak(text, language);
    if (!mounted) return;
    setState(() => _speaking = false);
    switch (result) {
      case SpeakResult.ok:
        break;
      case SpeakResult.noVoice:
        await showDialog<void>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: Text(l.noVoiceTitle(language)),
            content: Text(l.noVoiceBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog),
                child: Text(l.close),
              ),
            ],
          ),
        );
      case SpeakResult.error:
        showMessage(l.speakError);
    }
  }

  Future<void> _startTimer(StepTimer timer, String stepLabel, String recipe) async {
    final l = AppLocalizations.of(context);
    final store = ref.read(cookStoreProvider);
    final notifications = ref.read(timerNotificationsProvider);
    if (!await store.notificationAsked()) {
      if (!mounted) return;
      final go = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          icon: const Icon(Icons.notifications_active_outlined),
          title: Text(l.notifRationaleTitle),
          content: Text(l.notifRationaleBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(l.notifLater),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(l.notifContinue),
            ),
          ],
        ),
      );
      if (!mounted) return;
      await store.setNotificationAsked();
      if (go == true) {
        final granted = await notifications.requestPermission();
        if (!granted && mounted) showMessage(l.notifDeniedWarning);
        await ref.read(timersProvider.notifier).refreshPermission();
      }
    }
    if (!mounted) return;
    final name = l.timerName(stepLabel, timer.label);
    final same = ref
        .read(timersProvider)
        .running
        .any((t) => t.recipeId == _id && t.name == name);
    if (same) {
      showMessage(l.timerAlreadyStarted);
      return;
    }
    await ref
        .read(timersProvider.notifier)
        .start(
          name: name,
          recipeId: _id,
          recipeName: recipe,
          seconds: timer.seconds,
          notificationTitle: l.timerDone(name),
          notificationBody: l.timerNotifBody(recipe),
          channelName: l.notifChannelName,
          channelDescription: l.notifChannelDescription,
        );
    if (mounted) showMessage(l.timerStarted);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final recipe = ref.watch(recipeProvider(_id)).value;
    final pins = ref.watch(cookPinsProvider).value ?? const <int>[];
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.cookModeTitle)),
        body: _loaded
            ? Center(child: Text(l.recipeMissing))
            : const Center(child: CircularProgressIndicator()),
      );
    }
    final d = recipe.draft;
    final headingSteps = {
      for (var i = 0; i < d.steps.length; i++)
        if (d.steps[i].isHeading) i,
    };
    final stepCount = d.steps.length - headingSteps.length;
    final current = _progress.currentStep(d.steps.length, skip: headingSteps);
    final running = ref.watch(timersProvider).running.where(
      (t) => t.recipeId == _id,
    );
    final now = ref.read(clockProvider)();
    return Scaffold(
      appBar: AppBar(
        title: Text(d.name),
        actions: [
          IconButton(
            tooltip: pins.contains(_id) ? l.cookUnpin : l.cookPin,
            onPressed: _togglePin,
            icon: Icon(
              pins.contains(_id) ? Icons.push_pin : Icons.push_pin_outlined,
            ),
          ),
          IconButton(
            tooltip: l.cookFontSize,
            onPressed: _cycleFont,
            icon: const Icon(Icons.text_fields),
          ),
          PopupMenuButton<String>(
            tooltip: l.moreActions,
            onSelected: (v) {
              if (v == 'reset') _reset();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'reset', child: Text(l.cookStartOver)),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l.ingredients),
            Tab(text: l.steps),
          ],
        ),
      ),
      body: Column(
        children: [
          if (pins.isNotEmpty) _PinsBar(pins: pins, current: _id),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _ingredientsTab(l, d),
                _stepsTab(l, d, current, stepCount, running, now),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientsTab(AppLocalizations l, RecipeDraft d) {
    final lines = d.ingredients;
    final shown = ingredientsView(lines, RecipeView.original);
    if (shown.isEmpty) {
      return Center(child: Text(l.cookNoIngredients));
    }
    final done = _progress.ingredients.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.cookIngredientsDone(done, shown.length),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final line = shown[i];
              if (line.isHeading) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    line.text,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                );
              }
              final struck = _progress.ingredients.contains(i);
              return CheckboxListTile(
                value: struck,
                onChanged: (_) => _saveProgress(_progress.toggleIngredient(i)),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  line.text,
                  style: TextStyle(
                    fontSize: 16 * _fontScale,
                    decoration: struck ? TextDecoration.lineThrough : null,
                    color: struck
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _stepsTab(
    AppLocalizations l,
    RecipeDraft d,
    int? current,
    int stepCount,
    Iterable<CookTimer> running,
    DateTime now,
  ) {
    final steps = d.steps;
    if (steps.isEmpty) return Center(child: Text(l.cookNoSteps));
    final heading = {
      for (var i = 0; i < steps.length; i++)
        if (steps[i].isHeading) i,
    };
    int numberAt(int i) =>
        i - heading.where((h) => h < i).length + (heading.contains(i) ? 0 : 1);
    final done = _progress.steps.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (done > 0)
          Row(
            children: [
              Expanded(
                child: Text(
                  l.cookStepsDoneShow(done),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TextButton(
                onPressed: _reset,
                child: Text(l.cookStartOver),
              ),
            ],
          ),
        if (current != null)
          Card(
            color: context.bep.currentStep,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.cookStepN(numberAt(current)),
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: context.bep.onCurrentStep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[current].text,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 19 * _fontScale,
                      height: 1.4,
                      color: context.bep.onCurrentStep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in findTimers(steps[current].text))
                        ActionChip(
                          avatar: const Icon(Icons.timer_outlined, size: 18),
                          label: Text(t.label),
                          tooltip: l.timerButtonTooltip(t.label),
                          onPressed: () => _startTimer(
                            t,
                            l.cookStepN(numberAt(current)),
                            d.name,
                          ),
                        ),
                      ActionChip(
                        avatar: Icon(
                          _speaking ? Icons.stop : Icons.volume_up_outlined,
                          size: 18,
                        ),
                        label: Text(
                          _speaking ? l.cookReadStopShort : l.speakStep,
                        ),
                        onPressed: () => _read(steps[current].text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _saveProgress(
                            _progress.toggleStep(current),
                          ),
                          child: Text(l.done),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l.cookAllStepsDone),
          ),
        const SizedBox(height: 8),
        for (final (i, step) in steps.indexed)
          if (!step.isHeading)
            _StepTile(
              number: numberAt(i),
              text: step.text,
              struck: _progress.steps.contains(i),
              current: i == current,
              fontScale: _fontScale,
              onTap: () => _saveProgress(_progress.toggleStep(i)),
              onLongPress: () => _editStep(step, i),
              timers: [
                for (final t in findTimers(step.text))
                  (t, l.cookStepN(numberAt(i))),
              ],
              onTimer: (t) => _startTimer(
                t,
                l.cookStepN(numberAt(i)),
                d.name,
              ),
              onRead: () => _read(step.text),
              onEdit: () => _editStep(step, i),
            ),
        if (running.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l.timersRunning, style: Theme.of(context).textTheme.titleSmall),
          for (final t in running)
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(t.name),
                subtitle: Text(
                  formatRemaining(t.remaining(now)),
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                trailing: IconButton(
                  tooltip: l.timerCancel,
                  onPressed: () => ref.read(timersProvider.notifier).cancel(t.id),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            l.cookTapHint,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editStep(RecipeLine step, int index) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: step.text);
    final text = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.scanEditLine),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 6,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.scanLineText,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, controller.text.trim()),
            child: Text(l.done),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;
    final repo = ref.read(recipeRepositoryProvider);
    final recipe = ref.read(recipeProvider(_id)).value;
    if (recipe == null) return;
    final draft = recipe.draft;
    final steps = [...draft.steps];
    steps[index] = RecipeLine(text, isHeading: step.isHeading);
    await repo.save(
      RecipeDraftView.replacingSteps(draft, steps),
      id: _id,
    );
  }
}

/// Bản nháp chỉ đổi các bước, giữ nguyên mọi thứ khác.
extension RecipeDraftView on RecipeDraft {
  static RecipeDraft replacingSteps(RecipeDraft d, List<RecipeLine> steps) =>
      RecipeDraft(
        name: d.name,
        servings: d.servings,
        servingsUnit: d.servingsUnit,
        prepMinutes: d.prepMinutes,
        cookMinutes: d.cookMinutes,
        totalMinutes: d.totalMinutes,
        source: d.source,
        sourceUrl: d.sourceUrl,
        notes: d.notes,
        nutrition: d.nutrition,
        difficulty: d.difficulty,
        rating: d.rating,
        favorite: d.favorite,
        ingredients: d.ingredients,
        steps: steps,
        photos: d.photos,
        categoryIds: d.categoryIds,
        tags: d.tags,
      );
}

class _PinsBar extends ConsumerWidget {
  const _PinsBar({required this.pins, required this.current});

  final List<int> pins;
  final int current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final id in pins)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: id == current,
                label: Text(
                  ref.watch(_recipeNameProvider(id)).value ?? '…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onSelected: (_) {
                  if (id != current) context.pushReplacement('/cook/$id');
                },
                onDeleted: id == current
                    ? null
                    : () => ref.read(cookStoreProvider).unpin(id),
                deleteButtonTooltipMessage: l.cookUnpin,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.text,
    required this.struck,
    required this.current,
    required this.fontScale,
    required this.onTap,
    required this.onLongPress,
    required this.timers,
    required this.onTimer,
    required this.onRead,
    required this.onEdit,
  });

  final int number;
  final String text;
  final bool struck;
  final bool current;
  final double fontScale;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final List<(StepTimer, String)> timers;
  final void Function(StepTimer) onTimer;
  final VoidCallback onRead;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bep = context.bep;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: current ? bep.currentStep : Colors.transparent,
        borderRadius: BepRadius.circular(BepRadius.sm),
        child: InkWell(
          borderRadius: BepRadius.circular(BepRadius.sm),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '$number',
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: current ? bep.onCurrentStep : theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontSize: 15.5 * fontScale,
                          height: 1.45,
                          decoration: struck ? TextDecoration.lineThrough : null,
                          color: struck
                              ? theme.colorScheme.onSurfaceVariant
                              : current
                              ? bep.onCurrentStep
                              : null,
                        ),
                      ),
                      if (!struck && (timers.isNotEmpty || current))
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final (t, _) in timers)
                                ActionChip(
                                  visualDensity: VisualDensity.compact,
                                  avatar: const Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                  ),
                                  label: Text(t.label),
                                  tooltip: l.timerButtonTooltip(t.label),
                                  onPressed: () => onTimer(t),
                                ),
                              ActionChip(
                                visualDensity: VisualDensity.compact,
                                avatar: const Icon(
                                  Icons.volume_up_outlined,
                                  size: 16,
                                ),
                                label: Text(l.speakStep),
                                onPressed: onRead,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.scanEditLine,
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
