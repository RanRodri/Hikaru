import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/localization/supported_locales.dart';
import '../../../core/notifications/ritual_notifications.dart';
import '../../../l10n/app_localizations.dart';
import '../data/user_profile_gateway.dart';

/// Morning ritual and evening reflection reminders: whether each is on, and
/// the time the member chose for it.
class RitualReminders {
  const RitualReminders({
    required this.morning,
    required this.evening,
    this.morningTime = defaultMorningTime,
    this.eveningTime = defaultEveningTime,
  });

  static const TimeOfDay defaultMorningTime = TimeOfDay(hour: 8, minute: 0);
  static const TimeOfDay defaultEveningTime = TimeOfDay(hour: 21, minute: 30);

  static const RitualReminders defaults = RitualReminders(
    morning: true,
    evening: true,
  );

  final bool morning;
  final bool evening;
  final TimeOfDay morningTime;
  final TimeOfDay eveningTime;

  RitualReminders copyWith({
    bool? morning,
    bool? evening,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
  }) => RitualReminders(
    morning: morning ?? this.morning,
    evening: evening ?? this.evening,
    morningTime: morningTime ?? this.morningTime,
    eveningTime: eveningTime ?? this.eveningTime,
  );
}

final ritualRemindersControllerProvider =
    AsyncNotifierProvider<RitualRemindersController, RitualReminders>(
      RitualRemindersController.new,
    );

/// Keeps the reminder switches in `User.morningSacredRitualEnabled` and
/// `User.eveningReflectionAndBreath`, with a local copy for offline use.
///
/// The backend `User` has no time field, so the chosen times live on this
/// phone only.
class RitualRemindersController extends AsyncNotifier<RitualReminders> {
  static const String morningKey = 'reminder_morning_ritual';
  static const String eveningKey = 'reminder_evening_reflection';
  static const String morningTimeKey = 'reminder_morning_minutes';
  static const String eveningTimeKey = 'reminder_evening_minutes';

  SharedPreferencesAsync get _preferences => SharedPreferencesAsync();

  /// Set once the OS permission dialog was offered, so opening Home does not
  /// ask again; turning a switch on still asks.
  static const String permissionAskedKey = 'reminder_permission_asked';

  @override
  Future<RitualReminders> build() async {
    // Notification texts follow the app language.
    ref.listen(localeControllerProvider, (_, _) {
      final current = state.value;
      if (current != null) _schedule(current);
    });
    final reminders = await _load();
    await _schedule(reminders, askPermissionOnce: true);
    return reminders;
  }

  Future<RitualReminders> _load() async {
    final times = await _readTimes();
    final remote = await ref.watch(userProfileGatewayProvider).fetchCurrent();
    if (remote != null) {
      final synced = RitualReminders(
        morning: remote.morningRitualReminder,
        evening: remote.eveningReflectionReminder,
        morningTime: times.morning,
        eveningTime: times.evening,
      );
      await _cache(synced);
      return synced;
    }
    final morning = await _preferences.getBool(morningKey);
    final evening = await _preferences.getBool(eveningKey);
    return RitualReminders(
      morning: morning ?? RitualReminders.defaults.morning,
      evening: evening ?? RitualReminders.defaults.evening,
      morningTime: times.morning,
      eveningTime: times.evening,
    );
  }

  Future<void> setMorning(bool enabled) => _save(
    (current) => current.copyWith(morning: enabled),
    askPermission: enabled,
  );

  Future<void> setEvening(bool enabled) => _save(
    (current) => current.copyWith(evening: enabled),
    askPermission: enabled,
  );

  Future<void> setMorningTime(TimeOfDay time) =>
      _save((current) => current.copyWith(morningTime: time));

  Future<void> setEveningTime(TimeOfDay time) =>
      _save((current) => current.copyWith(eveningTime: time));

  Future<void> _save(
    RitualReminders Function(RitualReminders) change, {
    bool askPermission = false,
  }) async {
    final next = change(await future);
    state = AsyncData(next);
    await _cache(next);
    if (askPermission) {
      await ref.read(ritualNotificationsProvider).requestPermission();
      await _preferences.setBool(permissionAskedKey, true);
    }
    await _schedule(next);
    await ref
        .read(userProfileGatewayProvider)
        .saveReminders(morning: next.morning, evening: next.evening);
  }

  /// Mirrors the switches and times into the phone's notification schedule.
  Future<void> _schedule(
    RitualReminders reminders, {
    bool askPermissionOnce = false,
  }) async {
    final notifications = ref.read(ritualNotificationsProvider);
    if (askPermissionOnce &&
        (reminders.morning || reminders.evening) &&
        await _preferences.getBool(permissionAskedKey) != true) {
      await notifications.requestPermission();
      await _preferences.setBool(permissionAskedKey, true);
    }
    final l10n = lookupAppLocalizations(
      ref.read(localeControllerProvider).value ?? defaultLocale,
    );
    if (reminders.morning) {
      await notifications.scheduleDaily(
        id: RitualNotifications.morningId,
        time: reminders.morningTime,
        title: l10n.notificationMorningTitle,
        body: l10n.notificationMorningBody,
      );
    } else {
      await notifications.cancel(RitualNotifications.morningId);
    }
    if (reminders.evening) {
      await notifications.scheduleDaily(
        id: RitualNotifications.eveningId,
        time: reminders.eveningTime,
        title: l10n.notificationEveningTitle,
        body: l10n.notificationEveningBody,
      );
    } else {
      await notifications.cancel(RitualNotifications.eveningId);
    }
  }

  Future<({TimeOfDay morning, TimeOfDay evening})> _readTimes() async {
    final morning = await _preferences.getInt(morningTimeKey);
    final evening = await _preferences.getInt(eveningTimeKey);
    return (
      morning: _fromMinutes(morning) ?? RitualReminders.defaultMorningTime,
      evening: _fromMinutes(evening) ?? RitualReminders.defaultEveningTime,
    );
  }

  Future<void> _cache(RitualReminders reminders) async {
    await _preferences.setBool(morningKey, reminders.morning);
    await _preferences.setBool(eveningKey, reminders.evening);
    await _preferences.setInt(
      morningTimeKey,
      _toMinutes(reminders.morningTime),
    );
    await _preferences.setInt(
      eveningTimeKey,
      _toMinutes(reminders.eveningTime),
    );
  }

  static int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static TimeOfDay? _fromMinutes(int? minutes) {
    if (minutes == null || minutes < 0 || minutes >= 24 * 60) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
