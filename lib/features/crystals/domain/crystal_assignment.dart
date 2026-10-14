import '../../listening_room/domain/discovery_quiz.dart';
import '../../listening_room/domain/quiz_answers.dart';
import 'crystal.dart';

/// Maps a completed quiz to a crystal.
///
/// Tiers follow crystal-assignment.md, highest priority first. A tier that
/// matches one crystal wins immediately. A tier that matches several narrows
/// the pool and later tiers may only keep crystals still in that pool. Renewal
/// is the only option that matches two crystals (Jade and Obsidian). When
/// Renewal is the only intention and no sensitive, irritated, or stress signal
/// remains, the result is Obsidian. Those Jade skin and stress signals still
/// select Jade. Any other tie uses the note's order: Jade, White Quartz,
/// Red Jasper, Obsidian. The same order is the fallback when no answer
/// matches a crystal.
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

/// Jade signals for sensitive or irritated skin, and for marked tension.
const Set<String> jadeSkinOrStressSignals = {
  QuizOptionIds.q2Sensitive,
  QuizOptionIds.q6SlightlySensitive,
  QuizOptionIds.q6RedOrIrritated,
  QuizOptionIds.q1ReduceRedness,
  QuizOptionIds.q4Jaw,
  QuizOptionIds.q4BetweenEyebrows,
  QuizOptionIds.q4Neck,
};

bool _renewalIsOnlyIntention(QuizAnswers answers) {
  final selected = answers.selectedIds(8);
  return selected.length == 1 && selected.contains(QuizOptionIds.q8Renewal);
}

bool _hasJadeSkinOrStress(QuizAnswers answers) {
  for (final question in const [1, 2, 4, 6]) {
    for (final optionId in answers.selectedIds(question)) {
      if (jadeSkinOrStressSignals.contains(optionId)) return true;
    }
  }
  return false;
}

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
  if (_renewalIsOnlyIntention(answers) &&
      remaining.contains(Crystal.jade) &&
      remaining.contains(Crystal.obsidian) &&
      !_hasJadeSkinOrStress(answers)) {
    return Crystal.obsidian;
  }

  for (final crystal in crystalTieBreakOrder) {
    if (remaining.contains(crystal)) return crystal;
  }
  return crystalTieBreakOrder.first;
}
