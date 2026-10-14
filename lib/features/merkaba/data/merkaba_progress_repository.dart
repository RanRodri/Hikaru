import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'merkaba_progress_repository.g.dart';

/// One Merkaba sitting. [completed] is the full five minutes, not a breath.
class MerkabaSessionRecord {
  const MerkabaSessionRecord({
    required this.date,
    required this.completedCycles,
    required this.completed,
  });

  final DateTime date;
  final int completedCycles;
  final bool completed;

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'completedCycles': completedCycles,
    'completed': completed,
  };

  static MerkabaSessionRecord? fromJson(Object? value) {
    if (value is! Map) return null;
    final date = DateTime.tryParse('${value['date']}');
    final cycles = value['completedCycles'];
    final completed = value['completed'];
    if (date == null || cycles is! int || completed is! bool) return null;
    return MerkabaSessionRecord(
      date: date,
      completedCycles: cycles,
      completed: completed,
    );
  }
}

/// Local history of Merkaba sittings.
abstract interface class MerkabaProgressRepository {
  Future<void> recordSession(MerkabaSessionRecord record);

  Future<List<MerkabaSessionRecord>> history();
}

class InMemoryMerkabaProgressRepository implements MerkabaProgressRepository {
  final List<MerkabaSessionRecord> _history = [];

  @override
  Future<void> recordSession(MerkabaSessionRecord record) async {
    _history.add(record);
  }

  @override
  Future<List<MerkabaSessionRecord>> history() async =>
      List.unmodifiable(_history);
}

class SharedPreferencesMerkabaProgressRepository
    implements MerkabaProgressRepository {
  SharedPreferencesMerkabaProgressRepository(this._preferences);

  static const String storageKey = 'merkaba_session_history';

  final SharedPreferencesAsync _preferences;

  @override
  Future<void> recordSession(MerkabaSessionRecord record) async {
    final next = [...await history(), record];
    await _preferences.setString(
      storageKey,
      jsonEncode([for (final item in next) item.toJson()]),
    );
  }

  @override
  Future<List<MerkabaSessionRecord>> history() async {
    final raw = await _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final records = <MerkabaSessionRecord>[];
      for (final item in decoded) {
        final record = MerkabaSessionRecord.fromJson(item);
        if (record != null) records.add(record);
      }
      return records;
    } catch (_) {
      return const [];
    }
  }
}

@Riverpod(keepAlive: true)
MerkabaProgressRepository merkabaProgressRepository(Ref ref) =>
    SharedPreferencesMerkabaProgressRepository(SharedPreferencesAsync());
