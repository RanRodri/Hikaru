enum MassageSurface { face, body, tutorial }

class MassageZone {
  const MassageZone({
    required this.name,
    required this.focus,
    required this.instruction,
    required this.start,
  });

  final String name;
  final String focus;
  final String instruction;

  /// Where this zone begins inside the ritual video.
  final Duration start;
}

/// A ritual whose length and zone changes follow its video.
class MassageRitual {
  const MassageRitual({
    required this.surface,
    required this.temple,
    required this.subtitle,
    required this.zones,
    required this.videoDuration,
    required this.videoStoragePath,
  });

  final MassageSurface surface;
  final String temple;
  final String subtitle;
  final List<MassageZone> zones;

  /// Full length of the video. The session ends when the video does.
  final Duration videoDuration;

  /// Key of the video in the Hikaru bucket.
  final String videoStoragePath;

  /// Same ritual measured against the real length reported by the player.
  MassageRitual withVideoDuration(Duration duration) => MassageRitual(
    surface: surface,
    temple: temple,
    subtitle: subtitle,
    zones: zones,
    videoDuration: duration,
    videoStoragePath: videoStoragePath,
  );

  Duration zoneStart(int index) => zones[index].start;

  Duration zoneEnd(int index) =>
      index >= zones.length - 1 ? videoDuration : zones[index + 1].start;

  Duration zoneLength(int index) => zoneEnd(index) - zoneStart(index);

  /// Zone that [position] falls in. Past the end it stays on the last zone.
  int zoneIndexAt(Duration position) {
    for (var index = zones.length - 1; index > 0; index--) {
      if (position >= zones[index].start) return index;
    }
    return 0;
  }
}

const MassageRitual faceRitual = MassageRitual(
  surface: MassageSurface.face,
  temple: 'THE FACE TEMPLE',
  subtitle: 'HIKARU LIFT RITUAL · FACE',
  videoDuration: Duration(milliseconds: 196700),
  videoStoragePath: 'Merkaba/ritual_face.mp4',
  zones: [
    MassageZone(
      name: 'Jawline',
      focus: 'Lift · Drain · Firm',
      instruction:
          'Place Hikaru beneath the ear, then glide upward along the jawline.',
      start: Duration.zero,
    ),
    MassageZone(
      name: 'Neck',
      focus: 'Drain · Release · Soften',
      instruction:
          'Glide Hikaru down the sides of the neck, from the jaw to the collarbone.',
      start: Duration(seconds: 35),
    ),
    MassageZone(
      name: 'Cheeks',
      focus: 'Lift · Sculpt · Glow',
      instruction:
          'Sweep Hikaru from the side of the nose outward across the cheekbones.',
      start: Duration(milliseconds: 68800),
    ),
    MassageZone(
      name: 'Nasolabial',
      focus: 'Smooth · Lift · Renew',
      instruction:
          'Glide Hikaru from the corner of the mouth up toward the temple.',
      start: Duration(milliseconds: 103100),
    ),
    MassageZone(
      name: 'Forehead',
      focus: 'Release · Smooth · Calm',
      instruction:
          'Glide Hikaru from the brows upward to the hairline, then out to the temples.',
      start: Duration(milliseconds: 147600),
    ),
  ],
);

const MassageRitual bodyRitual = MassageRitual(
  surface: MassageSurface.body,
  temple: 'THE BODY TEMPLE',
  subtitle: 'HIKARU LIFT RITUAL · BODY',
  videoDuration: Duration(milliseconds: 179500),
  videoStoragePath: 'Merkaba/ritual_body.mp4',
  zones: [
    MassageZone(
      name: 'Legs',
      focus: 'Drain · Lift · Renew',
      instruction:
          'Glide Hikaru upward from the ankles toward the knees and thighs.',
      start: Duration.zero,
    ),
    MassageZone(
      name: 'Chest',
      focus: 'Open · Drain · Breathe',
      instruction:
          'Glide Hikaru from the sternum outward toward the underarms.',
      start: Duration(milliseconds: 67500),
    ),
    MassageZone(
      name: 'Abdomen',
      focus: 'Release · Flow · Warm',
      instruction: 'Trace slow clockwise circles around the navel.',
      start: Duration(milliseconds: 105700),
    ),
    MassageZone(
      name: 'Body',
      focus: 'Lift · Sculpt · Firm',
      instruction:
          'Sweep Hikaru upward along the arms and hips, one side at a time.',
      start: Duration(milliseconds: 131500),
    ),
  ],
);

/// The crystal roller tutorial. One stretch, no zones to step through.
const MassageRitual tutorialRitual = MassageRitual(
  surface: MassageSurface.tutorial,
  temple: 'THE CRYSTAL TUTORIAL',
  subtitle: 'HIKARU LIFT RITUAL · TUTORIAL',
  videoDuration: Duration(milliseconds: 112366),
  videoStoragePath: 'Merkaba/ritual_tutorial.mp4',
  zones: [
    MassageZone(
      name: 'Tutorial',
      focus: 'Learn · Glide · Begin',
      instruction:
          'Watch how to glide the crystal before you begin your frequency.',
      start: Duration.zero,
    ),
  ],
);

MassageRitual ritualFor(MassageSurface surface) => switch (surface) {
  MassageSurface.face => faceRitual,
  MassageSurface.body => bodyRitual,
  MassageSurface.tutorial => tutorialRitual,
};

String formatMassageClock(Duration duration) {
  final bounded = duration.isNegative ? Duration.zero : duration;
  final minutes = bounded.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = bounded.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
