import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/crystals/application/selected_crystal_controller.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/journey/application/ritual_cycle_controller.dart';
import 'package:hikaru/features/journey/data/ritual_cycle_gateway.dart';
import 'package:hikaru/features/journey/domain/ritual_cycle.dart';
import 'package:hikaru/features/listening_room/data/questionnaire_gateway.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  ProviderContainer makeContainer(_Clock clock, _RecordingGateway gateway) {
    final container = ProviderContainer(
      overrides: [
        ritualClockProvider.overrideWithValue(clock.now),
        ritualCycleGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'first finished ritual opens a cycle with the selected crystal',
    () async {
      final clock = _Clock(DateTime(2026, 10, 22, 9));
      final gateway = _RecordingGateway();
      final container = makeContainer(clock, gateway);
      await container
          .read(selectedCrystalProvider.notifier)
          .select(Crystal.obsidian);

      final controller = container.read(ritualCycleControllerProvider.notifier);
      await controller.markMerkaba();

      final progress = await container.read(
        ritualCycleControllerProvider.future,
      );
      final cycle = progress.cycle!;
      expect(cycle.crystal, Crystal.obsidian);
      expect(cycle.startDate, DateTime(2026, 10, 22));
      expect(cycle.isActive, isTrue);
      expect(progress.flagsOn(clock.now()).merkaba, isTrue);
      expect(progress.flagsOn(clock.now()).completed, isFalse);
      expect(gateway.created, [cycle.id]);
      expect(gateway.savedDays.single.flags.merkaba, isTrue);
      expect(container.read(journeyProgressProvider).currentDay, 1);
    },
  );

  test(
    'three rituals complete the day and streak follows the calendar',
    () async {
      final clock = _Clock(DateTime(2026, 10, 22, 9));
      final gateway = _RecordingGateway();
      final container = makeContainer(clock, gateway);
      final controller = container.read(ritualCycleControllerProvider.notifier);

      await controller.markMerkaba();
      await controller.markMassage();
      await controller.markFrequency();
      var progress = await container.read(ritualCycleControllerProvider.future);
      expect(progress.flagsOn(clock.now()).completed, isTrue);
      expect(progress.cycle!.streak, 1);

      clock.advance(const Duration(days: 1));
      expect(progress.flagsOn(clock.now()), DailyRitualFlags.none);
      await controller.markMerkaba();
      await controller.markMassage();
      await controller.markFrequency();
      progress = await container.read(ritualCycleControllerProvider.future);
      expect(progress.cycle!.streak, 2);
      expect(container.read(journeyProgressProvider).currentDay, 2);
      expect(container.read(journeyProgressProvider).streak, 2);

      clock.advance(const Duration(days: 2));
      await controller.markMerkaba();
      await controller.markMassage();
      await controller.markFrequency();
      progress = await container.read(ritualCycleControllerProvider.future);
      expect(progress.cycle!.streak, 1);
      expect(container.read(journeyProgressProvider).currentDay, 4);
      expect(gateway.created.length, 1);
    },
  );

  test(
    'ending the cycle stops the day count and a new ritual reopens one',
    () async {
      final clock = _Clock(DateTime(2026, 10, 22, 9));
      final gateway = _RecordingGateway();
      final container = makeContainer(clock, gateway);
      final controller = container.read(ritualCycleControllerProvider.notifier);

      await controller.markMerkaba();
      final first = (await container.read(ritualCycleControllerProvider.future))
          .cycle!;
      await controller.endCycle();
      expect(
        (await container.read(ritualCycleControllerProvider.future))
            .cycle!
            .isActive,
        isFalse,
      );
      expect(container.read(journeyProgressProvider).currentDay, 1);

      clock.advance(const Duration(days: 3));
      await controller.markMassage();
      final second = (await container.read(
        ritualCycleControllerProvider.future,
      )).cycle!;
      expect(second.id, isNot(first.id));
      expect(second.startDate, DateTime(2026, 10, 25));
      expect(gateway.created, [first.id, second.id]);
    },
  );

  test('progress survives a restart through the local cache', () async {
    final clock = _Clock(DateTime(2026, 10, 22, 9));
    final gateway = _RecordingGateway();
    final first = makeContainer(clock, gateway);
    await first.read(ritualCycleControllerProvider.notifier).markMerkaba();
    final id = (await first.read(ritualCycleControllerProvider.future))
        .cycle!
        .id;

    final second = makeContainer(clock, gateway);
    final restored = await second.read(ritualCycleControllerProvider.future);
    expect(restored.cycle!.id, id);
    expect(restored.flagsOn(clock.now()).merkaba, isTrue);
  });

  test('answers rebuild from backend option ids', () {
    final answers = answersFromOptionIds([
      QuizOptionIds.q1ReducePuffiness,
      QuizOptionIds.q1DeeplyHydrate,
      QuizOptionIds.q10Routine,
      'unknown_option',
    ]);
    expect(answers.selectedIds(1), {
      QuizOptionIds.q1ReducePuffiness,
      QuizOptionIds.q1DeeplyHydrate,
    });
    expect(answers.selectedIds(10), {QuizOptionIds.q10Routine});
    expect(answers.selections.length, 2);
  });
}

class _Clock {
  _Clock(this._now);

  DateTime _now;

  DateTime now() => _now;

  void advance(Duration by) => _now = _now.add(by);
}

class _SavedDay {
  const _SavedDay(this.cycleId, this.flags);

  final String cycleId;
  final DailyRitualFlags flags;
}

class _RecordingGateway implements RitualCycleGateway {
  final List<String> created = [];
  final List<_SavedDay> savedDays = [];

  @override
  Future<CycleProgress?> fetchActive(DateTime today) async => null;

  @override
  Future<void> createCycle(RitualCycle cycle) async => created.add(cycle.id);

  @override
  Future<void> updateCycle(
    RitualCycle cycle, {
    required int currentDay,
  }) async {}

  @override
  Future<void> saveDay(
    RitualCycle cycle, {
    required DateTime date,
    required DailyRitualFlags flags,
  }) async => savedDays.add(_SavedDay(cycle.id, flags));
}
