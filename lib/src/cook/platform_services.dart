import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wakelock_plus/wakelock_plus.dart';

/// Giữ màn hình sáng ở chế độ nấu (AC-26). Gói dùng cờ cửa sổ của Android.
abstract class ScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

class WakelockScreenAwake implements ScreenAwake {
  @override
  Future<void> enable() => _safe(() => WakelockPlus.enable());

  @override
  Future<void> disable() => _safe(() => WakelockPlus.disable());

  Future<void> _safe(Future<void> Function() f) async {
    try {
      await f();
    } on Object catch (e) {
      debugPrint('wakelock: $e');
    }
  }
}

/// Thông báo hết giờ (AC-28). Chỉ lập lịch KHÔNG chính xác tuyệt đối: không
/// cần quyền báo giờ chính xác (D-009).
abstract class TimerNotifications {
  /// Đã được phép hiện thông báo chưa (Android 12 trở xuống luôn là true).
  Future<bool> isEnabled();

  /// Xin quyền; trả về kết quả.
  Future<bool> requestPermission();

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String channelName,
    required String channelDescription,
  });

  Future<void> cancel(int id);
}

class LocalTimerNotifications implements TimerNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _init;

  Future<bool> _ready() => _init ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      )
      .then((v) => v ?? false)
      .catchError((Object e) {
        debugPrint('notifications init: $e');
        return false;
      });

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> isEnabled() async {
    try {
      await _ready();
      return await _android?.areNotificationsEnabled() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await _ready();
      return await _android?.requestNotificationsPermission() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String channelName,
    required String channelDescription,
  }) async {
    try {
      if (!await _ready()) return;
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'cook_timer',
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            playSound: true,
            // Gói tự thêm quyền VIBRATE; đã loại khỏi manifest (D-009).
            enableVibration: false,
          ),
        ),
        // Không chính xác tuyệt đối: không cần SCHEDULE_EXACT_ALARM.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Object catch (e) {
      debugPrint('notification schedule: $e');
    }
  }

  @override
  Future<void> cancel(int id) async {
    try {
      await _ready();
      await _plugin.cancel(id: id);
    } on Object catch (e) {
      debugPrint('notification cancel: $e');
    }
  }
}

enum SpeakResult { ok, noVoice, error }

/// Giọng đọc của hệ điều hành (AC-30).
abstract class SpeechService {
  /// [languageTag]: `vi-VN`, `en-US`.
  Future<SpeakResult> speak(String text, String languageTag);

  Future<void> stop();
}

class SystemSpeechService implements SpeechService {
  final _tts = FlutterTts();

  @override
  Future<SpeakResult> speak(String text, String languageTag) async {
    try {
      final available = await _tts.isLanguageAvailable(languageTag);
      if (available != true && available != 1 && available != 2) {
        return SpeakResult.noVoice;
      }
      await _tts.setLanguage(languageTag);
      await _tts.stop();
      final r = await _tts.speak(text);
      return r == 0 ? SpeakResult.error : SpeakResult.ok;
    } on Object catch (e) {
      debugPrint('tts: $e');
      return SpeakResult.error;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } on Object {
      // Không có gì để dừng.
    }
  }
}

/// Đoán ngôn ngữ của bước để chọn giọng đọc: có chữ tiếng Việt có dấu thì
/// `vi-VN`, còn lại `en-US`. Công thức chưa có trường ngôn ngữ riêng.
String detectSpeechLanguage(String text) =>
    _vietnamese.hasMatch(text) ? 'vi-VN' : 'en-US';

final _vietnamese = RegExp(
  '[ăâđêôơưĂÂĐÊÔƠƯàáảãạằắẳẵặầấẩẫậèéẻẽẹềếểễệìíỉĩịòóỏõọồốổỗộờớởỡợùúủũụừứửữựỳýỷỹỵ'
  'ÀÁẢÃẠẰẮẲẴẶẦẤẨẪẬÈÉẺẼẸỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌỒỐỔỖỘỜỚỞỠỢÙÚỦŨỤỪỨỬỮỰỲÝỶỸỴ]',
);
