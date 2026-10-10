class JourneyProgress {
  const JourneyProgress({required this.currentDay, required this.cycleLength});

  final int currentDay;
  final int cycleLength;

  double get fraction => currentDay / cycleLength;
}

const JourneyProgress sampleJourneyProgress = JourneyProgress(
  currentDay: 14,
  cycleLength: 30,
);
