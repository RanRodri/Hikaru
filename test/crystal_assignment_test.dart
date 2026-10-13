import 'package:flutter_test/flutter_test.dart';
import 'package:hiraku/features/crystals/domain/crystal.dart';
import 'package:hiraku/features/crystals/domain/crystal_assignment.dart';
import 'package:hiraku/features/listening_room/domain/discovery_quiz.dart';
import 'package:hiraku/features/listening_room/domain/quiz_answers.dart';

QuizAnswers _answers(Map<int, List<String>> selected) => QuizAnswers({
  for (final entry in selected.entries) entry.key: entry.value.toSet(),
});

void main() {
  test('quiz has the 10 documented questions and 58 options', () {
    expect(discoveryQuiz, hasLength(10));
    expect(
      discoveryQuiz.fold<int>(
        0,
        (count, question) => count + question.options.length,
      ),
      58,
    );
    expect(
      discoveryQuiz.map((question) => question.number).toList(),
      List.generate(10, (index) => index + 1),
    );
    expect(discoveryQuiz.first.selection, QuizSelection.multiple);
    expect(discoveryQuiz[3].selection, QuizSelection.single);
    expect(discoveryQuiz[3].instruction, 'Select the area you notice most');
    expect(
      discoveryQuiz.where(
        (question) => question.selection == QuizSelection.multiple,
      ),
      hasLength(1),
    );
    expect(discoveryQuiz.first.options.map((option) => option.label), [
      'Reduce puffiness',
      'Define facial contours',
      'Smooth fine lines',
      'Restore glow/radiance',
      'Deeply hydrate',
      'Even skin tone',
      'Calm blemish-prone skin',
      'Reduce visible redness',
    ]);
    expect(
      discoveryQuiz[8].options.map((option) => (option.label, option.detail)),
      [
        ('3 minutes', 'Reset'),
        ('5 minutes', 'Daily Ritual'),
        ('10 minutes', 'Lift & Sculpt'),
        ('15 minutes', 'Full Sanctuary Journey'),
      ],
    );
  });

  test('every crystal signal points at a real quiz option', () {
    final ids = discoveryQuiz
        .expand((question) => question.options.map((option) => option.id))
        .toSet();

    expect(quizCrystalSignals.keys, everyElement(isIn(ids)));
  });

  test('a unique intention wins over later answers', () {
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Harmony],
          1: [QuizOptionIds.q1ReducePuffiness],
          7: [QuizOptionIds.q7Sculpted],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Clarity],
        }),
      ),
      Crystal.whiteQuartz,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Expansion],
        }),
      ),
      Crystal.whiteQuartz,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8SelfLove],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Vitality],
        }),
      ),
      Crystal.redJasper,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Grounding],
        }),
      ),
      Crystal.redJasper,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Protection],
        }),
      ),
      Crystal.obsidian,
    );
  });

  test('Renewal stays tied until a later tier picks one crystal', () {
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          6: [QuizOptionIds.q6RedOrIrritated],
          1: [QuizOptionIds.q1ReducePuffiness],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          2: [QuizOptionIds.q2Sensitive],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          1: [QuizOptionIds.q1ReducePuffiness],
          7: [QuizOptionIds.q7Relaxed],
        }),
      ),
      Crystal.obsidian,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          7: [QuizOptionIds.q7Sculpted],
        }),
      ),
      Crystal.obsidian,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          7: [QuizOptionIds.q7LessPuffy],
        }),
      ),
      Crystal.obsidian,
    );
  });

  test('Renewal alone selects Obsidian', () {
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
        }),
      ),
      Crystal.obsidian,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          3: [QuizOptionIds.q3Morning],
          9: [QuizOptionIds.q9Reset],
          10: [QuizOptionIds.q10FirstRitual],
        }),
      ),
      Crystal.obsidian,
    );
  });

  test('Renewal with sensitive, irritated, or stress signals selects Jade', () {
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          6: [QuizOptionIds.q6SlightlySensitive],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          4: [QuizOptionIds.q4Jaw],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          8: [QuizOptionIds.q8Renewal],
          1: [QuizOptionIds.q1ReducePuffiness, QuizOptionIds.q1ReduceRedness],
        }),
      ),
      Crystal.jade,
    );
  });

  test('skin sensitivity outranks physical needs and post-ritual emotion', () {
    expect(
      assignCrystal(
        _answers({
          6: [QuizOptionIds.q6SlightlySensitive],
          1: [QuizOptionIds.q1RestoreGlow],
          7: [QuizOptionIds.q7Grounded],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          4: [QuizOptionIds.q4Jaw],
          7: [QuizOptionIds.q7Radiant],
        }),
      ),
      Crystal.jade,
    );
    expect(
      assignCrystal(
        _answers({
          1: [QuizOptionIds.q1RestoreGlow],
        }),
      ),
      Crystal.whiteQuartz,
    );
    expect(
      assignCrystal(
        _answers({
          7: [QuizOptionIds.q7Restored],
        }),
      ),
      Crystal.redJasper,
    );
    expect(
      assignCrystal(
        _answers({
          7: [QuizOptionIds.q7Connected],
        }),
      ),
      Crystal.whiteQuartz,
    );
  });

  test(
    'several physical signals stay tied until a later tier or the order',
    () {
      expect(
        assignCrystal(
          _answers({
            1: [QuizOptionIds.q1ReducePuffiness, QuizOptionIds.q1ReduceRedness],
            7: [QuizOptionIds.q7Sculpted],
          }),
        ),
        Crystal.obsidian,
      );
      expect(
        assignCrystal(
          _answers({
            1: [QuizOptionIds.q1ReducePuffiness, QuizOptionIds.q1ReduceRedness],
          }),
        ),
        Crystal.jade,
      );
    },
  );

  test('unmapped answers do not choose a crystal on their own', () {
    expect(
      assignCrystal(
        _answers({
          1: [
            QuizOptionIds.q1DefineContours,
            QuizOptionIds.q1SmoothFineLines,
            QuizOptionIds.q1DeeplyHydrate,
            QuizOptionIds.q1EvenSkinTone,
            QuizOptionIds.q1CalmBlemishes,
          ],
          2: [QuizOptionIds.q2Dry],
          4: [QuizOptionIds.q4Forehead],
          5: [QuizOptionIds.q5Jawline],
          6: [QuizOptionIds.q6Breakout],
        }),
      ),
      Crystal.jade,
    );
    expect(assignCrystal(const QuizAnswers()), Crystal.jade);
  });

  test('answers round-trip through json', () {
    const original = QuizAnswers({
      1: {QuizOptionIds.q1ReducePuffiness, QuizOptionIds.q1RestoreGlow},
      8: {QuizOptionIds.q8Harmony},
    });

    final restored = QuizAnswers.fromJson(original.toJson());

    expect(restored.selectedIds(1), original.selectedIds(1));
    expect(restored.selectedIds(8), {QuizOptionIds.q8Harmony});
    expect(QuizAnswers.fromJson({'nope': 'x', '2': []}).selections, isEmpty);
  });
}
