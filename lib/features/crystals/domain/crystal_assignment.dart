import '../../listening_room/domain/discovery_quiz.dart';
import '../../listening_room/domain/quiz_answers.dart';
import 'crystal.dart';

/// Proposed personalization weights (not scientific or diagnostic).
///
/// Emotional / intention answers carry 60% and skin / cosmetic outcome 30%.
/// Ritual time preference (Q9) is stored for the journey but does not score
/// crystals, so active buckets are renormalized to sum to 1.0. Q10 is
/// informative screening only and never votes.
const double emotionWeight = 0.60;
const double skinWeight = 0.30;

const List<int> emotionQuestions = [3, 4, 6, 7, 8];
const List<int> skinQuestions = [1, 2, 5];

const List<Crystal> crystalTieBreakOrder = [
  Crystal.jade,
  Crystal.whiteQuartz,
  Crystal.redJasper,
  Crystal.obsidian,
];

/// Option id → crystal signal for scoring.
const Map<String, Crystal> quizCrystalSignals = {
  // Skin / cosmetic outcome (30%)
  QuizOptionIds.q1CalmComfort: Crystal.jade,
  QuizOptionIds.q1LiftedFirm: Crystal.redJasper,
  QuizOptionIds.q1HydrationSoftness: Crystal.jade,
  QuizOptionIds.q1RadianceVitality: Crystal.whiteQuartz,
  QuizOptionIds.q2Sensitive: Crystal.jade,
  QuizOptionIds.q2TightDry: Crystal.jade,
  QuizOptionIds.q2PuffyTired: Crystal.redJasper,
  QuizOptionIds.q2ComfortableLackingRadiance: Crystal.whiteQuartz,
  QuizOptionIds.q5ChangesUnknown: Crystal.obsidian,
  QuizOptionIds.q5LossBrightness: Crystal.whiteQuartz,
  QuizOptionIds.q5StressTension: Crystal.jade,
  QuizOptionIds.q5FirmnessVitality: Crystal.redJasper,

  // Emotional state / intention (60%)
  QuizOptionIds.q3EmotionallyOverwhelmed: Crystal.obsidian,
  QuizOptionIds.q3MentallyBusy: Crystal.whiteQuartz,
  QuizOptionIds.q3DisconnectedBody: Crystal.redJasper,
  QuizOptionIds.q3CalmBalanced: Crystal.jade,
  QuizOptionIds.q4UncertaintyTension: Crystal.obsidian,
  QuizOptionIds.q4MentalNoise: Crystal.whiteQuartz,
  QuizOptionIds.q4StressPressure: Crystal.jade,
  QuizOptionIds.q4FatigueHeaviness: Crystal.redJasper,
  QuizOptionIds.q6SpaceReflect: Crystal.obsidian,
  QuizOptionIds.q6MomentClarity: Crystal.whiteQuartz,
  QuizOptionIds.q6GentlenessBalance: Crystal.jade,
  QuizOptionIds.q6GroundingStrength: Crystal.redJasper,
  QuizOptionIds.q7UnderstandBeneath: Crystal.obsidian,
  QuizOptionIds.q7GreaterClarity: Crystal.whiteQuartz,
  QuizOptionIds.q7ReturnHarmony: Crystal.jade,
  QuizOptionIds.q7InnerStrength: Crystal.redJasper,
  QuizOptionIds.q8SelfAware: Crystal.obsidian,
  QuizOptionIds.q8ClearRefreshed: Crystal.whiteQuartz,
  QuizOptionIds.q8CalmNurtured: Crystal.jade,
  QuizOptionIds.q8GroundedEnergized: Crystal.redJasper,
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
