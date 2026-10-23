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
      10 => quizQ10Instruction,
      _ => question.instruction,
    };
  }

  /// Label for an answer option, found by its stable id.
  String quizOptionLabel(QuizOption option) => switch (option.id) {
    QuizOptionIds.q1CalmComfort => quizOptionQ1CalmComfort,
    QuizOptionIds.q1LiftedFirm => quizOptionQ1LiftedFirm,
    QuizOptionIds.q1HydrationSoftness => quizOptionQ1HydrationSoftness,
    QuizOptionIds.q1RadianceVitality => quizOptionQ1RadianceVitality,
    QuizOptionIds.q2Sensitive => quizOptionQ2Sensitive,
    QuizOptionIds.q2TightDry => quizOptionQ2TightDry,
    QuizOptionIds.q2PuffyTired => quizOptionQ2PuffyTired,
    QuizOptionIds.q2ComfortableLackingRadiance =>
      quizOptionQ2ComfortableLackingRadiance,
    QuizOptionIds.q3EmotionallyOverwhelmed =>
      quizOptionQ3EmotionallyOverwhelmed,
    QuizOptionIds.q3MentallyBusy => quizOptionQ3MentallyBusy,
    QuizOptionIds.q3DisconnectedBody => quizOptionQ3DisconnectedBody,
    QuizOptionIds.q3CalmBalanced => quizOptionQ3CalmBalanced,
    QuizOptionIds.q4UncertaintyTension => quizOptionQ4UncertaintyTension,
    QuizOptionIds.q4MentalNoise => quizOptionQ4MentalNoise,
    QuizOptionIds.q4StressPressure => quizOptionQ4StressPressure,
    QuizOptionIds.q4FatigueHeaviness => quizOptionQ4FatigueHeaviness,
    QuizOptionIds.q5ChangesUnknown => quizOptionQ5ChangesUnknown,
    QuizOptionIds.q5LossBrightness => quizOptionQ5LossBrightness,
    QuizOptionIds.q5StressTension => quizOptionQ5StressTension,
    QuizOptionIds.q5FirmnessVitality => quizOptionQ5FirmnessVitality,
    QuizOptionIds.q6SpaceReflect => quizOptionQ6SpaceReflect,
    QuizOptionIds.q6MomentClarity => quizOptionQ6MomentClarity,
    QuizOptionIds.q6GentlenessBalance => quizOptionQ6GentlenessBalance,
    QuizOptionIds.q6GroundingStrength => quizOptionQ6GroundingStrength,
    QuizOptionIds.q7UnderstandBeneath => quizOptionQ7UnderstandBeneath,
    QuizOptionIds.q7GreaterClarity => quizOptionQ7GreaterClarity,
    QuizOptionIds.q7ReturnHarmony => quizOptionQ7ReturnHarmony,
    QuizOptionIds.q7InnerStrength => quizOptionQ7InnerStrength,
    QuizOptionIds.q8SelfAware => quizOptionQ8SelfAware,
    QuizOptionIds.q8ClearRefreshed => quizOptionQ8ClearRefreshed,
    QuizOptionIds.q8CalmNurtured => quizOptionQ8CalmNurtured,
    QuizOptionIds.q8GroundedEnergized => quizOptionQ8GroundedEnergized,
    QuizOptionIds.q9ThreeMinutes => quizOptionQ9ThreeMinutes,
    QuizOptionIds.q9FiveMinutes => quizOptionQ9FiveMinutes,
    QuizOptionIds.q9TenMinutes => quizOptionQ9TenMinutes,
    QuizOptionIds.q10OpenBroken => quizOptionQ10OpenBroken,
    QuizOptionIds.q10ActiveIrritation => quizOptionQ10ActiveIrritation,
    QuizOptionIds.q10UnexplainedChange => quizOptionQ10UnexplainedChange,
    QuizOptionIds.q10None => quizOptionQ10None,
    _ => option.label,
  };
}
