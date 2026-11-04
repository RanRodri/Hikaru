/// Listening Garden discovery quiz — 10 questions.
///
/// Q1 is multi-select; the rest are single choice. Answers are stored for
/// personalization; Q10 (familiarity with facial sculpting rituals) is
/// informative only and does not score crystals.
class QuizOption {
  const QuizOption({required this.id, required this.label});

  final String id;
  final String label;
}

class DiscoveryQuestion {
  const DiscoveryQuestion({
    required this.number,
    required this.prompt,
    required this.options,
    this.multiSelect = false,
  });

  final int number;
  final String prompt;
  final List<QuizOption> options;

  /// When true the user may pick several options; otherwise exactly one.
  final bool multiSelect;
}

abstract final class QuizOptionIds {
  static const q1ReducePuffiness = 'q1_reduce_puffiness';
  static const q1DefineContours = 'q1_define_contours';
  static const q1SmoothFineLines = 'q1_smooth_fine_lines';
  static const q1RestoreGlow = 'q1_restore_glow';
  static const q1DeeplyHydrate = 'q1_deeply_hydrate';

  static const q2ComfortableBalanced = 'q2_comfortable_balanced';
  static const q2Tight = 'q2_tight';
  static const q2Dry = 'q2_dry';
  static const q2Oily = 'q2_oily';
  static const q2Sensitive = 'q2_sensitive';

  static const q3Morning = 'q3_morning';
  static const q3AfterTravel = 'q3_after_travel';
  static const q3LongWorkdays = 'q3_long_workdays';
  static const q3HormonalChanges = 'q3_hormonal_changes';
  static const q3RestlessNight = 'q3_restless_night';

  static const q4Jaw = 'q4_jaw';
  static const q4Cheeks = 'q4_cheeks';
  static const q4BetweenEyebrows = 'q4_between_eyebrows';
  static const q4Forehead = 'q4_forehead';
  static const q4Neck = 'q4_neck';

  static const q5Jawline = 'q5_jawline';
  static const q5Cheekbones = 'q5_cheekbones';
  static const q5Neck = 'q5_neck';
  static const q5EyeArea = 'q5_eye_area';
  static const q5OverallHarmony = 'q5_overall_harmony';

  static const q6CalmBalanced = 'q6_calm_balanced';
  static const q6SlightlySensitive = 'q6_slightly_sensitive';
  static const q6RedIrritated = 'q6_red_irritated';
  static const q6ActiveBreakout = 'q6_active_breakout';
  static const q6RecoveringTreatment = 'q6_recovering_treatment';

  static const q7MoreSculpted = 'q7_more_sculpted';
  static const q7MoreRadiant = 'q7_more_radiant';
  static const q7Refreshed = 'q7_refreshed';
  static const q7DeeplyRelaxed = 'q7_deeply_relaxed';
  static const q7Grounded = 'q7_grounded';

  static const q8Clarity = 'q8_clarity';
  static const q8Harmony = 'q8_harmony';
  static const q8Grounding = 'q8_grounding';
  static const q8Protection = 'q8_protection';
  static const q8Vitality = 'q8_vitality';

  static const q9ClarityRenewal = 'q9_clarity_renewal';
  static const q9BalanceHarmony = 'q9_balance_harmony';
  static const q9GroundingProtection = 'q9_grounding_protection';
  static const q9VitalityConfidence = 'q9_vitality_confidence';

  static const q10FirstRitual = 'q10_first_ritual';
  static const q10ExploredFewTimes = 'q10_explored_few_times';
  static const q10Routine = 'q10_routine';
}

/// Symbolic / non-medical disclaimer shown in the quiz and revelation screens.
const String crystalRecommendationDisclaimer =
    'Your crystal recommendation is symbolic and is not a medical diagnosis '
    'or a scientifically proven treatment for skin conditions.';

