import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/journey/domain/ritual_cycle.dart';

RitualCycle _cycle({DateTime? lastCompleted, int streak = 0}) => RitualCycle(
  id: 'c1',
  startDate: DateTime(2026, 10, 1),
  crystal: Crystal.jade,
  isActive: true,
  streak: streak,
  lastCompletedDate: lastCompleted,
);

void main() {
  group('daily steps', () {
    test('the day is complete only with all four steps', () {
      const partial = DailyRitualFlags(merkaba: true, facial: true);
      expect(partial.completed, isFalse);
      expect(partial.massage, isFalse);
      expect(partial.pending, [RitualStep.body, RitualStep.crystal]);

      const full = DailyRitualFlags(
        merkaba: true,
        facial: true,
        body: true,
        frequency: true,
      );
      expect(full.completed, isTrue);
      expect(full.massage, isTrue);
      expect(full.pending, isEmpty);
    });

    test('a copy saved before the split keeps massage as both rituals', () {
      final flags = DailyRitualFlags.fromJson({
        'merkaba': true,
        'massage': true,
        'frequency': false,
      });
      expect(flags.facial, isTrue);
      expect(flags.body, isTrue);
    });

    test('an old backend row maps isMassageDone to both rituals', () {
      final old = DailyRitualFlags.fromRow({
        'isMerkabahDone': true,
        'isMassageDone': true,
        'isFrequencyDone': true,
      });
      expect(old.completed, isTrue);

      final split = DailyRitualFlags.fromRow({
        'isMerkabahDone': true,
        'isFacialDone': true,
        'isBodyDone': false,
        'isMassageDone': false,
        'isFrequencyDone': false,
      });
      expect(split.facial, isTrue);
      expect(split.body, isFalse);
    });
  });

  group('streak', () {
    test('stands while yesterday was complete and breaks after a gap', () {
      final cycle = _cycle(lastCompleted: DateTime(2026, 10, 5), streak: 5);
      expect(cycle.streakOn(DateTime(2026, 10, 5, 20)), 5);
      expect(cycle.streakOn(DateTime(2026, 10, 6, 8)), 5);
      expect(cycle.streakOn(DateTime(2026, 10, 7, 8)), 0);
    });

    test('is zero before any full day', () {
      expect(_cycle().streakOn(DateTime(2026, 10, 3)), 0);
    });
  });

  group('cycle closure', () {
    final cycle = _cycle();

    test('is not due during the 30 days', () {
      expect(
        cycle.awaitingClosureOn(DateTime(2026, 10, 15), todayCompleted: true),
        isFalse,
      );
    });

    test('is due on day 30 once its ritual is done', () {
      final lastDay = DateTime(2026, 10, 30, 21);
      expect(cycle.dayNumber(lastDay), 30);
      expect(cycle.awaitingClosureOn(lastDay, todayCompleted: false), isFalse);
      expect(cycle.awaitingClosureOn(lastDay, todayCompleted: true), isTrue);
    });

    test('is due after the 30 days even with days missed', () {
      expect(
        cycle.awaitingClosureOn(DateTime(2026, 11, 2), todayCompleted: false),
        isTrue,
      );
    });

    test('is not due once the member closed the cycle', () {
      final closed = cycle.copyWith(
        isActive: false,
        completedAt: DateTime(2026, 11, 1),
        completedDays: 22,
      );
      expect(
        closed.awaitingClosureOn(DateTime(2026, 11, 2), todayCompleted: false),
        isFalse,
      );
      final restored = RitualCycle.fromJson(closed.toJson())!;
      expect(restored.completedDays, 22);
      expect(restored.completedAt, isNotNull);
    });
  });
}
