import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/ritual_cycle.dart';

/// Local copy of the active cycle and today's flags.
class RitualCycleRepository {
  RitualCycleRepository(this._preferences);

  static const String storageKey = 'ritual_cycle_progress';

  final SharedPreferencesAsync _preferences;

  Future<CycleProgress> read() async {
    final raw = await _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return CycleProgress.empty;
    try {
      return CycleProgress.fromJson(jsonDecode(raw));
    } on FormatException {
      return CycleProgress.empty;
    }
  }

  Future<void> save(CycleProgress progress) =>
      _preferences.setString(storageKey, jsonEncode(progress.toJson()));

  /// Set while the local copy holds a change the backend has not confirmed.
  static const String pendingKey = 'ritual_cycle_pending_sync';
  static const String manualCompletionUnlockedKey =
      'ritual_manual_completion_unlocked';
  static const String completedDaysCountKey =
      'ritual_experience_completed_days';
  static const String locallyCountedDaysKey = 'ritual_experience_counted_days';

  Future<bool> hasPending() async =>
      await _preferences.getBool(pendingKey) ?? false;

  Future<void> setPending(bool pending) => pending
      ? _preferences.setBool(pendingKey, true)
      : _preferences.remove(pendingKey);

  Future<bool> manualCompletionUnlocked() async =>
      await _preferences.getBool(manualCompletionUnlockedKey) ?? false;

  Future<int> completedDaysCount() async =>
      await _preferences.getInt(completedDaysCountKey) ?? 0;

  /// Keeps the largest backend count and permanently unlocks at four days.
  Future<bool> syncCompletedDaysCount(int count) async {
    final known = await completedDaysCount();
    final next = count > known ? count : known;
    await _preferences.setInt(completedDaysCountKey, next);
    if (next < 4) return false;
    await _preferences.setBool(manualCompletionUnlockedKey, true);
    return true;
  }

  /// Counts a newly completed day once, including while offline.
  Future<bool> recordCompletedDay(String cycleId, DateTime date) async {
    final key = '$cycleId|${isoDate(dateOnly(date))}';
    final counted =
        await _preferences.getStringList(locallyCountedDaysKey) ?? <String>[];
    if (counted.contains(key)) return manualCompletionUnlocked();
    counted.add(key);
    await _preferences.setStringList(locallyCountedDaysKey, counted);
    return syncCompletedDaysCount(await completedDaysCount() + 1);
  }

  Future<void> clear() async {
    await _preferences.remove(storageKey);
    await _preferences.remove(pendingKey);
    await _preferences.remove(manualCompletionUnlockedKey);
    await _preferences.remove(completedDaysCountKey);
    await _preferences.remove(locallyCountedDaysKey);
  }
}

final ritualCycleRepositoryProvider = Provider<RitualCycleRepository>(
  (ref) => RitualCycleRepository(SharedPreferencesAsync()),
);
