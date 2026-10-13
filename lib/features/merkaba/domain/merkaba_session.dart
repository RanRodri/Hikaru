enum BreathPhase { inhale, hold, exhale }

class MerkabaScene {
  const MerkabaScene({
    required this.title,
    required this.mudra,
    required this.mudraPurpose,
    required this.start,
    required this.end,
  });

  final String title;
  final String mudra;
  final String mudraPurpose;
  final Duration start;
  final Duration end;
}

const Duration merkabaDuration = Duration(minutes: 5);
const Duration breathInhale = Duration(seconds: 4);
const Duration breathHold = Duration(seconds: 4);
const Duration breathExhale = Duration(seconds: 6);
const Duration breathCycle = Duration(seconds: 14);

/// Official Merkaba Room timeline (corrected): five scenes.
const List<MerkabaScene> merkabaScenes = [
  MerkabaScene(
    title: 'Human Blueprint',
    mudra: 'Gyan Mudra',
    mudraPurpose: 'Presence and awareness',
    start: Duration.zero,
    end: Duration(seconds: 40),
  ),
  MerkabaScene(
    title: 'Air Becomes the Vehicle',
    mudra: 'Vayu Mudra',
    mudraPurpose: 'Air, movement, and breath',
    start: Duration(seconds: 40),
    end: Duration(seconds: 90),
  ),
  MerkabaScene(
    title: 'Breath Builds the Merkaba',
    mudra: 'Lotus Mudra',
    mudraPurpose: 'Receiving and expansion',
    start: Duration(seconds: 90),
    end: Duration(seconds: 220),
  ),
  MerkabaScene(
    title: 'Expansion Through Coherence',
    mudra: 'Akash Mudra',
    mudraPurpose: 'Spaciousness and consciousness',
    start: Duration(seconds: 220),
    end: Duration(seconds: 270),
  ),
  MerkabaScene(
    title: 'The Heart Blossoms',
    mudra: 'Anjali',
    mudraPurpose: 'Integration and gratitude',
    start: Duration(seconds: 270),
    end: merkabaDuration,
  ),
];

class MerkabaFrame {
  const MerkabaFrame({
    required this.elapsed,
    required this.phase,
    required this.phaseElapsed,
    required this.scene,
    required this.isFinished,
  });

  final Duration elapsed;
  final BreathPhase phase;
  final Duration phaseElapsed;
  final MerkabaScene scene;
  final bool isFinished;

  Duration get phaseDuration => switch (phase) {
    BreathPhase.inhale => breathInhale,
    BreathPhase.hold => breathHold,
    BreathPhase.exhale => breathExhale,
  };

  int get phaseSecondsRemaining {
    final remaining = phaseDuration - phaseElapsed;
    final seconds = (remaining.inMilliseconds / 1000).ceil();
    if (seconds < 1) return 1;
    return seconds;
  }

  double get phaseProgress {
    final total = phaseDuration.inMilliseconds;
    if (total == 0) return 0;
    return (phaseElapsed.inMilliseconds / total).clamp(0.0, 1.0);
  }

  String get phaseLabel => switch (phase) {
    BreathPhase.inhale => 'Inhale',
    BreathPhase.hold => 'Hold',
    BreathPhase.exhale => 'Exhale',
  };

  /// Completed 4-4-6 cycles. The in-progress cycle is the progress bar.
  int get completedCycles =>
      elapsed.inMilliseconds ~/ breathCycle.inMilliseconds;

  /// Progress through the current breath cycle, from 0 to 1.
  double get cycleProgress {
    final cycleMs = breathCycle.inMilliseconds;
    if (cycleMs == 0) return 0;
    return (elapsed.inMilliseconds % cycleMs) / cycleMs;
  }
}

/// Placeholder mudra art, one file per breath phase. Swap the PNG in place.
String mudraPlaceholderAsset(BreathPhase phase) => switch (phase) {
  BreathPhase.inhale => 'assets/images/mudras/inhale.png',
  BreathPhase.hold => 'assets/images/mudras/hold.png',
  BreathPhase.exhale => 'assets/images/mudras/exhale.png',
};

MerkabaFrame merkabaFrameAt(Duration elapsed) {
  final bounded = elapsed < Duration.zero
      ? Duration.zero
      : (elapsed > merkabaDuration ? merkabaDuration : elapsed);
  final finished = bounded >= merkabaDuration;
  final cycleMs = breathCycle.inMilliseconds;
  final position = bounded.inMilliseconds % cycleMs;
  final inhaleMs = breathInhale.inMilliseconds;
  final holdMs = breathHold.inMilliseconds;

  final BreathPhase phase;
  final int phaseElapsedMs;
  if (position < inhaleMs) {
    phase = BreathPhase.inhale;
    phaseElapsedMs = position;
  } else if (position < inhaleMs + holdMs) {
    phase = BreathPhase.hold;
    phaseElapsedMs = position - inhaleMs;
  } else {
    phase = BreathPhase.exhale;
    phaseElapsedMs = position - inhaleMs - holdMs;
  }

  final scene = merkabaScenes.lastWhere(
    (item) => bounded >= item.start,
    orElse: () => merkabaScenes.first,
  );

  return MerkabaFrame(
    elapsed: bounded,
    phase: phase,
    phaseElapsed: Duration(milliseconds: phaseElapsedMs),
    scene: scene,
    isFinished: finished,
  );
}

String formatMerkabaClock(Duration duration) {
  final bounded = duration.isNegative ? Duration.zero : duration;
  final minutes = bounded.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = bounded.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