const List<DiscoveryQuestion> discoveryQuiz = [
  DiscoveryQuestion(
    number: 1,
    prompt: 'What would you like to see reflected in the mirror today?',
    multiSelect: true,
    options: [
      QuizOption(
        id: QuizOptionIds.q1ReducePuffiness,
        label: 'Reduce puffiness',
      ),
      QuizOption(
        id: QuizOptionIds.q1DefineContours,
        label: 'Define facial contours',
      ),
      QuizOption(
        id: QuizOptionIds.q1SmoothFineLines,
        label: 'Smooth fine lines',
      ),
      QuizOption(
        id: QuizOptionIds.q1RestoreGlow,
        label: 'Restore glow/radiance',
      ),
      QuizOption(id: QuizOptionIds.q1DeeplyHydrate, label: 'Deeply hydrate'),
    ],
  ),
  DiscoveryQuestion(
    number: 2,
    prompt: 'How does your skin feel today?',
    options: [
      QuizOption(
        id: QuizOptionIds.q2ComfortableBalanced,
        label: 'Comfortable and balanced',
      ),
      QuizOption(id: QuizOptionIds.q2Tight, label: 'Tight'),
      QuizOption(id: QuizOptionIds.q2Dry, label: 'Dry'),
      QuizOption(id: QuizOptionIds.q2Oily, label: 'Oily'),
      QuizOption(id: QuizOptionIds.q2Sensitive, label: 'Sensitive'),
    ],
  ),
  DiscoveryQuestion(
    number: 3,
    prompt: 'Where does your skin need extra care?',
    options: [
      QuizOption(id: QuizOptionIds.q3Morning, label: 'In the morning'),
      QuizOption(id: QuizOptionIds.q3AfterTravel, label: 'After travel'),
      QuizOption(
        id: QuizOptionIds.q3LongWorkdays,
        label: 'After long workdays',
      ),
      QuizOption(
        id: QuizOptionIds.q3HormonalChanges,
        label: 'During hormonal changes',
      ),
      QuizOption(
        id: QuizOptionIds.q3RestlessNight,
        label: 'After a restless night',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 4,
    prompt: 'Where do you notice the most facial tension?',
    options: [
      QuizOption(id: QuizOptionIds.q4Jaw, label: 'Jaw'),
      QuizOption(id: QuizOptionIds.q4Cheeks, label: 'Cheeks'),
      QuizOption(
        id: QuizOptionIds.q4BetweenEyebrows,
        label: 'Between eyebrows',
      ),
      QuizOption(id: QuizOptionIds.q4Forehead, label: 'Forehead'),
      QuizOption(id: QuizOptionIds.q4Neck, label: 'Neck'),
    ],
  ),
  DiscoveryQuestion(
    number: 5,
    prompt: 'Which area would you like to focus?',
    options: [
      QuizOption(id: QuizOptionIds.q5Jawline, label: 'Jawline'),
      QuizOption(id: QuizOptionIds.q5Cheekbones, label: 'Cheekbones'),
      QuizOption(id: QuizOptionIds.q5Neck, label: 'Neck'),
      QuizOption(id: QuizOptionIds.q5EyeArea, label: 'Eye area'),
      QuizOption(
        id: QuizOptionIds.q5OverallHarmony,
        label: 'Overall facial harmony',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 6,
    prompt: 'How is your skin responding today?',
    options: [
      QuizOption(id: QuizOptionIds.q6CalmBalanced, label: 'Calm and balanced'),
      QuizOption(
        id: QuizOptionIds.q6SlightlySensitive,
        label: 'Slightly sensitive',
      ),
      QuizOption(id: QuizOptionIds.q6RedIrritated, label: 'Red or irritated'),
      QuizOption(
        id: QuizOptionIds.q6ActiveBreakout,
        label: 'Experiencing an active breakout',
      ),
      QuizOption(
        id: QuizOptionIds.q6RecoveringTreatment,
        label: 'Recovering from a cosmetic treatment',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 7,
    prompt: "How would you like to feel at the end of today's ritual?",
    options: [
      QuizOption(id: QuizOptionIds.q7MoreSculpted, label: 'More sculpted'),
      QuizOption(id: QuizOptionIds.q7MoreRadiant, label: 'More radiant'),
      QuizOption(id: QuizOptionIds.q7Refreshed, label: 'Refreshed'),
      QuizOption(id: QuizOptionIds.q7DeeplyRelaxed, label: 'Deeply relaxed'),
      QuizOption(id: QuizOptionIds.q7Grounded, label: 'Grounded'),
    ],
  ),
  DiscoveryQuestion(
    number: 8,
    prompt: "What intention would you like to set for today's ritual?",
    options: [
      QuizOption(id: QuizOptionIds.q8Clarity, label: 'Clarity'),
      QuizOption(id: QuizOptionIds.q8Harmony, label: 'Harmony'),
      QuizOption(id: QuizOptionIds.q8Grounding, label: 'Grounding'),
      QuizOption(id: QuizOptionIds.q8Protection, label: 'Protection'),
      QuizOption(id: QuizOptionIds.q8Vitality, label: 'Vitality'),
    ],
  ),
  DiscoveryQuestion(
    number: 9,
    prompt: 'What would you like to cultivate over the next 20 days?',
    options: [
      QuizOption(
        id: QuizOptionIds.q9ClarityRenewal,
        label: 'Clarity and renewal',
      ),
      QuizOption(
        id: QuizOptionIds.q9BalanceHarmony,
        label: 'Balance and harmony',
      ),
      QuizOption(
        id: QuizOptionIds.q9GroundingProtection,
        label: 'Grounding and protection',
      ),
      QuizOption(
        id: QuizOptionIds.q9VitalityConfidence,
        label: 'Vitality and confidence',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 10,
    prompt: 'How familiar are you with facial sculpting rituals?',
    options: [
      QuizOption(
        id: QuizOptionIds.q10FirstRitual,
        label: 'Today is my very first ritual',
      ),
      QuizOption(
        id: QuizOptionIds.q10ExploredFewTimes,
        label: "I've explored it a few times",
      ),
      QuizOption(
        id: QuizOptionIds.q10Routine,
        label: 'It is part of my regular routine',
      ),
    ],
  ),
];
