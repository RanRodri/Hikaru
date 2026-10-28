enum MassageSurface { face, body }

enum MassagePressure {
  light('Light'),
  moderate('Moderate'),
  firm('Firm');

  const MassagePressure(this.label);

  final String label;
}

class MassageZone {
  const MassageZone({
    required this.name,
    required this.focus,
    required this.instruction,
  });

  final String name;
  final String focus;
  final String instruction;
}

/// Available face-ritual lengths from the Listening Garden time preference.
const List<int> faceSessionMinutesOptions = [3, 5, 10];

class MassageRitual {
  const MassageRitual({
    required this.surface,
    required this.temple,
    required this.subtitle,
    required this.zones,
    required this.posterAsset,
    this.sessionLength = const Duration(minutes: 10),
    this.videoUrl,
  });

  final MassageSurface surface;
  final String temple;
  final String subtitle;
  final List<MassageZone> zones;

  /// Still frame for the video area. Replace the file at this path.
  final String posterAsset;
  final Duration sessionLength;
  final String? videoUrl;

  Duration get zoneLength => sessionLength ~/ zones.length;

  MassageRitual copyWith({Duration? sessionLength}) => MassageRitual(
    surface: surface,
    temple: temple,
    subtitle: subtitle,
    zones: zones,
    posterAsset: posterAsset,
    sessionLength: sessionLength ?? this.sessionLength,
    videoUrl: videoUrl,
  );
}

int clampFaceSessionMinutes(int? minutes) {
  if (minutes == null) return 5;
  if (faceSessionMinutesOptions.contains(minutes)) return minutes;
  return 5;
}

/// Model using Hikaru Lift on the face. The file is not in the repo yet.
const String faceRitualPosterAsset =
    'assets/images/rituals/face_hikaru_lift.png';

/// Model using Hikaru on the body. The file is not in the repo yet.
const String bodyRitualPosterAsset =
    'assets/images/rituals/body_hikaru_lift.png';

const MassageRitual faceRitual = MassageRitual(
  surface: MassageSurface.face,
  temple: 'THE FACE TEMPLE',
  subtitle: 'HIKARU LIFT RITUAL · FACE',
  posterAsset: faceRitualPosterAsset,
  zones: [
    MassageZone(
      name: 'Jawline',
      focus: 'Lift · Drain · Firm',
      instruction:
          'Place Hikaru beneath the ear, then glide upward along the jawline.',
    ),
    MassageZone(
      name: 'Neck',
      focus: 'Drain · Release · Soften',
      instruction:
          'Glide Hikaru down the sides of the neck, from the jaw to the collarbone.',
    ),
    MassageZone(
      name: 'Cheeks',
      focus: 'Lift · Sculpt · Glow',
      instruction:
          'Sweep Hikaru from the side of the nose outward across the cheekbones.',
    ),
    MassageZone(
      name: 'Nasolabial',
      focus: 'Smooth · Lift · Renew',
      instruction:
          'Glide Hikaru from the corner of the mouth up toward the temple.',
    ),
    MassageZone(
      name: 'Forehead',
      focus: 'Release · Smooth · Calm',
      instruction:
          'Glide Hikaru from the brows upward to the hairline, then out to the temples.',
    ),
  ],
);

const MassageRitual bodyRitual = MassageRitual(
  surface: MassageSurface.body,
  temple: 'THE BODY TEMPLE',
  subtitle: 'HIKARU LIFT RITUAL · BODY',
  posterAsset: bodyRitualPosterAsset,
  zones: [
    MassageZone(
      name: 'Glutes',
      focus: 'Lift · Sculpt · Firm',
      instruction:
          'Sweep Hikaru upward from the base of the glutes toward the hips.',
    ),
    MassageZone(
      name: 'Legs',
      focus: 'Drain · Lift · Renew',
      instruction:
          'Glide Hikaru upward from the ankles toward the knees and thighs.',
    ),
    MassageZone(
      name: 'Abdomen',
      focus: 'Release · Flow · Warm',
      instruction: 'Trace slow clockwise circles around the navel.',
    ),
    MassageZone(
      name: 'Chest',
      focus: 'Open · Drain · Breathe',
      instruction:
          'Glide Hikaru from the sternum outward toward the underarms.',
    ),
  ],
);

MassageRitual ritualFor(MassageSurface surface) =>
    surface == MassageSurface.face ? faceRitual : bodyRitual;

String formatMassageClock(Duration duration) {
  final bounded = duration.isNegative ? Duration.zero : duration;
  final minutes = bounded.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = bounded.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
