/// Listening Garden discovery quiz — 10 questions.
///
/// Q1–Q9 are single choice. Q10 is a multi-select safety screening question
/// with an exclusive "None of the above" option. Answers are stored for
/// personalization; Q10 is informative only and does not block experiences.
enum QuizSelection { single, multiple }

class QuizOption {
  const QuizOption({required this.id, required this.label, this.detail});

  final String id;
  final String label;
  final String? detail;
}

class DiscoveryQuestion {
  const DiscoveryQuestion({
    required this.number,
    required this.prompt,
    required this.selection,
    required this.options,
    this.instruction,
    this.exclusiveOptionId,
  });

  final int number;
  final String prompt;
  final String? instruction;
  final QuizSelection selection;
  final List<QuizOption> options;

  /// When set on a multiple-choice question, selecting this option clears the
  /// others, and selecting any other option clears this one.
  final String? exclusiveOptionId;
}

abstract final class QuizOptionIds {
  static const q1CalmComfort = 'q1_calm_comfort';
  static const q1LiftedFirm = 'q1_lifted_firm';
  static const q1HydrationSoftness = 'q1_hydration_softness';
  static const q1RadianceVitality = 'q1_radiance_vitality';

  static const q2Sensitive = 'q2_sensitive';
  static const q2TightDry = 'q2_tight_dry';
  static const q2PuffyTired = 'q2_puffy_tired';
  static const q2ComfortableLackingRadiance = 'q2_comfortable_lacking_radiance';

  static const q3EmotionallyOverwhelmed = 'q3_emotionally_overwhelmed';
  static const q3MentallyBusy = 'q3_mentally_busy';
  static const q3DisconnectedBody = 'q3_disconnected_body';
  static const q3CalmBalanced = 'q3_calm_balanced';

  static const q4UncertaintyTension = 'q4_uncertainty_tension';
  static const q4MentalNoise = 'q4_mental_noise';
  static const q4StressPressure = 'q4_stress_pressure';
  static const q4FatigueHeaviness = 'q4_fatigue_heaviness';

  static const q5ChangesUnknown = 'q5_changes_unknown';
  static const q5LossBrightness = 'q5_loss_brightness';
  static const q5StressTension = 'q5_stress_tension';
  static const q5FirmnessVitality = 'q5_firmness_vitality';

  static const q6SpaceReflect = 'q6_space_reflect';
  static const q6MomentClarity = 'q6_moment_clarity';
  static const q6GentlenessBalance = 'q6_gentleness_balance';
  static const q6GroundingStrength = 'q6_grounding_strength';

  static const q7UnderstandBeneath = 'q7_understand_beneath';
  static const q7GreaterClarity = 'q7_greater_clarity';
  static const q7ReturnHarmony = 'q7_return_harmony';
  static const q7InnerStrength = 'q7_inner_strength';

  static const q8SelfAware = 'q8_self_aware';
  static const q8ClearRefreshed = 'q8_clear_refreshed';
  static const q8CalmNurtured = 'q8_calm_nurtured';
  static const q8GroundedEnergized = 'q8_grounded_energized';

  static const q9ThreeMinutes = 'q9_three_minutes';
  static const q9FiveMinutes = 'q9_five_minutes';
  static const q9TenMinutes = 'q9_ten_minutes';

  static const q10OpenBroken = 'q10_open_broken';
  static const q10ActiveIrritation = 'q10_active_irritation';
  static const q10UnexplainedChange = 'q10_unexplained_change';
  static const q10None = 'q10_none';
}

/// Symbolic / non-medical disclaimer shown in the quiz and revelation screens.
const String crystalRecommendationDisclaimer =
    'Your crystal recommendation is symbolic and is not a medical diagnosis '
    'or a scientifically proven treatment for skin conditions.';

