import 'package:amplify_flutter/amplify_flutter.dart' show UUID;
import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
import '../data/ritual_cycle_gateway.dart';
import '../data/ritual_cycle_repository.dart';
import '../domain/journey_progress.dart';
import '../domain/ritual_cycle.dart';

/// Current time, overridable in tests.
final ritualClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final ritualCycleControllerProvider =
    AsyncNotifierProvider<RitualCycleController, CycleProgress>(
      RitualCycleController.new,
    );

/// Progress shown by the Home ring and the Journey: day of the open cycle,
/// or day 1 before the first ritual starts one.
final journeyProgressProvider = Provider<JourneyProgress>((ref) {
  final now = ref.watch(ritualClockProvider)();
  final progress = ref.watch(ritualCycleControllerProvider).value;
  return progress?.journeyOn(now) ??
      const JourneyProgress(currentDay: 1, cycleLength: ritualCycleLength);
});

/// The member's 30-day cycle and today's three rituals.
///
/// The first finished ritual opens a cycle with the member's crystal. Each
/// finished ritual marks today's `DailyRitual`; the three together complete
/// the day and extend the streak. Everything is cached locally and mirrored
/// to the backend when a session exists.
class RitualCycleController extends AsyncNotifier<CycleProgress> {
  @override
  Future<CycleProgress> build() async {
    final repository = ref.watch(ritualCycleRepositoryProvider);
    final gateway = ref.watch(ritualCycleGatewayProvider);
    final local = await repository.read();
    final pending = await repository.hasPending();
    final now = ref.read(ritualClockProvider)();

    CycleProgress? remote;
    try {
      remote = await gateway.fetchActive(now);
    } catch (error, stackTrace) {
      _log('Cycle could not be read', error, stackTrace);
    }

    // Offline or the read failed: the device copy stands, and anything it
    // has not delivered yet is sent again.
    if (remote == null) {
      if (pending) unawaited(_push(local, now, mayCreate: true));
      return local;
    }

    final merged = mergeCycleProgress(
      local: local,
      remote: remote,
      pending: pending,
      now: now,
    );
    await repository.save(merged);
    final behind = !_sameProgress(merged, remote, now);
    if (pending || behind) {
      final mayCreate = merged.cycle?.id != remote.cycle?.id;
      // A day finished offline before today is delivered first, so its
      // flags are not lost when the screens move on to today.
      final earlierDay = local.date;
      final sendEarlier =
          pending &&
          earlierDay != null &&
          local.cycle != null &&
          dateOnly(earlierDay) != dateOnly(now);
      unawaited(() async {
        if (sendEarlier) await _push(local, now, mayCreate: mayCreate);
        await _push(merged, now, mayCreate: mayCreate && !sendEarlier);
      }());
    }
    return merged;
  }

  /// Sends [progress] to the backend. Until every write is confirmed the
  /// change stays marked pending and is sent again on the next start.
  Future<bool> _push(
    CycleProgress progress,
    DateTime now, {
    required bool mayCreate,
  }) async {
    final cycle = progress.cycle;
    if (cycle == null) return true;
    final repository = ref.read(ritualCycleRepositoryProvider);
    final gateway = ref.read(ritualCycleGatewayProvider);
    await repository.setPending(true);
    try {
      if (mayCreate) {
        try {
          await gateway.createCycle(cycle);
        } catch (error, stackTrace) {
          // It may already exist from an earlier attempt; the update below
          // tells whether the backend really has it.
          _log('Cycle create was not confirmed', error, stackTrace);
        }
      }
      final day = progress.date;
      if (day != null) {
        await gateway.saveDay(cycle, date: day, flags: progress.today);
      }
      await gateway.updateCycle(cycle, currentDay: cycle.dayNumber(now));
      await repository.setPending(false);
      return true;
    } catch (error, stackTrace) {
      _log('Cycle progress kept on the device for later', error, stackTrace);
      return false;
    }
  }

  static bool _sameProgress(CycleProgress a, CycleProgress b, DateTime now) {
    final x = a.cycle;
    final y = b.cycle;
    if (x == null || y == null) return x == y;
    return x.id == y.id &&
        x.streak == y.streak &&
        x.isActive == y.isActive &&
        a.flagsOn(now) == b.flagsOn(now);
  }

  static void _log(String message, Object error, StackTrace stackTrace) {
    log(message, name: 'hikaru.cycle', error: error, stackTrace: stackTrace);
  }

  Future<void> markMerkaba() => _mark((flags) => flags.copyWith(merkaba: true));

  Future<void> markMassage() => _mark((flags) => flags.copyWith(massage: true));

  Future<void> markFrequency() =>
      _mark((flags) => flags.copyWith(frequency: true));

  CycleProgress? _stagedCycle;

  bool get hasStagedCycle => _stagedCycle != null;

