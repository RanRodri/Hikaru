import '../../listening_room/domain/discovery_quiz.dart';
import '../../listening_room/domain/quiz_answers.dart';
import 'crystal.dart';

/// Proposed personalization weights (not scientific or diagnostic).
///
/// Emotional / intention answers carry 60% and skin / cosmetic outcome 30%.
/// Ritual time (Q9) and sculpting familiarity (Q10) are stored for the
/// journey but do not score crystals, so active buckets are renormalized to
/// sum to 1.0. Options without an entry below are stored and never vote:
/// Figma does not assign them a crystal. Q2 keeps the crystal of the skin
/// options that survived ("Sensitive", and "Tight" / "Dry" split from
/// "Tight or dry"). Q8 carries the four intentions Fernanda named.
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
  // Skin options that kept their previous crystal (30% bucket, Q2).
  QuizOptionIds.q2Sensitive: Crystal.jade,
  QuizOptionIds.q2Tight: Crystal.jade,
  QuizOptionIds.q2Dry: Crystal.jade,

  // Intention options named with a crystal (60% bucket, Q8).
  QuizOptionIds.q8ClarityRenewal: Crystal.whiteQuartz,
  QuizOptionIds.q8BalanceHarmony: Crystal.jade,
  QuizOptionIds.q8GroundingProtection: Crystal.obsidian,
  QuizOptionIds.q8VitalityConfidence: Crystal.redJasper,
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
