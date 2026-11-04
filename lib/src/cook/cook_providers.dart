import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cooking/unit_conversion.dart';
import '../providers.dart';
import 'cook_store.dart';
import 'platform_services.dart';
import 'recipe_view.dart';
import 'timer_engine.dart';

final cookStoreProvider = Provider<CookStore>(
  (ref) => CookStore(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

/// Test ghi đè bằng bản giả.
final screenAwakeProvider = Provider<ScreenAwake>(
  (ref) => WakelockScreenAwake(),
);

final timerNotificationsProvider = Provider<TimerNotifications>(
  (ref) => LocalTimerNotifications(),
);

final speechProvider = Provider<SpeechService>((ref) => SystemSpeechService());

/// Id các công thức đã ghim, theo thứ tự ghim (AC-29).
final cookPinsProvider = StreamProvider<List<int>>(
  (ref) => ref.watch(cookStoreProvider).watchPins(),
);

/// Cách đang xem mỗi công thức; mất khi rời màn xem (chỉ để xem).
class RecipeViewNotifier extends Notifier<RecipeView> {
  RecipeViewNotifier(this.id);

  final int id;

  @override
  RecipeView build() => RecipeView.original;

  void setFactor(double f) => state = state.withFactor(f);

  void setUnits(UnitSystem? u) => state = state.withUnits(u);

  void reset() => state = RecipeView.original;
}

final recipeViewProvider = NotifierProvider.autoDispose
    .family<RecipeViewNotifier, RecipeView, int>(RecipeViewNotifier.new);

/// Trạng thái các hẹn giờ cho giao diện.
class TimersState {
  const TimersState({
    this.running = const [],
    this.lastFinished = const [],
    this.notificationsOn = false,
  });

  final List<CookTimer> running;

  /// Các hẹn giờ vừa hết ở lần đếm gần nhất (mỗi lần có hẹn giờ hết là một
  /// danh sách mới).
  final List<CookTimer> lastFinished;

  /// Hệ điều hành cho phép thông báo; sai thì cảnh báo "không báo khi ở nền".
  final bool notificationsOn;
}

/// Nhiều hẹn giờ cùng lúc (AC-28). Đếm bằng [TimerEngine] với đồng hồ của app;
/// thông báo hết giờ do hệ điều hành đưa ra theo lịch đã đặt lúc bắt đầu.
class TimersNotifier extends Notifier<TimersState> {
  final _engine = TimerEngine();
  Timer? _ticker;

  @override
  TimersState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const TimersState();
  }

  DateTime get _now => ref.read(clockProvider)();

  /// Hỏi lại hệ điều hành xem thông báo có đang bật không.
  Future<bool> refreshPermission() async {
    final on = await ref.read(timerNotificationsProvider).isEnabled();
    state = TimersState(
      running: state.running,
      lastFinished: state.lastFinished,
      notificationsOn: on,
    );
    return on;
  }

  Future<CookTimer> start({
    required String name,
    required int recipeId,
    required String recipeName,
    required int seconds,
    required String notificationTitle,
    required String notificationBody,
    required String channelName,
    required String channelDescription,
  }) async {
    final t = _engine.start(
      name: name,
      recipeId: recipeId,
      recipeName: recipeName,
      seconds: seconds,
      now: _now,
    );
    _publish();
    _ensureTicker();
    if (state.notificationsOn) {
      await ref
          .read(timerNotificationsProvider)
          .schedule(
            id: t.id,
            title: notificationTitle,
            body: notificationBody,
            at: t.endsAt,
            channelName: channelName,
            channelDescription: channelDescription,
          );
    }
    return t;
  }

  Future<void> cancel(int id) async {
    if (_engine.cancel(id)) {
      _publish();
      await ref.read(timerNotificationsProvider).cancel(id);
    }
    if (_engine.isEmpty) _stopTicker();
  }

  /// Một nhịp đếm; công khai để test gọi trực tiếp.
  void tick() {
    final done = _engine.tick(_now);
    if (done.isNotEmpty) {
      state = TimersState(
        running: _engine.running,
        lastFinished: done,
        notificationsOn: state.notificationsOn,
      );
      if (!state.notificationsOn) {
        // Không có thông báo hệ thống: đổ chuông trong app (AC-28).
        unawaited(_ring());
      }
    } else {
      _publish();
    }
    if (_engine.isEmpty) _stopTicker();
  }

  Future<void> _ring() async {
    for (var i = 0; i < 3; i++) {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
  }

  void _publish() {
    state = TimersState(
      running: _engine.running,
      lastFinished: state.lastFinished,
      notificationsOn: state.notificationsOn,
    );
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final timersProvider = NotifierProvider<TimersNotifier, TimersState>(
  TimersNotifier.new,
);
