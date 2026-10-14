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
  });

  final String id;
  final String title;
  final List<LibraryBlock> blocks;

  int get readingMinutes {
    final words = blocks
        .map((block) => block.body.split(RegExp(r'\s+')).length)
        .fold(0, (total, count) => total + count);
    return (words / _wordsPerMinute).ceil().clamp(1, 60);
  }

  static const int _wordsPerMinute = 200;
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
    blocks: [
      LibraryBlock('Temple', crystal.temple),
      LibraryBlock('Purpose', crystal.purpose),
      LibraryBlock('Skin', crystal.skinBenefit),
      LibraryBlock('Meridians', crystal.meridians),
      LibraryBlock('Frequency', _frequencyCopy(crystal)),
      LibraryBlock('Environment', crystal.environment),
      LibraryBlock('Intention', _intentions[crystal]!),
    ],
  );
}

String _frequencyCopy(Crystal crystal) {
  final tail = crystal.protocol.contains(Crystal.composer)
      ? '${Crystal.sessionLength}.'
      : '${Crystal.sessionLength}. ${Crystal.composer}.';
  return '${crystal.frequency}. ${crystal.frequencyDetail}. '
      '${crystal.protocol}. $tail';
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
        '0:00–0:40 Human Blueprint. A figure of light with a pulsing heart '
            'traces the five-pointed star. Gyan Mudra. Presence and awareness.',
        '0:40–1:30 Air Becomes the Vehicle. The star dissolves into ribbons of '
            'air that spiral with the breath. Vayu Mudra. Air, movement, and breath.',
        '1:30–3:40 Breath Builds the Merkaba. The two interlocking tetrahedra '
            'are drawn edge by edge around the body. Lotus Mudra. Receiving and expansion.',
        '3:40–4:30 Expansion Through Coherence. The triangles counter-rotate '
            'and the field expands with heart coherence. Akash Mudra. '
            'Spaciousness and consciousness.',
        '4:30–5:00 The Heart Blossoms. The Merkaba slows, its lines soften and '
            'bloom into the Anahata heart mandala. Anjali. Integration and gratitude.',
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
