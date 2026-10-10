import '../../crystals/domain/crystal.dart';

class LibraryBlock {
  const LibraryBlock(this.heading, this.body);

  final String heading;
  final String body;
}

class LibraryArticle {
  const LibraryArticle({
    required this.id,
    required this.title,
    required this.blocks,
    this.imageAsset,
  });

  final String id;
  final String title;
  final String? imageAsset;
  final List<LibraryBlock> blocks;
}

const String libraryMerkabaId = 'merkaba';
const String libraryRitualsId = 'rituals';

LibraryArticle? libraryArticleFor(String? id) {
  if (id == null) return null;
  if (id == libraryMerkabaId) return _merkaba;
  if (id == libraryRitualsId) return _rituals;
  final crystal = Crystal.fromName(id);
  if (crystal == null) return null;
  return _crystalArticle(crystal);
}

LibraryArticle _crystalArticle(Crystal crystal) {
  return LibraryArticle(
    id: crystal.name,
    title: crystal.displayName,
    imageAsset: crystal.imageAsset,
    blocks: [
      LibraryBlock('Temple', crystal.temple),
      LibraryBlock('Purpose', crystal.purpose),
      LibraryBlock('Skin', crystal.skinBenefit),
      LibraryBlock('Meridians', crystal.meridians),
      LibraryBlock(
        'Frequency',
        '${crystal.frequency}. ${crystal.frequencyDetail}. '
            '${crystal.protocol}. ${Crystal.sessionLength}. '
            '${Crystal.composer}.',
      ),
      LibraryBlock('Environment', crystal.environment),
      LibraryBlock('Intention', _intentions[crystal]!),
    ],
  );
}

const Map<Crystal, String> _intentions = {
  Crystal.jade: 'Harmony, Self-Love, Renewal',
  Crystal.whiteQuartz: 'Clarity, Expansion, Radiance',
  Crystal.redJasper: 'Vitality, Grounding',
  Crystal.obsidian: 'Protection, Renewal, Transformation',
};

final LibraryArticle _merkaba = LibraryArticle(
  id: libraryMerkabaId,
  title: 'MERKABA',
  imageAsset: 'assets/images/library_merkaba.png',
  blocks: [
    const LibraryBlock('Duration', '5 minutes'),
    const LibraryBlock(
      'Breath',
      'Inhale 4 seconds. Hold 4 seconds. Exhale 6 seconds.\n'
          'Every inhale creates. Every hold is organized. Every exhale reveals.\n'
          'Breath is the invisible architect. Air is the medium. '
          'Light is the material. Geometry is the result.',
    ),
    LibraryBlock(
      'Scenes',
      [
        '0:00–0:40 Human Blueprint. Gyan Mudra. Presence and awareness.',
        '0:40–1:30 Breath Creates the Star. Hridaya Mudra. Opening the heart.',
        '1:30–2:20 Air Becomes the Vehicle. Vayu Mudra. Air, movement, and breath.',
        '2:20–3:40 Breath Builds the Merkaba. Lotus Mudra. Receiving and expansion.',
        '3:40–4:30 Expansion Through Coherence. Akash Mudra. Spaciousness and consciousness.',
        '4:30–5:00 The Heart Blossoms. Anjali. Integration and gratitude.',
      ].join('\n'),
    ),
    const LibraryBlock(
      'Cues',
      'One clear chime cues Inhale (4 seconds). '
          'A soft sustained shimmer cues Hold (4 seconds). '
          'A warm lower chime cues Exhale (6 seconds).',
    ),
  ],
);

const LibraryArticle _rituals = LibraryArticle(
  id: libraryRitualsId,
  title: 'HIKARU RITUALS',
  imageAsset: 'assets/images/library_rituals.png',
  blocks: [
    LibraryBlock(
      'Sequence',
      '01 The Merkaba Room. Breathing 4·4·6: inhale 4 seconds, hold 4 seconds, '
          'exhale 6 seconds. Mudras.\n'
          '02 Hikaru Massage Experience. Facial Gua Sha. The massage maps '
          'meridians, lymphatic drainage, fascia, and the 54 facial muscles.\n'
          '03 Hikaru Massage Experience. Body Gua Sha. Timer. '
          'Pressure: Light, Moderate, Firm.\n'
          '04 Frequency and cymatics. 528 Hz, Maestro Jorge Alfano. '
          'Locked until the Merkaba meditation and the Gua Sha massage are complete.',
    ),
  ],
);
