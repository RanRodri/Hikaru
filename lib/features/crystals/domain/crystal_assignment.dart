import '../../listening_room/domain/discovery_quiz.dart';
import '../../listening_room/domain/quiz_answers.dart';
import 'crystal.dart';

/// Proposed personalization weights (not scientific or diagnostic).
///
/// Intention answers (Q7–Q9) carry 60% and skin / face answers (Q1–Q6) 30%.
/// Active buckets are renormalized to sum to 1.0. Q10 (ritual familiarity) is
/// informative only and never votes.
///
/// Crystal themes used for the signals:
/// - Jade: calm, hydration, soothing, harmony.
/// - White Quartz: clarity, radiance, renewal.
/// - Red Jasper: vitality, lift, firmness, grounding.
/// - Obsidian: protection, purifying, looking beneath the surface.
const double emotionWeight = 0.60;
const double skinWeight = 0.30;

const List<int> emotionQuestions = [7, 8, 9];
const List<int> skinQuestions = [1, 2, 3, 4, 5, 6];

const List<Crystal> crystalTieBreakOrder = [
  Crystal.jade,
  Crystal.whiteQuartz,
  Crystal.redJasper,
  Crystal.obsidian,
];

/// Option id → crystal signal for scoring.
const Map<String, Crystal> quizCrystalSignals = {
  // Skin / face (30%)
  // Q1 — what to see in the mirror (multi-select).
  QuizOptionIds.q1ReducePuffiness: Crystal.redJasper,
  QuizOptionIds.q1DefineContours: Crystal.redJasper,
  QuizOptionIds.q1SmoothFineLines: Crystal.whiteQuartz,
  QuizOptionIds.q1RestoreGlow: Crystal.whiteQuartz,
  QuizOptionIds.q1DeeplyHydrate: Crystal.jade,
  // Q2 — how the skin feels.
  QuizOptionIds.q2ComfortableBalanced: Crystal.whiteQuartz,
  QuizOptionIds.q2Tight: Crystal.redJasper,
  QuizOptionIds.q2Dry: Crystal.jade,
  QuizOptionIds.q2Oily: Crystal.obsidian,
  QuizOptionIds.q2Sensitive: Crystal.jade,
  // Q3 — when the skin needs extra care.
  QuizOptionIds.q3Morning: Crystal.redJasper,
  QuizOptionIds.q3AfterTravel: Crystal.obsidian,
  QuizOptionIds.q3LongWorkdays: Crystal.whiteQuartz,
  QuizOptionIds.q3HormonalChanges: Crystal.jade,
  QuizOptionIds.q3RestlessNight: Crystal.redJasper,
  // Q4 — where the facial tension is.
  QuizOptionIds.q4Jaw: Crystal.obsidian,
  QuizOptionIds.q4Cheeks: Crystal.jade,
  QuizOptionIds.q4BetweenEyebrows: Crystal.whiteQuartz,
  QuizOptionIds.q4Forehead: Crystal.whiteQuartz,
  QuizOptionIds.q4Neck: Crystal.redJasper,
  // Q5 — area to focus.
  QuizOptionIds.q5Jawline: Crystal.redJasper,
  QuizOptionIds.q5Cheekbones: Crystal.whiteQuartz,
  QuizOptionIds.q5Neck: Crystal.redJasper,
  QuizOptionIds.q5EyeArea: Crystal.obsidian,
  QuizOptionIds.q5OverallHarmony: Crystal.jade,
  // Q6 — how the skin is responding.
  QuizOptionIds.q6CalmBalanced: Crystal.whiteQuartz,
  QuizOptionIds.q6SlightlySensitive: Crystal.jade,
  QuizOptionIds.q6RedIrritated: Crystal.jade,
  QuizOptionIds.q6ActiveBreakout: Crystal.obsidian,
  QuizOptionIds.q6RecoveringTreatment: Crystal.jade,

  // Intention (60%)
  // Q7 — how to feel at the end of the ritual.
  QuizOptionIds.q7MoreSculpted: Crystal.redJasper,
  QuizOptionIds.q7MoreRadiant: Crystal.whiteQuartz,
  QuizOptionIds.q7Refreshed: Crystal.jade,
  QuizOptionIds.q7DeeplyRelaxed: Crystal.jade,
  QuizOptionIds.q7Grounded: Crystal.obsidian,
  // Q8 — intention for today's ritual.
  QuizOptionIds.q8Clarity: Crystal.whiteQuartz,
  QuizOptionIds.q8Harmony: Crystal.jade,
  QuizOptionIds.q8Grounding: Crystal.redJasper,
  QuizOptionIds.q8Protection: Crystal.obsidian,
  QuizOptionIds.q8Vitality: Crystal.redJasper,
  // Q9 — what to cultivate over the next 20 days.
  QuizOptionIds.q9ClarityRenewal: Crystal.whiteQuartz,
  QuizOptionIds.q9BalanceHarmony: Crystal.jade,
  QuizOptionIds.q9GroundingProtection: Crystal.obsidian,
  QuizOptionIds.q9VitalityConfidence: Crystal.redJasper,
};

Map<Crystal, double> _bucketScores(QuizAnswers answers, List<int> questions) {
  final totals = <Crystal, double>{
    for (final crystal in Crystal.values) crystal: 0,
  };
  var answered = 0;

  for (final question in questions) {
    final selected = answers.selectedIds(question);
    if (selected.isEmpty) continue;

    final votes = <Crystal>{};
    for (final optionId in selected) {
      final crystal = quizCrystalSignals[optionId];
      if (crystal != null) votes.add(crystal);
    }
    if (votes.isEmpty) continue;

    answered += 1;
    final share = 1.0 / votes.length;
    for (final crystal in votes) {
      totals[crystal] = totals[crystal]! + share;
    }
  }

  if (answered == 0) return const {};

  return {
    for (final entry in totals.entries)
      if (entry.value > 0) entry.key: entry.value / answered,
  };
}

/// Per-crystal scores after renormalizing active bucket weights.
Map<Crystal, double> scoreCrystals(QuizAnswers answers) {
  final emotion = _bucketScores(answers, emotionQuestions);
  final skin = _bucketScores(answers, skinQuestions);

  var emotionW = 0.0;
  var skinW = 0.0;
  if (emotion.isNotEmpty) emotionW = emotionWeight;
  if (skin.isNotEmpty) skinW = skinWeight;
  final weightSum = emotionW + skinW;
  if (weightSum == 0) return const {};

  final scores = <Crystal, double>{};
  void addBucket(Map<Crystal, double> bucket, double weight) {
    if (bucket.isEmpty || weight == 0) return;
    final scaled = weight / weightSum;
    for (final entry in bucket.entries) {
      scores[entry.key] = (scores[entry.key] ?? 0) + entry.value * scaled;
    }
  }

  addBucket(emotion, emotionW);
  addBucket(skin, skinW);
  return scores;
}

Crystal assignCrystal(QuizAnswers answers) {
  final scores = scoreCrystals(answers);
  if (scores.isEmpty) return crystalTieBreakOrder.first;

  var bestScore = double.negativeInfinity;
  for (final score in scores.values) {
    if (score > bestScore) bestScore = score;
  }

  for (final crystal in crystalTieBreakOrder) {
    final score = scores[crystal];
    if (score != null && (score - bestScore).abs() < 1e-9) return crystal;
  }
  return crystalTieBreakOrder.first;
}
