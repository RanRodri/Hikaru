import '../../listening_room/domain/discovery_quiz.dart';
import '../../listening_room/domain/quiz_answers.dart';
import 'crystal.dart';

/// Maps a completed quiz to a crystal.
///
/// Tiers follow crystal-assignment.md, highest priority first. A tier that
/// matches one crystal wins immediately. A tier that matches several narrows
/// the pool and later tiers may only keep crystals still in that pool. Renewal
/// is the only option that matches two crystals (Jade and Obsidian). If more
/// than one crystal remains, the order in that note breaks the tie: Jade,
/// White Quartz, Red Jasper, Obsidian. The same order is the fallback when no
/// answer matches a crystal.
///
/// Questions 3, 9 and 10 are stored with the quiz and are not part of the
/// algorithm. Options absent from [quizCrystalSignals] do not vote.
const List<Crystal> crystalTieBreakOrder = [
  Crystal.jade,
  Crystal.whiteQuartz,
  Crystal.redJasper,
  Crystal.obsidian,
];

const List<List<int>> crystalPriorityTiers = [
  [8],
  [2, 6],
  [1, 4, 5],
  [7],
];

const Map<String, Set<Crystal>> quizCrystalSignals = {
  QuizOptionIds.q8Harmony: {Crystal.jade},
  QuizOptionIds.q8SelfLove: {Crystal.jade},
  QuizOptionIds.q8Renewal: {Crystal.jade, Crystal.obsidian},
  QuizOptionIds.q8Clarity: {Crystal.whiteQuartz},
  QuizOptionIds.q8Expansion: {Crystal.whiteQuartz},
  QuizOptionIds.q8Vitality: {Crystal.redJasper},
  QuizOptionIds.q8Grounding: {Crystal.redJasper},
  QuizOptionIds.q8Protection: {Crystal.obsidian},
  QuizOptionIds.q2Sensitive: {Crystal.jade},
  QuizOptionIds.q6SlightlySensitive: {Crystal.jade},
  QuizOptionIds.q6RedOrIrritated: {Crystal.jade},
  QuizOptionIds.q1ReducePuffiness: {Crystal.obsidian},
  QuizOptionIds.q1RestoreGlow: {Crystal.whiteQuartz},
  QuizOptionIds.q1ReduceRedness: {Crystal.jade},
  QuizOptionIds.q4Jaw: {Crystal.jade},
  QuizOptionIds.q4BetweenEyebrows: {Crystal.jade},
  QuizOptionIds.q4Neck: {Crystal.jade},
  QuizOptionIds.q7Relaxed: {Crystal.jade},
  QuizOptionIds.q7Radiant: {Crystal.whiteQuartz},
  QuizOptionIds.q7Connected: {Crystal.whiteQuartz},
  QuizOptionIds.q7Grounded: {Crystal.redJasper},
  QuizOptionIds.q7Restored: {Crystal.redJasper},
  QuizOptionIds.q7Sculpted: {Crystal.obsidian},
  QuizOptionIds.q7LessPuffy: {Crystal.obsidian},
};

Crystal assignCrystal(QuizAnswers answers) {
  Set<Crystal>? pool;

  for (final tier in crystalPriorityTiers) {
    final hits = <Crystal>{};
    for (final question in tier) {
      for (final optionId in answers.selectedIds(question)) {
        hits.addAll(quizCrystalSignals[optionId] ?? const {});
      }
    }
    if (hits.isEmpty) continue;

    if (pool == null) {
      if (hits.length == 1) return hits.single;
      pool = hits;
      continue;
    }

    final narrowed = pool.intersection(hits);
    if (narrowed.length == 1) return narrowed.single;
    if (narrowed.length > 1) pool = narrowed;
  }

  final remaining = pool ?? crystalTieBreakOrder.toSet();
  for (final crystal in crystalTieBreakOrder) {
    if (remaining.contains(crystal)) return crystal;
  }
  return crystalTieBreakOrder.first;
}
