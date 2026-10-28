/// Listening Room discovery quiz — 10 questions, as in Figma.
///
/// Q1 is multi-select ("Select all that resonate with you"). Q2–Q10 are
/// single choice. Answers are stored for personalization. Only the options
/// listed in [quizCrystalSignals] vote for a crystal.
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
  static const q1ReducePuffiness = 'q1_reduce_puffiness';
  static const q1DefineContours = 'q1_define_contours';
  static const q1SmoothLines = 'q1_smooth_lines';
  static const q1RestoreGlow = 'q1_restore_glow';
  static const q1DeeplyHydrate = 'q1_deeply_hydrate';
  static const q1EvenTone = 'q1_even_tone';
  static const q1CalmBlemish = 'q1_calm_blemish';
  static const q1ReduceRedness = 'q1_reduce_redness';

  static const q2Comfortable = 'q2_comfortable';
  static const q2Tight = 'q2_tight';
  static const q2Dry = 'q2_dry';
  static const q2Oily = 'q2_oily';
  static const q2Sensitive = 'q2_sensitive';
  static const q2Changes = 'q2_changes';

  static const q3Morning = 'q3_morning';
  static const q3Travel = 'q3_travel';
  static const q3Workdays = 'q3_workdays';
  static const q3Hormonal = 'q3_hormonal';
  static const q3RestlessNight = 'q3_restless_night';
  static const q3UsuallyBalanced = 'q3_usually_balanced';

  static const q4Jaw = 'q4_jaw';
  static const q4Cheeks = 'q4_cheeks';
  static const q4Brows = 'q4_brows';
  static const q4Forehead = 'q4_forehead';
  static const q4Neck = 'q4_neck';
  static const q4Unsure = 'q4_unsure';

  static const q5Jawline = 'q5_jawline';
  static const q5Cheekbones = 'q5_cheekbones';
  static const q5Neck = 'q5_neck';
  static const q5EyeArea = 'q5_eye_area';
  static const q5Harmony = 'q5_harmony';

  static const q6Calm = 'q6_calm';
  static const q6SlightlySensitive = 'q6_slightly_sensitive';
  static const q6RedIrritated = 'q6_red_irritated';
  static const q6Breakout = 'q6_breakout';
  static const q6Recovering = 'q6_recovering';

  static const q7Sculpted = 'q7_sculpted';
  static const q7Radiant = 'q7_radiant';
  static const q7Refreshed = 'q7_refreshed';
  static const q7Relaxed = 'q7_relaxed';
  static const q7Grounded = 'q7_grounded';
  static const q7Connected = 'q7_connected';
  static const q7Restored = 'q7_restored';

  static const q8ClarityRenewal = 'q8_clarity_renewal';
  static const q8BalanceHarmony = 'q8_balance_harmony';
  static const q8GroundingProtection = 'q8_grounding_protection';
  static const q8VitalityConfidence = 'q8_vitality_confidence';

  static const q9ThreeMinutes = 'q9_three_minutes';
  static const q9FiveMinutes = 'q9_five_minutes';
  static const q9TenMinutes = 'q9_ten_minutes';
  static const q9FifteenMinutes = 'q9_fifteen_minutes';

  static const q10FirstRitual = 'q10_first_ritual';
  static const q10Explored = 'q10_explored';
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
    instruction: 'Select all that resonate with you',
    selection: QuizSelection.multiple,
    options: [
      QuizOption(
        id: QuizOptionIds.q1ReducePuffiness,
        label: 'Reduce puffiness',
      ),
      QuizOption(
        id: QuizOptionIds.q1DefineContours,
        label: 'Define facial contours',
      ),
      QuizOption(id: QuizOptionIds.q1SmoothLines, label: 'Smooth fine lines'),
      QuizOption(
        id: QuizOptionIds.q1RestoreGlow,
        label: 'Restore glow/radiance',
      ),
      QuizOption(id: QuizOptionIds.q1DeeplyHydrate, label: 'Deeply hydrate'),
      QuizOption(id: QuizOptionIds.q1EvenTone, label: 'Even skin tone'),
      QuizOption(
        id: QuizOptionIds.q1CalmBlemish,
        label: 'Calm blemish-prone skin',
      ),
      QuizOption(
        id: QuizOptionIds.q1ReduceRedness,
        label: 'Reduce visible redness',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 2,
    prompt: 'How does your skin feel today?',
    instruction: 'Listen to what your skin is telling you',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q2Comfortable,
        label: 'Comfortable and balanced',
      ),
      QuizOption(id: QuizOptionIds.q2Tight, label: 'Tight'),
      QuizOption(id: QuizOptionIds.q2Dry, label: 'Dry'),
      QuizOption(id: QuizOptionIds.q2Oily, label: 'Oily'),
      QuizOption(id: QuizOptionIds.q2Sensitive, label: 'Sensitive'),
      QuizOption(
        id: QuizOptionIds.q2Changes,
        label: 'It changes throughout the day',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 3,
    prompt: 'When does your skin need the most support?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q3Morning, label: 'In the morning'),
      QuizOption(id: QuizOptionIds.q3Travel, label: 'After travel'),
      QuizOption(id: QuizOptionIds.q3Workdays, label: 'After long workdays'),
      QuizOption(
        id: QuizOptionIds.q3Hormonal,
        label: 'During hormonal changes',
      ),
      QuizOption(
        id: QuizOptionIds.q3RestlessNight,
        label: 'After a restless night',
      ),
      QuizOption(
        id: QuizOptionIds.q3UsuallyBalanced,
        label: 'Usually balanced',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 4,
    prompt: 'Where do you notice the most facial tension?',
    instruction: 'Select the area you notice most',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q4Jaw, label: 'Jaw'),
      QuizOption(id: QuizOptionIds.q4Cheeks, label: 'Cheeks'),
      QuizOption(id: QuizOptionIds.q4Brows, label: 'Between eyebrows'),
      QuizOption(id: QuizOptionIds.q4Forehead, label: 'Forehead'),
      QuizOption(id: QuizOptionIds.q4Neck, label: 'Neck'),
      QuizOption(id: QuizOptionIds.q4Unsure, label: "I'm not sure"),
    ],
  ),
  DiscoveryQuestion(
    number: 5,
    prompt: 'Which area would you like to focus on?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q5Jawline, label: 'Jawline'),
      QuizOption(id: QuizOptionIds.q5Cheekbones, label: 'Cheekbones'),
      QuizOption(id: QuizOptionIds.q5Neck, label: 'Neck'),
      QuizOption(id: QuizOptionIds.q5EyeArea, label: 'Eye area'),
      QuizOption(id: QuizOptionIds.q5Harmony, label: 'Overall facial harmony'),
    ],
  ),
  DiscoveryQuestion(
    number: 6,
    prompt: 'How is your skin responding today?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q6Calm, label: 'Calm'),
      QuizOption(
        id: QuizOptionIds.q6SlightlySensitive,
        label: 'Slightly sensitive',
      ),
      QuizOption(id: QuizOptionIds.q6RedIrritated, label: 'Red or irritated'),
      QuizOption(
        id: QuizOptionIds.q6Breakout,
        label: 'Experiencing an active breakout',
      ),
      QuizOption(
        id: QuizOptionIds.q6Recovering,
        label: 'Recovering from a cosmetic treatment',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 7,
    prompt: "What intention would you like to set for today's ritual?",
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q7Sculpted, label: 'More sculpted'),
      QuizOption(id: QuizOptionIds.q7Radiant, label: 'More radiant'),
      QuizOption(id: QuizOptionIds.q7Refreshed, label: 'Refreshed'),
      QuizOption(id: QuizOptionIds.q7Relaxed, label: 'Deeply relaxed'),
      QuizOption(id: QuizOptionIds.q7Grounded, label: 'Grounded'),
      QuizOption(
        id: QuizOptionIds.q7Connected,
        label: 'More connected with myself',
      ),
      QuizOption(id: QuizOptionIds.q7Restored, label: 'Restored'),
    ],
  ),
  DiscoveryQuestion(
    number: 8,
    prompt: 'What would you like to cultivate over the next 20 days?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q8ClarityRenewal,
        label: 'Clarity and renewal',
      ),
      QuizOption(
        id: QuizOptionIds.q8BalanceHarmony,
        label: 'Balance and harmony',
      ),
      QuizOption(
        id: QuizOptionIds.q8GroundingProtection,
        label: 'Grounding and protection',
      ),
      QuizOption(
        id: QuizOptionIds.q8VitalityConfidence,
        label: 'Vitality and confidence',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 9,
    prompt: 'How much time would you like to give yourself today?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q9ThreeMinutes,
        label: '3 minutes',
        detail: 'Reset',
      ),
      QuizOption(
        id: QuizOptionIds.q9FiveMinutes,
        label: '5 minutes',
        detail: 'Daily Ritual',
      ),
      QuizOption(
        id: QuizOptionIds.q9TenMinutes,
        label: '10 minutes',
        detail: 'Lift & Sculpt',
      ),
      QuizOption(
        id: QuizOptionIds.q9FifteenMinutes,
        label: '15 minutes',
        detail: 'Full Sanctuary Journey',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 10,
    prompt: 'How familiar are you with facial sculpting rituals?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q10FirstRitual,
        label: 'Today is my very first ritual',
      ),
      QuizOption(
        id: QuizOptionIds.q10Explored,
        label: "I've explored it a few times",
      ),
      QuizOption(
        id: QuizOptionIds.q10Routine,
        label: 'It is part of my regular routine',
      ),
    ],
  ),
];
