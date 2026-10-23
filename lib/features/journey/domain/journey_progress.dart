class JourneyProgress {
  const JourneyProgress({
    required this.currentDay,
    required this.cycleLength,
    this.streak = 0,
  });

  final int currentDay;
  final int cycleLength;

  /// Consecutive days with the full ritual done.
  final int streak;

  double get fraction => currentDay / cycleLength;
}

const JourneyProgress sampleJourneyProgress = JourneyProgress(
  currentDay: 14,
  cycleLength: 30,
  streak: 14,
);
