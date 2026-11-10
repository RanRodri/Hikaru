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

final manualStepCompletionUnlockedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(ritualCycleRepositoryProvider);
  if (await repository.manualCompletionUnlocked()) return true;
  final remoteCount = await ref.read(completedRitualDaysReaderProvider)();
  if (remoteCount == null) return false;
  return repository.syncCompletedDaysCount(remoteCount);
});

/// Today's steps in the open cycle, or nothing done before one starts.
final todayRitualProvider = Provider<DailyRitualFlags>((ref) {
  final now = ref.watch(ritualClockProvider)();
  final progress = ref.watch(ritualCycleControllerProvider).value;
  if (progress?.journeyOn(now) == null) return DailyRitualFlags.none;
  return progress!.flagsOn(now);
});

/// The current cycle and what was done each day, as the history calendar
/// shows it.
class CycleHistory {
  const CycleHistory({
    required this.cycle,
    required this.days,
    this.isAuthoritative = false,
  });

  static const CycleHistory empty = CycleHistory(cycle: null, days: {});

  final RitualCycle? cycle;

  /// True only when the backend returned a complete snapshot. Without it,
  /// a missing row cannot honestly be called a missed ritual.
  final bool isAuthoritative;

  /// Recorded days by day number. A day missing here had nothing done.
  final Map<int, DailyRitualFlags> days;

  DailyRitualFlags on(int dayNumber) =>
      days[dayNumber] ?? DailyRitualFlags.none;

  int get completedDays => days.values.where((flags) => flags.completed).length;
}

/// History of the current cycle: the backend days merged with today's copy
/// on this phone, so a ritual just done shows even before it is synced.
/// Offline, only today is known.
final cycleHistoryProvider = FutureProvider<CycleHistory>((ref) async {
  final now = ref.watch(ritualClockProvider)();
  final progress = await ref.watch(ritualCycleControllerProvider.future);
  final cycle = progress.cycle;
  if (cycle == null) return CycleHistory.empty;

  final days = <int, DailyRitualFlags>{};
  var isAuthoritative = false;
  try {
    final remote = await ref.read(ritualCycleGatewayProvider).fetchDays(cycle);
    if (remote != null) isAuthoritative = true;
    for (final day in remote ?? const <RitualDay>[]) {
      days[day.dayNumber] = day.flags;
    }
  } catch (error, stackTrace) {
    log(
      'Cycle history could not be read',
      name: 'hikaru.cycle',
      error: error,
      stackTrace: stackTrace,
    );
  }
  final localDate = progress.date;
  if (localDate != null && !dateOnly(localDate).isAfter(cycle.endDate)) {
    final number = cycle.dayNumber(localDate);
    final known = days[number] ?? DailyRitualFlags.none;
    days[number] = known.union(progress.today);
  }
  // Days after today have nothing to show yet.
  days.removeWhere((number, _) => number > cycle.dayNumber(now));
  return CycleHistory(
    cycle: cycle,
    days: days,
    isAuthoritative: isAuthoritative,
  );
});

/// The cycle whose 30 days are over and is waiting for the member to choose
/// what comes next, or `null`.
final cycleAwaitingClosureProvider = Provider<RitualCycle?>((ref) {
  final now = ref.watch(ritualClockProvider)();
  final progress = ref.watch(ritualCycleControllerProvider).value;
  final cycle = progress?.cycle;
  if (cycle == null) return null;
  final todayDone = progress!.flagsOn(now).completed;
  return cycle.awaitingClosureOn(now, todayCompleted: todayDone) ? cycle : null;
});

/// The member's 30-day cycle and today's four ritual steps.
///
/// The first finished ritual opens a cycle with the member's crystal. Each
/// finished ritual marks today's `DailyRitual`; the four together complete
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

  Future<void> markFacial() => _mark((flags) => flags.copyWith(facial: true));

  Future<void> markBody() => _mark((flags) => flags.copyWith(body: true));

  Future<void> markFrequency() =>
      _mark((flags) => flags.copyWith(frequency: true));

  /// Moves the open cycle to [crystal], keeping its days, streak and dates.
  /// Does nothing without an open cycle: the next one starts with it anyway.
  Future<void> changeCrystal(Crystal crystal) async {
    final progress = await future;
    final cycle = progress.cycle;
    final now = ref.read(ritualClockProvider)();
    if (cycle == null || !cycle.isOpenOn(now) || cycle.crystal == crystal) {
      return;
    }
    final next = CycleProgress(
      cycle: cycle.copyWith(crystal: crystal),
      date: progress.date,
      today: progress.today,
    );
    state = AsyncData(next);
    await ref.read(ritualCycleRepositoryProvider).save(next);
    await _push(next, now, mayCreate: false);
  }

  /// Ends the cycle because the member chose how to continue (repeat the
  /// test or pick a new crystal). The next ritual opens a fresh cycle.
  Future<void> closeCycle({required int completedDays}) async {
    final progress = await future;
    final cycle = progress.cycle;
    if (cycle == null || !cycle.isActive) return;
    final now = ref.read(ritualClockProvider)();
    final closed = cycle.copyWith(
      isActive: false,
      completedAt: now,
      completedDays: completedDays,
    );
    final next = CycleProgress(
      cycle: closed,
      date: progress.date,
      today: progress.today,
    );
    state = AsyncData(next);
    await ref.read(ritualCycleRepositoryProvider).save(next);
    await _push(next, now, mayCreate: false);
  }

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
      // An expired cycle still marked active would stay "active" in the
      // backend forever. Close it before the new one opens.
      final expired = cycle;
      if (expired != null && expired.isActive) {
        final closed = expired.copyWith(isActive: false);
        try {
          await ref
              .read(ritualCycleGatewayProvider)
              .updateCycle(closed, currentDay: ritualCycleLength);
        } catch (error, stackTrace) {
          _log('Expired cycle was not closed', error, stackTrace);
        }
      }
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
    if (after.completed && !before.completed) {
      await ref
          .read(ritualCycleRepositoryProvider)
          .recordCompletedDay(cycle.id, now);
      ref.invalidate(manualStepCompletionUnlockedProvider);
    }
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

  final flags = local.flagsOn(now).union(remote.flagsOn(now));

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
