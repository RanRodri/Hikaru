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
    this.elapsed = Duration.zero,
  });

  final DateTime date;
  final int completedCycles;
  final bool completed;
  final Duration elapsed;

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'completedCycles': completedCycles,
    'completed': completed,
    'elapsedMs': elapsed.inMilliseconds,
  };

  static MerkabaSessionRecord? fromJson(Object? value) {
    if (value is! Map) return null;
    final date = DateTime.tryParse('${value['date']}');
    final cycles = value['completedCycles'];
    final completed = value['completed'];
    final elapsedMs = value['elapsedMs'];
    if (date == null || cycles is! int || completed is! bool) return null;
    return MerkabaSessionRecord(
      date: date,
      completedCycles: cycles,
      completed: completed,
      elapsed: elapsedMs is int
          ? Duration(milliseconds: elapsedMs)
          : Duration(seconds: cycles * 14),
    );
  }
}

/// Local history of Merkaba sittings.
abstract interface class MerkabaProgressRepository {
  Future<void> recordSession(MerkabaSessionRecord record);

  Future<List<MerkabaSessionRecord>> history();

  /// Unfinished sitting, so the room can open where the user left it.
  Future<void> saveResume(Duration elapsed);

  Future<Duration?> readResume();

  Future<void> clearResume();
}

class InMemoryMerkabaProgressRepository implements MerkabaProgressRepository {
  final List<MerkabaSessionRecord> _history = [];
  Duration? _resume;

  @override
  Future<void> recordSession(MerkabaSessionRecord record) async {
    _history.add(record);
  }

  @override
  Future<List<MerkabaSessionRecord>> history() async =>
      List.unmodifiable(_history);

  @override
  Future<void> saveResume(Duration elapsed) async => _resume = elapsed;

  @override
  Future<Duration?> readResume() async => _resume;

  @override
  Future<void> clearResume() async => _resume = null;
}

class SharedPreferencesMerkabaProgressRepository
    implements MerkabaProgressRepository {
  SharedPreferencesMerkabaProgressRepository(this._preferences);

  static const String storageKey = 'merkaba_session_history';
  static const String resumeKey = 'merkaba_resume_ms';

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

  @override
  Future<void> saveResume(Duration elapsed) async {
    await _preferences.setInt(resumeKey, elapsed.inMilliseconds);
  }

  @override
  Future<Duration?> readResume() async {
    final milliseconds = await _preferences.getInt(resumeKey);
    if (milliseconds == null || milliseconds <= 0) return null;
    return Duration(milliseconds: milliseconds);
  }

  @override
  Future<void> clearResume() async {
    await _preferences.remove(resumeKey);
  }
}

@Riverpod(keepAlive: true)
MerkabaProgressRepository merkabaProgressRepository(Ref ref) =>
    SharedPreferencesMerkabaProgressRepository(SharedPreferencesAsync());
