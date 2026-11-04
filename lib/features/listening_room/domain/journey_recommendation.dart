import '../../crystals/domain/crystal.dart';
import 'discovery_quiz.dart';
import 'quiz_answers.dart';

/// Crystal + personalized skin-care protocol revealed after the Listening Garden.
///
/// Symbolic personalization only â€” not a medical diagnosis or treatment claim.
class JourneyRecommendation {
  const JourneyRecommendation({
    required this.crystal,
    required this.crystalTitle,
    required this.revelationMessage,
    required this.intention,
    required this.skinFocus,
    required this.facialRitual,
    required this.durationMinutes,
  });

  final Crystal crystal;
  final String crystalTitle;
  final String revelationMessage;
  final String intention;
  final String skinFocus;
  final String facialRitual;
  final int durationMinutes;

  String get durationLabel => '$durationMinutes minutes';

  Map<String, dynamic> toJson() => {
    'crystal': crystal.name,
    'crystalTitle': crystalTitle,
    'revelationMessage': revelationMessage,
    'intention': intention,
    'skinFocus': skinFocus,
    'facialRitual': facialRitual,
    'durationMinutes': durationMinutes,
  };

  factory JourneyRecommendation.fromJson(Map<String, dynamic> json) {
    final crystal =
        Crystal.fromName(json['crystal'] as String?) ?? Crystal.jade;
    final duration = json['durationMinutes'];
    return JourneyRecommendation(
      crystal: crystal,
      crystalTitle: json['crystalTitle'] as String? ?? crystal.symbolicTitle,
      revelationMessage:
          json['revelationMessage'] as String? ?? crystal.revelationMessage,
      intention: json['intention'] as String? ?? crystal.defaultIntention,
      skinFocus: json['skinFocus'] as String? ?? _defaultSkinFocus,
      facialRitual: json['facialRitual'] as String? ?? _defaultFacialRitual,
      durationMinutes: duration is int ? duration : 5,
    );
  }
}

/// English text persisted inside a [JourneyRecommendation].
///
/// Kept as constants so the presentation layer can recognize each value and
/// show it in the active language. Changing a value here would stop it from
/// matching recommendations that were already saved.
abstract final class RecommendationCopy {
  static const intentionSelfAwareness = 'Self-awareness and reflection';
  static const intentionMentalClarity = 'Mental clarity and radiance';
  static const intentionCalmComfort = 'Calm, comfort, and mindful skin care';
  static const intentionVitality = 'Vitality and reconnection with the body';
  static const intentionInnerIllumination = 'Clarity and inner illumination';
  static const intentionHarmony = 'Harmony and gentle balance';
  static const intentionGrounding = 'Grounding and inner strength';

  static const skinFocusSoothing = 'Soothing comfort and calming facial care';
  static const skinFocusHydration = 'Hydration and gentle facial care';
  static const skinFocusLift = 'Lift, firmness, and depuffing support';
  static const skinFocusRadiance = 'Radiance and renewed vitality';

  static const ritualSoothing = 'Soothing Comfort Protocol';
  static const ritualHydration = 'Hydration Protocol';
  static const ritualLift = 'Lift & Sculpt Protocol';
  static const ritualRadiance = 'Radiance Protocol';
}

extension CrystalRevelationCopy on Crystal {
  String get symbolicTitle => switch (this) {
    Crystal.obsidian => 'The Mirror of the Unseen',
    Crystal.whiteQuartz => 'The Light of Clarity',
    Crystal.jade => 'The Garden of Harmony',
    Crystal.redJasper => 'The Earth of Vitality',
  };

  String get defaultIntention => switch (this) {
    Crystal.obsidian => RecommendationCopy.intentionSelfAwareness,
    Crystal.whiteQuartz => RecommendationCopy.intentionMentalClarity,
    Crystal.jade => RecommendationCopy.intentionCalmComfort,
    Crystal.redJasper => RecommendationCopy.intentionVitality,
  };

  String get revelationMessage => switch (this) {
    Crystal.obsidian =>
      'Your answers suggest this may be a moment for deeper reflection. '
          'Obsidian invites you to look beyond the surface, listen to yourself, '
          'and create space for understanding.',
    Crystal.whiteQuartz =>
      'Your answers point toward clarity and renewal. White Quartz invites you '
          'to clear mental noise, welcome illumination, and restore your natural '
          'radiance.',
    Crystal.jade =>
      'Your answers suggest a need for gentleness and balance. Jade invites you '
          'to soften, return to harmony, and care for your skin with mindful '
          'presence.',
    Crystal.redJasper =>
      'Your answers speak to grounding and renewed strength. Red Jasper invites '
          'you to reconnect with your body, release heaviness, and restore '
          'vitality.',
  };
}

const String _defaultSkinFocus = RecommendationCopy.skinFocusHydration;
const String _defaultFacialRitual = RecommendationCopy.ritualHydration;
const int _defaultDurationMinutes = 5;

