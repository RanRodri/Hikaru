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

  /// Subtitle under the prompt, or `null` when the question has none.
  String? quizInstruction(DiscoveryQuestion question) =>
      switch (question.number) {
        1 => quizQ1Instruction,
        2 => quizQ2Instruction,
        4 => quizQ4Instruction,
        _ => null,
      };

  /// Label for an answer option, found by its stable id.
  String quizOptionLabel(QuizOption option) => switch (option.id) {
    QuizOptionIds.q1ReducePuffiness => quizOptionQ1ReducePuffiness,
    QuizOptionIds.q1DefineContours => quizOptionQ1DefineContours,
    QuizOptionIds.q1SmoothFineLines => quizOptionQ1SmoothFineLines,
    QuizOptionIds.q1RestoreGlow => quizOptionQ1RestoreGlow,
    QuizOptionIds.q1DeeplyHydrate => quizOptionQ1DeeplyHydrate,
    QuizOptionIds.q2ComfortableBalanced => quizOptionQ2ComfortableBalanced,
    QuizOptionIds.q2Tight => quizOptionQ2Tight,
    QuizOptionIds.q2Dry => quizOptionQ2Dry,
    QuizOptionIds.q2Oily => quizOptionQ2Oily,
    QuizOptionIds.q2Sensitive => quizOptionQ2Sensitive,
    QuizOptionIds.q3Morning => quizOptionQ3Morning,
    QuizOptionIds.q3AfterTravel => quizOptionQ3AfterTravel,
    QuizOptionIds.q3LongWorkdays => quizOptionQ3LongWorkdays,
    QuizOptionIds.q3HormonalChanges => quizOptionQ3HormonalChanges,
    QuizOptionIds.q3RestlessNight => quizOptionQ3RestlessNight,
    QuizOptionIds.q4Jaw => quizOptionQ4Jaw,
    QuizOptionIds.q4Cheeks => quizOptionQ4Cheeks,
    QuizOptionIds.q4BetweenEyebrows => quizOptionQ4BetweenEyebrows,
    QuizOptionIds.q4Forehead => quizOptionQ4Forehead,
    QuizOptionIds.q4Neck => quizOptionQ4Neck,
    QuizOptionIds.q5Jawline => quizOptionQ5Jawline,
    QuizOptionIds.q5Cheekbones => quizOptionQ5Cheekbones,
    QuizOptionIds.q5Neck => quizOptionQ5Neck,
    QuizOptionIds.q5EyeArea => quizOptionQ5EyeArea,
    QuizOptionIds.q5OverallHarmony => quizOptionQ5OverallHarmony,
    QuizOptionIds.q6CalmBalanced => quizOptionQ6CalmBalanced,
    QuizOptionIds.q6SlightlySensitive => quizOptionQ6SlightlySensitive,
    QuizOptionIds.q6RedIrritated => quizOptionQ6RedIrritated,
    QuizOptionIds.q6ActiveBreakout => quizOptionQ6ActiveBreakout,
    QuizOptionIds.q6RecoveringTreatment => quizOptionQ6RecoveringTreatment,
    QuizOptionIds.q7MoreSculpted => quizOptionQ7MoreSculpted,
    QuizOptionIds.q7MoreRadiant => quizOptionQ7MoreRadiant,
    QuizOptionIds.q7Refreshed => quizOptionQ7Refreshed,
    QuizOptionIds.q7DeeplyRelaxed => quizOptionQ7DeeplyRelaxed,
    QuizOptionIds.q7Grounded => quizOptionQ7Grounded,
    QuizOptionIds.q8Clarity => quizOptionQ8Clarity,
    QuizOptionIds.q8Harmony => quizOptionQ8Harmony,
    QuizOptionIds.q8Grounding => quizOptionQ8Grounding,
    QuizOptionIds.q8Protection => quizOptionQ8Protection,
    QuizOptionIds.q8Vitality => quizOptionQ8Vitality,
    QuizOptionIds.q9ClarityRenewal => quizOptionQ9ClarityRenewal,
    QuizOptionIds.q9BalanceHarmony => quizOptionQ9BalanceHarmony,
    QuizOptionIds.q9GroundingProtection => quizOptionQ9GroundingProtection,
    QuizOptionIds.q9VitalityConfidence => quizOptionQ9VitalityConfidence,
    QuizOptionIds.q10FirstRitual => quizOptionQ10FirstRitual,
    QuizOptionIds.q10ExploredFewTimes => quizOptionQ10ExploredFewTimes,
    QuizOptionIds.q10Routine => quizOptionQ10Routine,
    _ => option.label,
  };
}
