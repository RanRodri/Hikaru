enum MassageSurface { face, body }

enum MassagePressure {
  light('Light'),
  moderate('Moderate'),
  firm('Firm');

  const MassagePressure(this.label);

  final String label;
}

class MassageZone {
  const MassageZone(this.name);

  final String name;
}

const List<MassageZone> facialZones = [
  MassageZone('Neck'),
  MassageZone('Jawline'),
  MassageZone('Cheeks'),
  MassageZone('Nasolabial'),
  MassageZone('Forehead'),
];

const List<MassageZone> bodyZones = [
  MassageZone('Chest'),
  MassageZone('Abdomen'),
  MassageZone('Glutes'),
  MassageZone('Legs'),
];

const String massageStrokeGuidance =
    'Use slow and gentle strokes. Apply light pressure and breathe deeply.';

const List<String> massageGuideLabels = [
  'Meridians',
  'Lymphatic Drainage',
  'Fascia Release',
  'Gua Sha',
];

/// Guided map for Neck & Jawline from the facial massage reference.
const List<String> neckJawlineSteps = [
  'Follow the meridian path (Stomach & Gallbladder)',
  'Drain the lymphatic system (from center outwards)',
  'Release fascia points (gentle pressure)',
  'Use Gua Sha direction (upward and outward)',
];

List<MassageZone> zonesFor(MassageSurface surface) =>
    surface == MassageSurface.face ? facialZones : bodyZones;

List<String> guidedStepsFor(MassageSurface surface, MassageZone zone) {
  final isNeckOrJaw =
      surface == MassageSurface.face &&
      (zone.name == 'Neck' || zone.name == 'Jawline');
  if (isNeckOrJaw) return neckJawlineSteps;
  return massageGuideLabels;
}

String formatMassageClock(Duration duration) {
  final bounded = duration.isNegative ? Duration.zero : duration;
  final minutes = bounded.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = bounded.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
