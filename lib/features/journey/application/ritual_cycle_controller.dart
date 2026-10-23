import 'package:amplify_flutter/amplify_flutter.dart' show UUID;
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
    final local = await repository.read();
    final now = ref.read(ritualClockProvider)();
    final remote = await ref.watch(ritualCycleGatewayProvider).fetchActive(now);
    if (remote == null) return local;
    await repository.save(remote);
    return remote;
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
    await ref.read(ritualCycleRepositoryProvider).save(next);
    await ref.read(ritualCycleGatewayProvider).createCycle(opened);
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
    await ref
        .read(ritualCycleGatewayProvider)
        .updateCycle(closed, currentDay: closed.dayNumber(now));
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

    final gateway = ref.read(ritualCycleGatewayProvider);
    if (opened) await gateway.createCycle(cycle);
    await gateway.saveDay(cycle, date: now, flags: after);
    await gateway.updateCycle(cycle, currentDay: cycle.dayNumber(now));
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