  /// Persists a new cycle without notifying listeners yet.
  ///
  /// The progress photo is stored first. [publishStagedCycle] then refreshes
  /// the screens, so they read the photo and the cycle together.
  Future<RitualCycle> stageOpenCycle() async {
    final now = ref.read(ritualClockProvider)();
    final progress = await future;
    final cycle = progress.cycle;
    if (cycle != null && cycle.isOpenOn(now)) return cycle;

    final opened = RitualCycle(
      id: UUID.getUUID(),
      startDate: dateOnly(now),
      crystal: await _crystalForNewCycle(),
      isActive: true,
      streak: 0,
    );
    final next = CycleProgress(
      cycle: opened,
      date: dateOnly(now),
      today: DailyRitualFlags.none,
    );
    _stagedCycle = next;
    final repository = ref.read(ritualCycleRepositoryProvider);
    await repository.save(next);
    await repository.setPending(true);
    try {
      await ref.read(ritualCycleGatewayProvider).createCycle(opened);
      await repository.setPending(false);
    } catch (error, stackTrace) {
      _log('New cycle kept on the device for later', error, stackTrace);
    }
    return opened;
  }

  void publishStagedCycle() {
    final next = _stagedCycle;
    if (next == null) return;
    _stagedCycle = null;
    state = AsyncData(next);
  }

  Future<void> endCycle() async {
    final progress = await future;
    final cycle = progress.cycle;
    if (cycle == null || !cycle.isActive) return;
    final closed = cycle.copyWith(isActive: false);
    final next = CycleProgress(
      cycle: closed,
      date: progress.date,
      today: progress.today,
    );
    state = AsyncData(next);
    await ref.read(ritualCycleRepositoryProvider).save(next);
    final now = ref.read(ritualClockProvider)();
    await _push(next, now, mayCreate: false);
  }

  Future<void> _mark(DailyRitualFlags Function(DailyRitualFlags) change) async {
    final now = ref.read(ritualClockProvider)();
    var progress = await future;
    var cycle = progress.cycle;
    var opened = false;

    if (cycle == null || !cycle.isOpenOn(now)) {
      cycle = RitualCycle(
        id: UUID.getUUID(),
        startDate: dateOnly(now),
        crystal: await _crystalForNewCycle(),
        isActive: true,
        streak: 0,
      );
      opened = true;
      progress = CycleProgress(
        cycle: cycle,
        date: dateOnly(now),
        today: DailyRitualFlags.none,
      );
    }

    final before = progress.flagsOn(now);
    final after = change(before);
    if (!opened && after == before) return;

    if (after.completed && !before.completed) {
      cycle = cycle.copyWith(
        streak: cycle.streakAfterCompleting(now),
        lastCompletedDate: dateOnly(now),
      );
    }

    final next = CycleProgress(cycle: cycle, date: dateOnly(now), today: after);
    state = AsyncData(next);
    await ref.read(ritualCycleRepositoryProvider).save(next);
    await _push(next, now, mayCreate: opened);
  }

  Future<Crystal> _crystalForNewCycle() async {
    final selected = await ref.read(selectedCrystalProvider.future);
    if (selected != null) return selected;
    final recommendation = await ref.read(
      journeyRecommendationControllerProvider.future,
    );
    return recommendation?.crystal ?? Crystal.jade;
  }
}

/// Combines the device copy with the backend instead of letting either one
/// overwrite the other.
///
/// - Same cycle: a ritual done on either side stays done today, the longer
///   streak and the latest completed day win, and a cycle ended on either
///   side stays ended.
/// - Only one side has a cycle, or they differ: the backend wins, unless the
///   device holds an undelivered change for a cycle at least as recent.
CycleProgress mergeCycleProgress({
  required CycleProgress local,
  required CycleProgress remote,
  required bool pending,
  required DateTime now,
}) {
  final mine = local.cycle;
  final theirs = remote.cycle;
  if (mine == null) return remote;
  if (theirs == null) return pending ? local : remote;
  if (mine.id != theirs.id) {
    final keepMine = pending && !theirs.startDate.isAfter(mine.startDate);
    return keepMine ? local : remote;
  }

  final a = local.flagsOn(now);
  final b = remote.flagsOn(now);
  final flags = DailyRitualFlags(
    merkaba: a.merkaba || b.merkaba,
    massage: a.massage || b.massage,
    frequency: a.frequency || b.frequency,
  );

  DateTime? latest(DateTime? x, DateTime? y) {
    if (x == null) return y;
    if (y == null) return x;
    return x.isAfter(y) ? x : y;
  }

  final cycle = theirs.copyWith(
    isActive: mine.isActive && theirs.isActive,
    streak: mine.streak > theirs.streak ? mine.streak : theirs.streak,
    lastCompletedDate: latest(mine.lastCompletedDate, theirs.lastCompletedDate),
  );
  return CycleProgress(cycle: cycle, date: dateOnly(now), today: flags);
}
