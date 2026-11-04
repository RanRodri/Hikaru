import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/crystals/domain/crystal_assignment.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';
import 'package:hikaru/features/listening_room/domain/quiz_answers.dart';

QuizAnswers _answers(Map<int, List<String>> selected) => QuizAnswers({
  for (final entry in selected.entries) entry.key: entry.value.toSet(),
});

void main() {
  test('quiz has the 10 briefing questions and 47 options', () {
    expect(discoveryQuiz, hasLength(10));
    expect(
      discoveryQuiz.fold<int>(
        0,
        (count, question) => count + question.options.length,
      ),
      47,
    );
    expect(discoveryQuiz.every((q) => q.options.isNotEmpty), isTrue);
  });

  test('every crystal signal points at a real quiz option', () {
    final ids = discoveryQuiz
        .expand((question) => question.options.map((option) => option.id))
        .toSet();

    expect(quizCrystalSignals.keys, everyElement(isIn(ids)));
  });

  test('emotion bucket alone selects its crystal', () {
    expect(
      assignCrystal(
        _answers({
          7: [QuizOptionIds.q7Refreshed],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Protection],
        }),
      ),
      Crystal.obsidian,
    );
    expect(
      assignCrystal(
        _answers({
          3: [QuizOptionIds.q3LongWorkdays],
        }),
      ),
      Crystal.whiteQuartz,
    );
  });

  test('weights favor emotion over skin', () {
    final answers = _answers({
      7: [QuizOptionIds.q7Grounded], // Obsidian emotion
      1: [QuizOptionIds.q1RestoreGlow], // Quartz skin
    });

    final scores = scoreCrystals(answers);
    final weightSum = emotionWeight + skinWeight;
    expect(scores[Crystal.obsidian], closeTo(emotionWeight / weightSum, 1e-9));
    expect(scores[Crystal.whiteQuartz], closeTo(skinWeight / weightSum, 1e-9));
    expect(scores.containsKey(Crystal.redJasper), isFalse);
    expect(assignCrystal(answers), Crystal.obsidian);
  });

  test('Q9 votes within the emotion bucket', () {
    final answers = _answers({
      9: [QuizOptionIds.q9GroundingProtection], // Obsidian
    });

    expect(assignCrystal(answers), Crystal.obsidian);
  });

  test('empty emotion renormalizes to skin only', () {
    final answers = _answers({
      1: [QuizOptionIds.q1RestoreGlow],
    });

    final scores = scoreCrystals(answers);
    expect(scores[Crystal.whiteQuartz], closeTo(1.0, 1e-9));
    expect(scores.length, 1);
    expect(assignCrystal(answers), Crystal.whiteQuartz);
  });

  test('skin bucket chooses when emotion answers are absent', () {
    expect(
      assignCrystal(
        _answers({
          2: [QuizOptionIds.q2Sensitive],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          5: [QuizOptionIds.q5Jawline],
        }),
      ),
      Crystal.redJasper,
    );
  });

  test('Q10 familiarity answers do not affect crystal scores', () {
    final withFamiliarity = _answers({
      7: [QuizOptionIds.q7MoreRadiant],
      10: [QuizOptionIds.q10Routine],
    });
    final withoutFamiliarity = _answers({
      7: [QuizOptionIds.q7MoreRadiant],
    });

    expect(scoreCrystals(withFamiliarity), scoreCrystals(withoutFamiliarity));
    expect(assignCrystal(withFamiliarity), Crystal.whiteQuartz);
  });

  test('tie-break prefers Jade when scores match', () {
    expect(
      assignCrystal(
        _answers({
          7: [QuizOptionIds.q7Refreshed],
          8: [QuizOptionIds.q8Clarity],
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
      1: {QuizOptionIds.q1DeeplyHydrate},
      8: {QuizOptionIds.q8Harmony},
      10: {QuizOptionIds.q10Routine},
    });

    final restored = QuizAnswers.fromJson(original.toJson());

    expect(restored.selectedIds(1), original.selectedIds(1));
    expect(restored.selectedIds(8), {QuizOptionIds.q8Harmony});
    expect(restored.selectedIds(10), {QuizOptionIds.q10Routine});
  });
}
