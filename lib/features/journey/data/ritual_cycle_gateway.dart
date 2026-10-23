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

  @override
  Future<CycleProgress?> fetchActive(DateTime today) async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;

    final rows = await listAllPages(_api, _listCycles, 'listUser30DayCycles', {
      'userId': userId,
    });
    final cycles = rows.map(_cycleFromRow).nonNulls.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    if (cycles.isEmpty) return CycleProgress.empty;

    final cycle = cycles.first;
    final day = await _dayRow(cycle, cycle.dayNumber(today));
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

  @override
  Future<void> createCycle(RitualCycle cycle) async {
    final userId = await _api.currentUserId();
    if (userId == null) return;
    await _api.mutate(_createCycle, {
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
    });
  }

  @override
  Future<void> updateCycle(RitualCycle cycle, {required int currentDay}) async {
    if (await _api.currentUserId() == null) return;
    await _api.mutate(_updateCycle, {
      'input': {
        'id': cycle.id,
        'currentDay': currentDay,
        'isActive': cycle.isActive,
        'streak': cycle.streak,
      },
    });
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
    final existing = await _dayRow(cycle, dayNumber);
    if (existing != null) {
      await _api.mutate(_updateDay, {
        'input': {'id': existing['id'], ...values},
      });
      return;
    }
    await _api.mutate(_createDay, {
      'input': {
        'userId': userId,
        'cycleId': cycle.id,
        'dayNumber': dayNumber,
        'date': isoDate(dateOnly(date)),
        ...values,
      },
    });
  }

  Future<Map<String, dynamic>?> _dayRow(
    RitualCycle cycle,
    int dayNumber,
  ) async {
    final rows = await listAllPages(_api, _listDays, 'listDailyRituals', {
      'cycleId': cycle.id,
      'dayNumber': dayNumber,
    });
    return rows.isEmpty ? null : rows.first;
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
