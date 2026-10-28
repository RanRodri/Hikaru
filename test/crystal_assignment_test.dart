import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/crystals/domain/crystal_assignment.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';
import 'package:hikaru/features/listening_room/domain/quiz_answers.dart';

QuizAnswers _answers(Map<int, List<String>> selected) => QuizAnswers({
  for (final entry in selected.entries) entry.key: entry.value.toSet(),
});

void main() {
  test('quiz has the 10 Figma questions and 54 options', () {
    expect(discoveryQuiz, hasLength(10));
    expect(
      discoveryQuiz.fold<int>(
        0,
        (count, question) => count + question.options.length,
      ),
      54,
    );
    expect(discoveryQuiz.first.selection, QuizSelection.multiple);
    expect(discoveryQuiz.first.exclusiveOptionId, isNull);
    expect(discoveryQuiz.last.selection, QuizSelection.single);
    expect(discoveryQuiz.last.exclusiveOptionId, isNull);
  });

  test('every crystal signal points at a real quiz option', () {
    final ids = discoveryQuiz
        .expand((question) => question.options.map((option) => option.id))
        .toSet();

    expect(quizCrystalSignals.keys, everyElement(isIn(ids)));
  });

  test('Q8 intention selects the crystal named for that option', () {
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8BalanceHarmony],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8GroundingProtection],
        }),
      ),
      Crystal.obsidian,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8ClarityRenewal],
        }),
      ),
      Crystal.whiteQuartz,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8VitalityConfidence],
        }),
      ),
      Crystal.redJasper,
    );
  });

  test('weights favor emotion over skin; Q9 and Q10 do not score', () {
    final answers = _answers({
      8: [QuizOptionIds.q8GroundingProtection],
      2: [QuizOptionIds.q2Sensitive],
      9: [QuizOptionIds.q9TenMinutes],
      10: [QuizOptionIds.q10Routine],
    });

    final scores = scoreCrystals(answers);
    final weightSum = emotionWeight + skinWeight;
    expect(scores[Crystal.obsidian], closeTo(emotionWeight / weightSum, 1e-9));
    expect(scores[Crystal.jade], closeTo(skinWeight / weightSum, 1e-9));
    expect(scores.containsKey(Crystal.whiteQuartz), isFalse);
    expect(assignCrystal(answers), Crystal.obsidian);
  });

  test('empty emotion renormalizes to skin only', () {
    final answers = _answers({
      2: [QuizOptionIds.q2Dry],
      9: [QuizOptionIds.q9ThreeMinutes],
    });

    final scores = scoreCrystals(answers);
    expect(scores[Crystal.jade], closeTo(1.0, 1e-9));
    expect(scores.length, 1);
    expect(assignCrystal(answers), Crystal.jade);
  });

  test('unmapped answers do not vote', () {
    final answers = _answers({
      1: [QuizOptionIds.q1ReducePuffiness, QuizOptionIds.q1DeeplyHydrate],
      6: [QuizOptionIds.q6Calm],
    });

    expect(scoreCrystals(answers), isEmpty);
    expect(assignCrystal(answers), Crystal.jade);
  });

  test('tie-break prefers Jade when emotion votes split evenly', () {
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8BalanceHarmony, QuizOptionIds.q8ClarityRenewal],
        }),
      ),
      Crystal.jade,
    );
  });

  test('empty answers fall back to Jade', () {
    expect(assignCrystal(const QuizAnswers()), Crystal.jade);
    expect(scoreCrystals(const QuizAnswers()), isEmpty);
  });

  test('answers round-trip through json', () {
    const original = QuizAnswers({
      1: {QuizOptionIds.q1ReducePuffiness},
      8: {QuizOptionIds.q8BalanceHarmony},
      10: {QuizOptionIds.q10Routine},
    });

    final restored = QuizAnswers.fromJson(original.toJson());

    expect(restored.selectedIds(1), original.selectedIds(1));
    expect(restored.selectedIds(8), {QuizOptionIds.q8BalanceHarmony});
    expect(restored.selectedIds(10), {QuizOptionIds.q10Routine});
  });
}
