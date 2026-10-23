import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/user_profile_gateway.dart';

/// Morning ritual and evening reflection reminder switches.
class RitualReminders {
  const RitualReminders({required this.morning, required this.evening});

  static const RitualReminders defaults = RitualReminders(
    morning: true,
    evening: true,
  );

  final bool morning;
  final bool evening;

  RitualReminders copyWith({bool? morning, bool? evening}) => RitualReminders(
    morning: morning ?? this.morning,
    evening: evening ?? this.evening,
  );
}

final ritualRemindersControllerProvider =
    AsyncNotifierProvider<RitualRemindersController, RitualReminders>(
      RitualRemindersController.new,
    );

/// Keeps the reminder switches in `User.morningSacredRitualEnabled` and
/// `User.eveningReflectionAndBreath`, with a local copy for offline use.
class RitualRemindersController extends AsyncNotifier<RitualReminders> {
  static const String morningKey = 'reminder_morning_ritual';
  static const String eveningKey = 'reminder_evening_reflection';

  SharedPreferencesAsync get _preferences => SharedPreferencesAsync();

  @override
  Future<RitualReminders> build() async {
    final remote = await ref.watch(userProfileGatewayProvider).fetchCurrent();
    if (remote != null) {
      final synced = RitualReminders(
        morning: remote.morningRitualReminder,
        evening: remote.eveningReflectionReminder,
      );
      await _cache(synced);
      return synced;
    }
    final morning = await _preferences.getBool(morningKey);
    final evening = await _preferences.getBool(eveningKey);
    return RitualReminders(
      morning: morning ?? RitualReminders.defaults.morning,
      evening: evening ?? RitualReminders.defaults.evening,
    );
  }

  Future<void> setMorning(bool enabled) =>
      _save((current) => current.copyWith(morning: enabled));

  Future<void> setEvening(bool enabled) =>
      _save((current) => current.copyWith(evening: enabled));

  Future<void> _save(RitualReminders Function(RitualReminders) change) async {
    final next = change(await future);
    state = AsyncData(next);
    await _cache(next);
    await ref
        .read(userProfileGatewayProvider)
        .saveReminders(morning: next.morning, evening: next.evening);
  }

  Future<void> _cache(RitualReminders reminders) async {
    await _preferences.setBool(morningKey, reminders.morning);
    await _preferences.setBool(eveningKey, reminders.evening);
  }
}
