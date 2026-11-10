import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/amplify_graphql.dart';
import '../../crystals/domain/crystal_code.dart';
import '../domain/ritual_cycle.dart';

/// Backend `User30DayCycle` and `DailyRitual` rows of the signed-in member.
///
/// Reads return `null` without a session, so the local cache stays the
/// source the screens read from. Writes throw [RitualSyncException]
/// instead: progress made while the session is gone (e.g. the 30-day
/// refresh token expired) stays pending and is sent after the next sign-in.
abstract class RitualCycleGateway {
  /// The open cycle with today's flags, `null` when none or no session.
  Future<CycleProgress?> fetchActive(DateTime today);

  Future<void> createCycle(RitualCycle cycle);

  Future<void> updateCycle(RitualCycle cycle, {required int currentDay});

  Future<void> saveDay(
    RitualCycle cycle, {
    required DateTime date,
    required DailyRitualFlags flags,
  });

  /// Every recorded day of [cycle], or `null` without a session or when the
  /// read fails. Days with no row are days with nothing done.
  Future<List<RitualDay>?> fetchDays(RitualCycle cycle);
}

final ritualCycleGatewayProvider = Provider<RitualCycleGateway>(
  (ref) => AmplifyRitualCycleGateway(),
);

/// A write the backend did not confirm. The change stays pending locally.
class RitualSyncException implements Exception {
  const RitualSyncException(this.operation);

  final String operation;

  @override
  String toString() => 'RitualSyncException($operation)';
}

/// Distinct days with a finished Merkaba as the backend counts them, or
/// `null` when it cannot answer.
final merkabaPracticedDaysReaderProvider = Provider<Future<int?> Function()>(
  (ref) => AmplifyRitualCycleGateway().merkabaPracticedDays,
);

/// Completed ritual days across every cycle. This rebuilds the permanent
/// manual-completion permission on another phone or after reinstalling.
final completedRitualDaysReaderProvider = Provider<Future<int?> Function()>(
  (ref) => AmplifyRitualCycleGateway().completedRitualDays,
);

class AmplifyRitualCycleGateway implements RitualCycleGateway {
  static const AmplifyGraphQL _api = AmplifyGraphQL('cycle');

  static const String _listCycles =
      r'query ListCycles($userId: ID!, $nextToken: String) { '
      r'cyclesByUser(userId: $userId, '
      r'filter: {isActive: {eq: true}}, '
      r'limit: 100, nextToken: $nextToken'
      ') { items { id startDate crystalCode isActive streak } nextToken } }';

  /// Step fields of a `DailyRitual`. The facial and body ones only exist once
  /// the backend schema with them is deployed.
  static String _stepFields(bool split) => split
      ? 'isMerkabahDone isFacialDone isBodyDone isMassageDone isFrequencyDone'
      : 'isMerkabahDone isMassageDone isFrequencyDone';

  static String _listDays(bool split) =>
      r'query ListDays($cycleId: ID!, $dayNumber: Int!, $nextToken: String) { '
      r'dailyRitualsByCycle(cycleId: $cycleId, '
      r'dayNumber: {eq: $dayNumber}, '
      r'limit: 100, nextToken: $nextToken'
      ') { items { id ${_stepFields(split)} } nextToken } }';

  static String _listCycleDays(bool split) =>
      r'query ListCycleDays($cycleId: ID!, $nextToken: String) { '
      r'dailyRitualsByCycle(cycleId: $cycleId, '
      r'limit: 100, nextToken: $nextToken'
      ') { items { dayNumber date ${_stepFields(split)} } nextToken } }';

  /// Whether the deployed backend knows the facial/body fields and the cycle
  /// closing fields. `null` until a call tells.
  static bool? _schemaUpdated;

  /// Runs [call] with the new fields and, when the backend rejects them,
  /// again with the fields every deployed version has. The answer is
  /// remembered for the session so the old shape is not retried each time.
  static Future<T?> _withSchema<T>(
    Future<T?> Function(bool updated) call,
  ) async {
    if (_schemaUpdated != false) {
      final result = await call(true);
      if (result != null) {
        _schemaUpdated = true;
        return result;
      }
      // The new shape worked before: this is a real failure, not the schema.
      if (_schemaUpdated == true) return null;
    }
    final legacy = await call(false);
    if (legacy != null) _schemaUpdated = false;
    return legacy;
  }

  static const String _createCycle =
      r'mutation CreateCycle($input: CreateUser30DayCycleInput!) { '
      r'createUser30DayCycle(input: $input) { id } }';

  static const String _updateCycle =
      r'mutation UpdateCycle($input: UpdateUser30DayCycleInput!) { '
      r'updateUser30DayCycle(input: $input) { id } }';

  static const String _createDay =
      r'mutation CreateDay($input: CreateDailyRitualInput!) { '
      r'createDailyRitual(input: $input) { id } }';

