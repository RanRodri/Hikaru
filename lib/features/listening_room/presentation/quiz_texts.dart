import '../../../l10n/app_localizations.dart';
import '../domain/discovery_quiz.dart';

/// Resolves the localized copy of the discovery quiz.
///
/// The domain keeps stable ids and English text as a reference. The screen
/// asks this class for the text in the active language, so answers saved by
/// id keep working when the user changes language.
extension QuizTexts on AppLocalizations {
  /// Prompt for the question with the given [number] (1-based).
  String quizPrompt(DiscoveryQuestion question) => switch (question.number) {
    1 => quizQ1Prompt,
    2 => quizQ2Prompt,
    3 => quizQ3Prompt,
    4 => quizQ4Prompt,
    5 => quizQ5Prompt,
    6 => quizQ6Prompt,
    7 => quizQ7Prompt,
    8 => quizQ8Prompt,
    9 => quizQ9Prompt,
    10 => quizQ10Prompt,
    _ => question.prompt,
  };

  /// Instruction under the prompt, or `null` when the question has none.
  String? quizInstruction(DiscoveryQuestion question) {
    if (question.instruction == null) return null;
    return switch (question.number) {
      1 => quizQ1Instruction,
      2 => quizQ2Instruction,
      4 => quizQ4Instruction,
      _ => question.instruction,
    };
  }

  /// Label for an answer option, found by its stable id.
  String quizOptionLabel(QuizOption option) => switch (option.id) {
    QuizOptionIds.q1ReducePuffiness => quizOptionQ1ReducePuffiness,
    QuizOptionIds.q1DefineContours => quizOptionQ1DefineContours,
    QuizOptionIds.q1SmoothLines => quizOptionQ1SmoothLines,
    QuizOptionIds.q1RestoreGlow => quizOptionQ1RestoreGlow,
    QuizOptionIds.q1DeeplyHydrate => quizOptionQ1DeeplyHydrate,
    QuizOptionIds.q1EvenTone => quizOptionQ1EvenTone,
    QuizOptionIds.q1CalmBlemish => quizOptionQ1CalmBlemish,
    QuizOptionIds.q1ReduceRedness => quizOptionQ1ReduceRedness,
    QuizOptionIds.q2Comfortable => quizOptionQ2Comfortable,
    QuizOptionIds.q2Tight => quizOptionQ2Tight,
    QuizOptionIds.q2Dry => quizOptionQ2Dry,
    QuizOptionIds.q2Oily => quizOptionQ2Oily,
    QuizOptionIds.q2Sensitive => quizOptionQ2Sensitive,
    QuizOptionIds.q2Changes => quizOptionQ2Changes,
    QuizOptionIds.q3Morning => quizOptionQ3Morning,
    QuizOptionIds.q3Travel => quizOptionQ3Travel,
    QuizOptionIds.q3Workdays => quizOptionQ3Workdays,
    QuizOptionIds.q3Hormonal => quizOptionQ3Hormonal,
    QuizOptionIds.q3RestlessNight => quizOptionQ3RestlessNight,
    QuizOptionIds.q3UsuallyBalanced => quizOptionQ3UsuallyBalanced,
    QuizOptionIds.q4Jaw => quizOptionQ4Jaw,
    QuizOptionIds.q4Cheeks => quizOptionQ4Cheeks,
    QuizOptionIds.q4Brows => quizOptionQ4Brows,
    QuizOptionIds.q4Forehead => quizOptionQ4Forehead,
    QuizOptionIds.q4Neck => quizOptionQ4Neck,
    QuizOptionIds.q4Unsure => quizOptionQ4Unsure,
    QuizOptionIds.q5Jawline => quizOptionQ5Jawline,
    QuizOptionIds.q5Cheekbones => quizOptionQ5Cheekbones,
    QuizOptionIds.q5Neck => quizOptionQ5Neck,
    QuizOptionIds.q5EyeArea => quizOptionQ5EyeArea,
    QuizOptionIds.q5Harmony => quizOptionQ5Harmony,
    QuizOptionIds.q6Calm => quizOptionQ6Calm,
    QuizOptionIds.q6SlightlySensitive => quizOptionQ6SlightlySensitive,
    QuizOptionIds.q6RedIrritated => quizOptionQ6RedIrritated,
    QuizOptionIds.q6Breakout => quizOptionQ6Breakout,
    QuizOptionIds.q6Recovering => quizOptionQ6Recovering,
    QuizOptionIds.q7Sculpted => quizOptionQ7Sculpted,
    QuizOptionIds.q7Radiant => quizOptionQ7Radiant,
    QuizOptionIds.q7Refreshed => quizOptionQ7Refreshed,
    QuizOptionIds.q7Relaxed => quizOptionQ7Relaxed,
    QuizOptionIds.q7Grounded => quizOptionQ7Grounded,
    QuizOptionIds.q7Connected => quizOptionQ7Connected,
    QuizOptionIds.q7Restored => quizOptionQ7Restored,
    QuizOptionIds.q8ClarityRenewal => quizOptionQ8ClarityRenewal,
    QuizOptionIds.q8BalanceHarmony => quizOptionQ8BalanceHarmony,
    QuizOptionIds.q8GroundingProtection => quizOptionQ8GroundingProtection,
    QuizOptionIds.q8VitalityConfidence => quizOptionQ8VitalityConfidence,
    QuizOptionIds.q9ThreeMinutes => quizOptionQ9ThreeMinutes,
    QuizOptionIds.q9FiveMinutes => quizOptionQ9FiveMinutes,
    QuizOptionIds.q9TenMinutes => quizOptionQ9TenMinutes,
    QuizOptionIds.q9FifteenMinutes => quizOptionQ9FifteenMinutes,
    QuizOptionIds.q10FirstRitual => quizOptionQ10FirstRitual,
    QuizOptionIds.q10Explored => quizOptionQ10Explored,
    QuizOptionIds.q10Routine => quizOptionQ10Routine,
    _ => option.label,
  };

  /// Secondary line of an option, or `null` when it has none.
  String? quizOptionDetail(QuizOption option) {
    if (option.detail == null) return null;
    return switch (option.id) {
      QuizOptionIds.q9ThreeMinutes => quizOptionQ9ThreeDetail,
      QuizOptionIds.q9FiveMinutes => quizOptionQ9FiveDetail,
      QuizOptionIds.q9TenMinutes => quizOptionQ9TenDetail,
      QuizOptionIds.q9FifteenMinutes => quizOptionQ9FifteenDetail,
      _ => option.detail,
    };
  }
}
