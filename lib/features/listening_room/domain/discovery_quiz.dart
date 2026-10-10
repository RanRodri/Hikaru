/// Discovery quiz from the master doc v2.0, section 4, phase 2.
///
/// Option labels are the English glosses printed next to each Spanish option.
/// Prompts are direct translations of the official Spanish questions. The spec
/// does not include official English prompts.
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
  });

  final int number;
  final String prompt;
  final String? instruction;
  final QuizSelection selection;
  final List<QuizOption> options;
}

abstract final class QuizOptionIds {
  static const q1ReducePuffiness = 'q1_reduce_puffiness';
  static const q1DefineContours = 'q1_define_contours';
  static const q1SmoothFineLines = 'q1_smooth_fine_lines';
  static const q1RestoreGlow = 'q1_restore_glow';
  static const q1DeeplyHydrate = 'q1_deeply_hydrate';
  static const q1EvenSkinTone = 'q1_even_skin_tone';
  static const q1CalmBlemishes = 'q1_calm_blemishes';
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
  static const q3PoorSleep = 'q3_poor_sleep';
  static const q3Balanced = 'q3_balanced';

  static const q4Jaw = 'q4_jaw';
  static const q4Cheeks = 'q4_cheeks';
  static const q4BetweenEyebrows = 'q4_between_eyebrows';
  static const q4Forehead = 'q4_forehead';
  static const q4Neck = 'q4_neck';
  static const q4NotSure = 'q4_not_sure';

  static const q5Jawline = 'q5_jawline';
  static const q5Cheekbones = 'q5_cheekbones';
  static const q5Neck = 'q5_neck';
  static const q5EyeArea = 'q5_eye_area';
  static const q5OverallHarmony = 'q5_overall_harmony';

  static const q6Calm = 'q6_calm';
  static const q6SlightlySensitive = 'q6_slightly_sensitive';
  static const q6RedOrIrritated = 'q6_red_or_irritated';
  static const q6Breakout = 'q6_breakout';
  static const q6Recovering = 'q6_recovering';

  static const q7Sculpted = 'q7_sculpted';
  static const q7Radiant = 'q7_radiant';
  static const q7LessPuffy = 'q7_less_puffy';
  static const q7Relaxed = 'q7_relaxed';
  static const q7Grounded = 'q7_grounded';
  static const q7Connected = 'q7_connected';
  static const q7Restored = 'q7_restored';

  static const q8Clarity = 'q8_clarity';
  static const q8Harmony = 'q8_harmony';
  static const q8Grounding = 'q8_grounding';
  static const q8Protection = 'q8_protection';
  static const q8Vitality = 'q8_vitality';
  static const q8Expansion = 'q8_expansion';
  static const q8SelfLove = 'q8_self_love';
  static const q8Renewal = 'q8_renewal';

  static const q9Reset = 'q9_reset';
  static const q9DailyRitual = 'q9_daily_ritual';
  static const q9LiftSculpt = 'q9_lift_sculpt';
  static const q9FullJourney = 'q9_full_journey';

  static const q10FirstRitual = 'q10_first_ritual';
  static const q10Explored = 'q10_explored';
  static const q10Regular = 'q10_regular';
}

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
      QuizOption(
        id: QuizOptionIds.q1SmoothFineLines,
        label: 'Smooth fine lines',
      ),
      QuizOption(
        id: QuizOptionIds.q1RestoreGlow,
        label: 'Restore glow/radiance',
      ),
      QuizOption(id: QuizOptionIds.q1DeeplyHydrate, label: 'Deeply hydrate'),
      QuizOption(id: QuizOptionIds.q1EvenSkinTone, label: 'Even skin tone'),
      QuizOption(
        id: QuizOptionIds.q1CalmBlemishes,
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
      QuizOption(id: QuizOptionIds.q3PoorSleep, label: 'After poor sleep'),
      QuizOption(id: QuizOptionIds.q3Balanced, label: 'Usually balanced'),
    ],
  ),
  DiscoveryQuestion(
    number: 4,
    prompt: 'Where do you hold the most facial tension?',
    instruction: 'Select the area you notice most',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q4Jaw, label: 'Jaw'),
      QuizOption(id: QuizOptionIds.q4Cheeks, label: 'Cheeks'),
      QuizOption(
        id: QuizOptionIds.q4BetweenEyebrows,
        label: 'Between eyebrows',
      ),
      QuizOption(id: QuizOptionIds.q4Forehead, label: 'Forehead'),
      QuizOption(id: QuizOptionIds.q4Neck, label: 'Neck'),
      QuizOption(id: QuizOptionIds.q4NotSure, label: "I'm not sure"),
    ],
  ),
  DiscoveryQuestion(
    number: 5,
    prompt: 'Which area would you like to enhance most?',
    selection: QuizSelection.single,
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
    prompt: 'How is your skin reacting today?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q6Calm, label: 'Calm'),
      QuizOption(
        id: QuizOptionIds.q6SlightlySensitive,
        label: 'Slightly sensitive',
      ),
      QuizOption(id: QuizOptionIds.q6RedOrIrritated, label: 'Red or irritated'),
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
    prompt: 'How would you like to feel at the end of today\'s ritual?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q7Sculpted, label: 'More sculpted'),
      QuizOption(id: QuizOptionIds.q7Radiant, label: 'More radiant'),
      QuizOption(id: QuizOptionIds.q7LessPuffy, label: 'Less puffy'),
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
    prompt: 'What intention would you like to cultivate today?',
    selection: QuizSelection.single,
    options: [
      QuizOption(id: QuizOptionIds.q8Clarity, label: 'Clarity'),
      QuizOption(id: QuizOptionIds.q8Harmony, label: 'Harmony'),
      QuizOption(id: QuizOptionIds.q8Grounding, label: 'Grounding'),
      QuizOption(id: QuizOptionIds.q8Protection, label: 'Protection'),
      QuizOption(id: QuizOptionIds.q8Vitality, label: 'Vitality'),
      QuizOption(id: QuizOptionIds.q8Expansion, label: 'Expansion'),
      QuizOption(id: QuizOptionIds.q8SelfLove, label: 'Self-Love'),
      QuizOption(id: QuizOptionIds.q8Renewal, label: 'Renewal'),
    ],
  ),
  DiscoveryQuestion(
    number: 9,
    prompt: 'How much time would you like to give yourself today?',
    selection: QuizSelection.single,
    options: [
      QuizOption(
        id: QuizOptionIds.q9Reset,
        label: '3 minutes',
        detail: 'Reset',
      ),
      QuizOption(
        id: QuizOptionIds.q9DailyRitual,
        label: '5 minutes',
        detail: 'Daily Ritual',
      ),
      QuizOption(
        id: QuizOptionIds.q9LiftSculpt,
        label: '10 minutes',
        detail: 'Lift & Sculpt',
      ),
      QuizOption(
        id: QuizOptionIds.q9FullJourney,
        label: '15 minutes',
        detail: 'Full Sanctuary Journey',
      ),
    ],
  ),
  DiscoveryQuestion(
    number: 10,
    prompt: 'Tell us about your experience with Gua Sha',
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
        id: QuizOptionIds.q10Regular,
        label: "It's part of my regular practice",
      ),
    ],
  ),
];
