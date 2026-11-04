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

  Future<bool> hasPending() async =>
      await _preferences.getBool(pendingKey) ?? false;

  Future<void> setPending(bool pending) => pending
      ? _preferences.setBool(pendingKey, true)
      : _preferences.remove(pendingKey);

  Future<void> clear() async {
    await _preferences.remove(storageKey);
    await _preferences.remove(pendingKey);
  }
}

final ritualCycleRepositoryProvider = Provider<RitualCycleRepository>(
  (ref) => RitualCycleRepository(SharedPreferencesAsync()),
);