/// Builds the revealed protocol from the assigned crystal and quiz answers.
///
/// Skin focus and facial ritual come primarily from Q1 (refined by Q2).
/// Intention prefers Q8 (then Q7) when present, otherwise the crystal default. Duration
/// is a fixed 5-minute ritual (Q9 no longer selects a time).
JourneyRecommendation buildJourneyRecommendation(
  Crystal crystal,
  QuizAnswers answers,
) {
  final skin = _skinCareFromAnswers(answers);
  return JourneyRecommendation(
    crystal: crystal,
    crystalTitle: crystal.symbolicTitle,
    revelationMessage: crystal.revelationMessage,
    intention: _intentionFromAnswers(answers) ?? crystal.defaultIntention,
    skinFocus: skin.focus,
    facialRitual: skin.ritual,
    durationMinutes: _defaultDurationMinutes,
  );
}

JourneyRecommendation fallbackRecommendation(Crystal crystal) =>
    JourneyRecommendation(
      crystal: crystal,
      crystalTitle: crystal.symbolicTitle,
      revelationMessage: crystal.revelationMessage,
      intention: crystal.defaultIntention,
      skinFocus: _defaultSkinFocus,
      facialRitual: _defaultFacialRitual,
      durationMinutes: _defaultDurationMinutes,
    );

/// Intention prefers Q8 (today's intention) and falls back to Q7.
String? _intentionFromAnswers(QuizAnswers answers) {
  final q8 = answers.selectedIds(8);
  if (q8.contains(QuizOptionIds.q8Clarity)) {
    return RecommendationCopy.intentionInnerIllumination;
  }
  if (q8.contains(QuizOptionIds.q8Harmony)) {
    return RecommendationCopy.intentionHarmony;
  }
  if (q8.contains(QuizOptionIds.q8Grounding)) {
    return RecommendationCopy.intentionGrounding;
  }
  if (q8.contains(QuizOptionIds.q8Protection)) {
    return RecommendationCopy.intentionSelfAwareness;
  }
  if (q8.contains(QuizOptionIds.q8Vitality)) {
    return RecommendationCopy.intentionVitality;
  }

  final q7 = answers.selectedIds(7);
  if (q7.contains(QuizOptionIds.q7MoreSculpted)) {
    return RecommendationCopy.intentionVitality;
  }
  if (q7.contains(QuizOptionIds.q7MoreRadiant)) {
    return RecommendationCopy.intentionInnerIllumination;
  }
  if (q7.contains(QuizOptionIds.q7Refreshed)) {
    return RecommendationCopy.intentionHarmony;
  }
  if (q7.contains(QuizOptionIds.q7DeeplyRelaxed)) {
    return RecommendationCopy.intentionCalmComfort;
  }
  if (q7.contains(QuizOptionIds.q7Grounded)) {
    return RecommendationCopy.intentionGrounding;
  }
  return null;
}

/// Protocol priority: reactive skin (Q6/Q2) is soothed first, then
/// hydration, lift, and radiance from the goals in Q1, Q2, and Q5.
({String focus, String ritual}) _skinCareFromAnswers(QuizAnswers answers) {
  final q1 = answers.selectedIds(1);
  final q2 = answers.selectedIds(2);
  final q5 = answers.selectedIds(5);
  final q6 = answers.selectedIds(6);

  if (q2.contains(QuizOptionIds.q2Sensitive) ||
      q6.contains(QuizOptionIds.q6SlightlySensitive) ||
      q6.contains(QuizOptionIds.q6RedIrritated) ||
      q6.contains(QuizOptionIds.q6RecoveringTreatment)) {
    return (
      focus: RecommendationCopy.skinFocusSoothing,
      ritual: RecommendationCopy.ritualSoothing,
    );
  }
  if (q1.contains(QuizOptionIds.q1DeeplyHydrate) ||
      q2.contains(QuizOptionIds.q2Dry) ||
      q2.contains(QuizOptionIds.q2Tight)) {
    return (
      focus: RecommendationCopy.skinFocusHydration,
      ritual: RecommendationCopy.ritualHydration,
    );
  }
  if (q1.contains(QuizOptionIds.q1ReducePuffiness) ||
      q1.contains(QuizOptionIds.q1DefineContours) ||
      q5.contains(QuizOptionIds.q5Jawline) ||
      q5.contains(QuizOptionIds.q5Neck)) {
    return (
      focus: RecommendationCopy.skinFocusLift,
      ritual: RecommendationCopy.ritualLift,
    );
  }
  if (q1.contains(QuizOptionIds.q1SmoothFineLines) ||
      q1.contains(QuizOptionIds.q1RestoreGlow) ||
      q5.contains(QuizOptionIds.q5Cheekbones) ||
      q2.contains(QuizOptionIds.q2ComfortableBalanced)) {
    return (
      focus: RecommendationCopy.skinFocusRadiance,
      ritual: RecommendationCopy.ritualRadiance,
    );
  }
  return (focus: _defaultSkinFocus, ritual: _defaultFacialRitual);
}
