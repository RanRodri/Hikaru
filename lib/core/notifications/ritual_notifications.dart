import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Daily reminders scheduled on the phone itself. They show up like push
/// notifications (banner, sound, lock screen) but need no server.
final ritualNotificationsProvider = Provider<RitualNotifications>(
  (ref) => RitualNotifications(),
);

class RitualNotifications {
  RitualNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int morningId = 1;
  static const int eveningId = 2;

  static const String _channelId = 'hikaru_ritual_reminders';
  static const String _channelName = 'Ritual reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<bool>? _ready;

  /// Only Android and iOS schedule reminders. Elsewhere (tests, web,
  /// desktop) every call is a no-op.
  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> _init() => _ready ??= _initialize();

  Future<bool> _initialize() async {
    if (!_supported) return false;
    try {
      tz_data.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error) {
      // Unknown zone name: fall back to UTC so scheduling still works.
      debugPrint('RitualNotifications: timezone fallback ($error)');
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permission is asked when the member turns a reminder on, not at
          // launch.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      return true;
    } catch (error) {
      debugPrint('RitualNotifications: init failed ($error)');
      return false;
    }
  }

  /// Asks the OS for permission to show notifications. Returns whether they
  /// are allowed. The OS only shows its dialog the first time.
  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return granted ?? true;
    } catch (error) {
      debugPrint('RitualNotifications: permission failed ($error)');
      return false;
    }
  }

  /// Repeats every day at [time] (local time), replacing any reminder with
  /// the same [id].
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (!await _init()) return;
    try {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: _nextInstanceOf(time),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentSound: true,
          ),
        ),
        // Inexact keeps us clear of the exact-alarm permission; Android may
        // shift it by a few minutes.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      debugPrint('RitualNotifications: schedule $id failed ($error)');
    }
  }

  Future<void> cancel(int id) async {
    if (!await _init()) return;
    try {
      await _plugin.cancel(id: id);
    } catch (error) {
      debugPrint('RitualNotifications: cancel $id failed ($error)');
    }
  }

  Future<void> cancelAll() async {
    if (!await _init()) return;
    try {
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('RitualNotifications: cancelAll failed ($error)');
    }
  }

  static tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }
}