  static const String _updateDay =
      r'mutation UpdateDay($input: UpdateDailyRitualInput!) { '
      r'updateDailyRitual(input: $input) { id } }';

  static const String _listCompletedDays =
      r'query ListCompleted($cycleId: ID!, $nextToken: String) { '
      r'dailyRitualsByCycle(cycleId: $cycleId, '
      r'filter: {isCompleted: {eq: true}}, '
      r'limit: 100, nextToken: $nextToken'
      ') { items { date } nextToken } }';

  static const String _listMerkabaDays =
      r'query ListMerkabaDays($userId: ID!, $nextToken: String) { '
      r'dailyRitualsByUser(userId: $userId, '
      r'filter: {isMerkabahDone: {eq: true}}, '
      r'limit: 500, nextToken: $nextToken'
      ') { items { date } nextToken } }';

  static const String _listAllCompletedDays =
      r'query ListAllCompletedDays($userId: ID!, $nextToken: String) { '
      r'dailyRitualsByUser(userId: $userId, '
      r'filter: {isCompleted: {eq: true}}, '
      r'limit: 500, nextToken: $nextToken'
      ') { items { cycleId date } nextToken } }';

  @override
  Future<CycleProgress?> fetchActive(DateTime today) async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;

    // A failed read is `null`, never "no cycle": answering empty here would
    // let the caller replace a real local cycle with nothing.
    final rows = await _listStrict(_listCycles, 'cyclesByUser', {
      'userId': userId,
    });
    if (rows == null) return null;
    final cycles = rows.map(_cycleFromRow).nonNulls.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    if (cycles.isEmpty) return CycleProgress.empty;

    final completed = await _listStrict(
      _listCompletedDays,
      'dailyRitualsByCycle',
      {'cycleId': cycles.first.id},
    );
    if (completed == null) return null;
    // The backend has no lastCompletedDate: it is the latest completed day.
    // Without it every completion restarted the streak at 1.
    final completedDates = completed
        .map((row) => DateTime.tryParse('${row['date']}'))
        .nonNulls
        .map(dateOnly)
        .toList();
    final cycle = completedDates.isEmpty
        ? cycles.first
        : cycles.first.copyWith(
            lastCompletedDate: completedDates.reduce(
              (a, b) => a.isAfter(b) ? a : b,
            ),
          );

