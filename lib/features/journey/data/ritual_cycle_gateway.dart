import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/amplify_graphql.dart';
import '../../crystals/domain/crystal_code.dart';
import '../domain/ritual_cycle.dart';

/// Backend `User30DayCycle` and `DailyRitual` rows of the signed-in member.
///
/// Every call is a no-op or returns `null` without a session, so the local
/// cache stays the source the screens read from.
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

class AmplifyRitualCycleGateway implements RitualCycleGateway {
  static const AmplifyGraphQL _api = AmplifyGraphQL('cycle');

  static const String _listCycles =
      r'query ListCycles($userId: ID!, $nextToken: String) { '
      r'listUser30DayCycles('
      r'filter: {userId: {eq: $userId}, isActive: {eq: true}}, '
      r'limit: 100, nextToken: $nextToken'
      ') { items { id startDate crystalCode isActive streak } nextToken } }';

  static const String _listDays =
      r'query ListDays($cycleId: ID!, $dayNumber: Int!, $nextToken: String) { '
      r'listDailyRituals('
      r'filter: {cycleId: {eq: $cycleId}, dayNumber: {eq: $dayNumber}}, '
      r'limit: 100, nextToken: $nextToken'
      ') { items { id isMerkabahDone isMassageDone isFrequencyDone } '
      'nextToken } }';

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
      r'listDailyRituals('
      r'filter: {cycleId: {eq: $cycleId}, isCompleted: {eq: true}}, '
      r'limit: 100, nextToken: $nextToken'
      ') { items { date } nextToken } }';

  static const String _listMerkabaDays =
      r'query ListMerkabaDays($userId: ID!, $nextToken: String) { '
      r'listDailyRituals('
      r'filter: {userId: {eq: $userId}, isMerkabahDone: {eq: true}}, '
      r'limit: 500, nextToken: $nextToken'
      ') { items { date } nextToken } }';

  @override
  Future<CycleProgress?> fetchActive(DateTime today) async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;

    // A failed read is `null`, never "no cycle": answering empty here would
    // let the caller replace a real local cycle with nothing.
    final rows = await _listStrict(_listCycles, 'listUser30DayCycles', {
      'userId': userId,
    });
    if (rows == null) return null;
    final cycles = rows.map(_cycleFromRow).nonNulls.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    if (cycles.isEmpty) return CycleProgress.empty;

    final completed = await _listStrict(
      _listCompletedDays,
      'listDailyRituals',
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
    final days = await _listStrict(_listDays, 'listDailyRituals', {
      'cycleId': cycle.id,
      'dayNumber': dayNumber,
    });
    if (days == null) return null;
    final day = days.isEmpty ? null : days.first;
    return CycleProgress(
      cycle: cycle,
      date: dateOnly(today),
      today: day == null
          ? DailyRitualFlags.none
          : DailyRitualFlags(
              merkaba: day['isMerkabahDone'] == true,
              massage: day['isMassageDone'] == true,
              frequency: day['isFrequencyDone'] == true,
            ),
    );
  }

  /// Distinct days with a finished Merkaba across every cycle, or `null`
  /// without a session or when the read fails.
  Future<int?> merkabaPracticedDays() async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;
    final rows = await _listStrict(_listMerkabaDays, 'listDailyRituals', {
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

  @override
  Future<void> createCycle(RitualCycle cycle) async {
    final userId = await _api.currentUserId();
    if (userId == null) return;
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
    if (await _api.currentUserId() == null) return;
    await _write(_updateCycle, {
      'input': {
        'id': cycle.id,
        'currentDay': currentDay,
        'isActive': cycle.isActive,
        'streak': cycle.streak,
      },
    }, 'updateUser30DayCycle');
  }

  @override
  Future<void> saveDay(
    RitualCycle cycle, {
    required DateTime date,
    required DailyRitualFlags flags,
  }) async {
    final userId = await _api.currentUserId();
    if (userId == null) return;

    final dayNumber = cycle.dayNumber(date);
    final values = {
      'isMerkabahDone': flags.merkaba,
      'isMassageDone': flags.massage,
      'isFrequencyUnlocked': flags.frequencyUnlocked,
      'isFrequencyDone': flags.frequency,
      'isCompleted': flags.completed,
    };
    final rows = await _listStrict(_listDays, 'listDailyRituals', {
      'cycleId': cycle.id,
      'dayNumber': dayNumber,
    });
    // Unknown whether the day exists: creating now could duplicate it.
    if (rows == null) throw const RitualSyncException('listDailyRituals');
    final existing = rows.isEmpty ? null : rows.first;
    if (existing != null) {
      await _write(_updateDay, {
        'input': {'id': existing['id'], ...values},
      }, 'updateDailyRitual');
      return;
    }
    await _write(_createDay, {
      'input': {
        'userId': userId,
        'cycleId': cycle.id,
        'dayNumber': dayNumber,
        'date': isoDate(dateOnly(date)),
        ...values,
      },
    }, 'createDailyRitual');
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
