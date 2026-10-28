import '../../crystals/domain/crystal.dart';
import 'discovery_quiz.dart';
import 'quiz_answers.dart';

/// Crystal + personalized skin-care protocol revealed after the Listening Garden.
///
/// Symbolic personalization only — not a medical diagnosis or treatment claim.
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

/// Builds the revealed protocol from the assigned crystal and quiz answers.
///
/// Duration comes from Q9. Skin focus follows the Q2 options that kept a
/// protocol (sensitive, tight, or dry). Intention is the crystal default:
/// the previous Q7 phrases no longer have options in the quiz.
JourneyRecommendation buildJourneyRecommendation(
  Crystal crystal,
  QuizAnswers answers,
) {
  final skin = _skinCareFromAnswers(answers);
  return JourneyRecommendation(
    crystal: crystal,
    crystalTitle: crystal.symbolicTitle,
    revelationMessage: crystal.revelationMessage,
    intention: crystal.defaultIntention,
    skinFocus: skin.focus,
    facialRitual: skin.ritual,
    durationMinutes: _durationFromAnswers(answers),
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
      durationMinutes: 5,
    );

int _durationFromAnswers(QuizAnswers answers) {
  final selected = answers.selectedIds(9);
  if (selected.contains(QuizOptionIds.q9ThreeMinutes)) return 3;
  if (selected.contains(QuizOptionIds.q9TenMinutes)) return 10;
  if (selected.contains(QuizOptionIds.q9FifteenMinutes)) return 15;
  return 5;
}

({String focus, String ritual}) _skinCareFromAnswers(QuizAnswers answers) {
  final q2 = answers.selectedIds(2);

  if (q2.contains(QuizOptionIds.q2Sensitive)) {
    return (
      focus: RecommendationCopy.skinFocusSoothing,
      ritual: RecommendationCopy.ritualSoothing,
    );
  }
  if (q2.contains(QuizOptionIds.q2Tight) || q2.contains(QuizOptionIds.q2Dry)) {
    return (
      focus: RecommendationCopy.skinFocusHydration,
      ritual: RecommendationCopy.ritualHydration,
    );
  }
  return (focus: _defaultSkinFocus, ritual: _defaultFacialRitual);
}