    final dayNumber = cycle.dayNumber(today);
    final days = await _withSchema(
      (updated) => _listStrict(_listDays(updated), 'dailyRitualsByCycle', {
        'cycleId': cycle.id,
        'dayNumber': dayNumber,
      }),
    );
    if (days == null) return null;
    final day = days.isEmpty ? null : days.first;
    return CycleProgress(
      cycle: cycle,
      date: dateOnly(today),
      today: day == null
          ? DailyRitualFlags.none
          : DailyRitualFlags.fromRow(day),
    );
  }

  @override
  Future<List<RitualDay>?> fetchDays(RitualCycle cycle) async {
    if (await _api.currentUserId() == null) return null;
    final rows = await _withSchema(
      (updated) => _listStrict(_listCycleDays(updated), 'dailyRitualsByCycle', {
        'cycleId': cycle.id,
      }),
    );
    if (rows == null) return null;
    // A day can have more than one row after an offline race; a step done in
    // any of them counts.
    final byDay = <int, RitualDay>{};
    for (final row in rows) {
      final number = row['dayNumber'];
      final date = DateTime.tryParse('${row['date']}');
      if (number is! int || date == null) continue;
      final flags = DailyRitualFlags.fromRow(row);
      final known = byDay[number];
      byDay[number] = RitualDay(
        dayNumber: number,
        date: dateOnly(date),
        flags: known == null ? flags : known.flags.union(flags),
      );
    }
    return byDay.values.toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  /// Distinct days with a finished Merkaba across every cycle, or `null`
  /// without a session or when the read fails.
  Future<int?> merkabaPracticedDays() async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;
    final rows = await _listStrict(_listMerkabaDays, 'dailyRitualsByUser', {
      'userId': userId,
    });
    if (rows == null) return null;
    return rows
        .map((row) => DateTime.tryParse('${row['date']}'))
        .nonNulls
        .map(dateOnly)
        .toSet()
        .length;
  }

  Future<int?> completedRitualDays() async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;
    final rows = await _listStrict(
      _listAllCompletedDays,
      'dailyRitualsByUser',
      {'userId': userId},
    );
    if (rows == null) return null;
    return rows
        .map((row) {
          final cycleId = row['cycleId'];
          final date = DateTime.tryParse('${row['date']}');
          if (cycleId is! String || date == null) return null;
          return '$cycleId|${isoDate(dateOnly(date))}';
        })
        .nonNulls
        .toSet()
        .length;
  }

  /// Like [listAllPages], but `null` when any page fails.
  Future<List<Map<String, dynamic>>?> _listStrict(
    String document,
    String connectionField,
    Map<String, dynamic> variables,
  ) async {
    final items = <Map<String, dynamic>>[];
    String? nextToken;
    do {
      final data = await _api.query(document, {
        ...variables,
        'nextToken': nextToken,
      });
      final page = data?[connectionField];
      if (page is! Map) return null;
      final pageItems = page['items'];
      if (pageItems is List) {
        items.addAll(pageItems.whereType<Map<String, dynamic>>());
      }
      nextToken = page['nextToken'] as String?;
    } while (nextToken != null);
    return items;
  }

  /// Runs [document] and throws when the backend did not store the change,
  /// so the controller keeps it pending and retries later.
  Future<void> _write(
    String document,
    Map<String, dynamic> variables,
    String field,
  ) async {
    final data = await _api.mutate(document, variables);
    if (data?[field] == null) throw RitualSyncException(field);
  }

  /// [_write] that first sends [updatedInput] and, when the backend does not
  /// know its new fields yet, [legacyInput].
  Future<void> _writeWithSchema(
    String document,
    Map<String, dynamic> updatedInput,
    Map<String, dynamic> legacyInput,
    String field,
  ) async {
    final stored = await _withSchema((updated) async {
      final data = await _api.mutate(document, {
        'input': updated ? updatedInput : legacyInput,
      });
      return data?[field] == null ? null : true;
    });
    if (stored == null) throw RitualSyncException(field);
  }

  @override
  Future<void> createCycle(RitualCycle cycle) async {
    final userId = await _api.currentUserId();
    if (userId == null) throw const RitualSyncException('no-session');
    await _write(_createCycle, {
      'input': {
        'id': cycle.id,
        'userId': userId,
        'crystalCode': cycle.crystal.backendCode,
        'startDate': isoDate(cycle.startDate),
        'endDate': isoDate(cycle.endDate),
        'currentDay': 1,
        'isActive': cycle.isActive,
        'streak': cycle.streak,
      },
    }, 'createUser30DayCycle');
  }

  @override
  Future<void> updateCycle(RitualCycle cycle, {required int currentDay}) async {
    if (await _api.currentUserId() == null) {
      throw const RitualSyncException('no-session');
    }
    final input = {
      'id': cycle.id,
      'currentDay': currentDay,
      'isActive': cycle.isActive,
      'streak': cycle.streak,
      // A crystal changed mid-cycle applies to the cycle too.
      'crystalCode': cycle.crystal.backendCode,
    };
    final completedAt = cycle.completedAt;
    if (completedAt == null) {
      await _write(_updateCycle, {'input': input}, 'updateUser30DayCycle');
      return;
    }
    await _writeWithSchema(
      _updateCycle,
      {
        ...input,
        'completedAt': completedAt.toUtc().toIso8601String(),
        'completedDays': ?cycle.completedDays,
      },
      input,
      'updateUser30DayCycle',
    );
  }

  @override
  Future<void> saveDay(
    RitualCycle cycle, {
    required DateTime date,
    required DailyRitualFlags flags,
  }) async {
    final userId = await _api.currentUserId();
    if (userId == null) throw const RitualSyncException('no-session');

    final dayNumber = cycle.dayNumber(date);
    final legacy = {
      'isMerkabahDone': flags.merkaba,
      'isMassageDone': flags.massage,
      'isFrequencyUnlocked': flags.frequencyUnlocked,
      'isFrequencyDone': flags.frequency,
      'isCompleted': flags.completed,
    };
    final updated = {
      ...legacy,
      'isFacialDone': flags.facial,
      'isBodyDone': flags.body,
    };
    final rows = await _withSchema(
      (schema) => _listStrict(_listDays(schema), 'dailyRitualsByCycle', {
        'cycleId': cycle.id,
        'dayNumber': dayNumber,
      }),
    );
    // Unknown whether the day exists: creating now could duplicate it.
    if (rows == null) throw const RitualSyncException('listDailyRituals');
    final existing = rows.isEmpty ? null : rows.first;
    if (existing != null) {
      final id = {'id': existing['id']};
      await _writeWithSchema(
        _updateDay,
        {...id, ...updated},
        {...id, ...legacy},
        'updateDailyRitual',
      );
      return;
    }
    final keys = {
      'userId': userId,
      'cycleId': cycle.id,
      'dayNumber': dayNumber,
      'date': isoDate(dateOnly(date)),
    };
    await _writeWithSchema(
      _createDay,
      {...keys, ...updated},
      {...keys, ...legacy},
      'createDailyRitual',
    );
  }

  RitualCycle? _cycleFromRow(Map<String, dynamic> row) {
    final id = row['id'];
    final start = DateTime.tryParse('${row['startDate']}');
    final crystal = CrystalCode.fromBackendCode(row['crystalCode'] as String?);
    if (id is! String || start == null || crystal == null) return null;
    final streak = row['streak'];
    return RitualCycle(
      id: id,
      startDate: dateOnly(start),
      crystal: crystal,
      isActive: row['isActive'] == true,
      streak: streak is int ? streak : 0,
    );
  }
}