const List<DiscoveryQuestion> discoveryQuiz = [
  DiscoveryQuestion(
    number: 1,
    prompt: 'What is your skin asking for today?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q1CalmComfort, label: 'Calm and comfort'),
      QuizOption(
        id: QuizOptionIds.q1LiftedFirm,
        label: 'A more lifted, firm appearance',
      ),
      QuizOption(
        id: QuizOptionIds.q1HydrationSoftness,
        label: 'Hydration and softness',
      ),
      QuizOption(
        id: QuizOptionIds.q1RadianceVitality,
        label: 'Radiance and renewed vitality',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 2,
    prompt: 'How does your skin feel right now?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q2Sensitive,
        label: 'Sensitive or easily irritated',
      ),
      QuizOption(id: QuizOptionIds.q2TightDry, label: 'Tight or dry'),
      QuizOption(id: QuizOptionIds.q2PuffyTired, label: 'Puffy or tired'),
      QuizOption(
        id: QuizOptionIds.q2ComfortableLackingRadiance,
        label: 'Comfortable, but lacking radiance',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 3,
    prompt: 'How has your inner world been feeling lately?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q3EmotionallyOverwhelmed,
        label: 'Emotionally overwhelmed',
      ),
      QuizOption(
        id: QuizOptionIds.q3MentallyBusy,
        label: 'Mentally busy or distracted',
      ),
      QuizOption(
        id: QuizOptionIds.q3DisconnectedBody,
        label: 'Disconnected from my body',
      ),
      QuizOption(id: QuizOptionIds.q3CalmBalanced, label: 'Calm and balanced'),
    ],
  ),
  DiscoveryQuestion(
    number: 4,
    prompt: 'What would you most like to release?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q4UncertaintyTension,
        label: 'Uncertainty or hidden tension',
      ),
      QuizOption(
        id: QuizOptionIds.q4MentalNoise,
        label: 'Mental noise and overthinking',
      ),
      QuizOption(
        id: QuizOptionIds.q4StressPressure,
        label: 'Stress and emotional pressure',
      ),
      QuizOption(
        id: QuizOptionIds.q4FatigueHeaviness,
        label: 'Fatigue and heaviness',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 5,
    prompt: 'When you look in the mirror, what do you notice first?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q5ChangesUnknown,
        label: "Changes I don't fully understand",
      ),
      QuizOption(
        id: QuizOptionIds.q5LossBrightness,
        label: 'A loss of brightness',
      ),
      QuizOption(
        id: QuizOptionIds.q5StressTension,
        label: 'Signs of stress or tension',
      ),
      QuizOption(
        id: QuizOptionIds.q5FirmnessVitality,
        label: 'Changes in firmness or vitality',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 6,
    prompt: 'What does your body need more of today?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q6SpaceReflect, label: 'Space to reflect'),
      QuizOption(
        id: QuizOptionIds.q6MomentClarity,
        label: 'A moment of clarity',
      ),
      QuizOption(
        id: QuizOptionIds.q6GentlenessBalance,
        label: 'Gentleness and balance',
      ),
      QuizOption(
        id: QuizOptionIds.q6GroundingStrength,
        label: 'Grounding and strength',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 7,
    prompt: 'Which intention resonates with you?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q7UnderstandBeneath,
        label: 'Understand what lies beneath the surface',
      ),
      QuizOption(
        id: QuizOptionIds.q7GreaterClarity,
        label: 'See myself with greater clarity',
      ),
      QuizOption(id: QuizOptionIds.q7ReturnHarmony, label: 'Return to harmony'),
      QuizOption(
        id: QuizOptionIds.q7InnerStrength,
        label: 'Reconnect with my inner strength',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 8,
    prompt: 'How would you like to feel after your ritual?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q8SelfAware, label: 'More self-aware'),
      QuizOption(
        id: QuizOptionIds.q8ClearRefreshed,
        label: 'Clear and refreshed',
      ),
      QuizOption(id: QuizOptionIds.q8CalmNurtured, label: 'Calm and nurtured'),
      QuizOption(
        id: QuizOptionIds.q8GroundedEnergized,
        label: 'Grounded and energized',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 9,
    prompt: 'How much time would you like to dedicate to yourself?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q9ThreeMinutes, label: '3 minutes'),
      QuizOption(id: QuizOptionIds.q9FiveMinutes, label: '5 minutes'),
      QuizOption(id: QuizOptionIds.q9TenMinutes, label: '10 minutes'),
    ],
  ),
  DiscoveryQuestion(
    number: 10,
    prompt: 'Is your skin currently experiencing any of these?',
    instruction: 'Select all that apply',
    selection: QuizSelection.multiple,
    exclusiveOptionId: QuizOptionIds.q10None,
    options: [
      QuizOption(id: QuizOptionIds.q10OpenBroken, label: 'Open or broken skin'),
      QuizOption(
        id: QuizOptionIds.q10ActiveIrritation,
        label: 'Active irritation or painful inflammation',
      ),
      QuizOption(
        id: QuizOptionIds.q10UnexplainedChange,
        label: 'A new or unexplained skin change',
      ),
      QuizOption(id: QuizOptionIds.q10None, label: 'None of the above'),
    ],
  ),
];
