import '../../crystals/domain/crystal.dart';
import 'library_article.dart';

class LibraryCollection {
  const LibraryCollection({
    required this.id,
    required this.name,
    required this.detail,
    required this.category,
    required this.imageAsset,
    required this.photoHeight,
    this.diameter = 104,
    this.isHighlighted = false,
  });

  final String id;
  final String name;
  final String detail;
  final String category;
  final String imageAsset;
  final double diameter;
  final double photoHeight;
  final bool isHighlighted;

  String get inlineDetail => detail.replaceAll('\n', ' ');

  String get semanticsLabel => '$name, $inlineDetail';
}

const String _crystalGuide = 'CRYSTAL GUIDE';

const LibraryCollection merkabaCollection = LibraryCollection(
  id: libraryMerkabaId,
  name: 'MERKABA',
  detail: 'Geometry & Energy',
  category: 'SACRED GEOMETRY',
  imageAsset: 'assets/images/library_merkaba.png',
  diameter: 110,
  photoHeight: 60,
  isHighlighted: true,
);

const LibraryCollection ritualsCollection = LibraryCollection(
  id: libraryRitualsId,
  name: 'HIKARU RITUALS',
  detail: 'Face & Body',
  category: 'RITUAL GUIDE',
  imageAsset: 'assets/images/library_rituals.png',
  diameter: 106,
  photoHeight: 56,
);

const String libraryMeridiansId = 'meridians';
const String libraryLymphaticId = 'lymphatic';
const String libraryFasciaId = 'fascia';
const String libraryGuaShaId = 'gua_sha';

const String _methodGuide = 'METHOD GUIDE';

const LibraryCollection meridiansCollection = LibraryCollection(
  id: libraryMeridiansId,
  name: 'MERIDIANS',
  detail: 'Energy Flow',
  category: _methodGuide,
  imageAsset: 'assets/images/library_meridians.png',
  photoHeight: 54,
);

const LibraryCollection lymphaticCollection = LibraryCollection(
  id: libraryLymphaticId,
  name: 'LYMPHATIC',
  detail: 'Detox & Renew',
  category: _methodGuide,
  imageAsset: 'assets/images/library_lymphatic.png',
  photoHeight: 54,
);

const LibraryCollection fasciaCollection = LibraryCollection(
  id: libraryFasciaId,
  name: 'FASCIA',
  detail: 'Living Matrix',
  category: _methodGuide,
  imageAsset: 'assets/images/library_fascia.png',
  photoHeight: 54,
);

const LibraryCollection guaShaCollection = LibraryCollection(
  id: libraryGuaShaId,
  name: 'GUA SHA',
  detail: 'History & Sculpt',
  category: _methodGuide,
  imageAsset: 'assets/images/library_gua_sha.png',
  photoHeight: 54,
);

/// Topics added from the client infographics. They have no ARB copy yet, so
/// their name, detail and category come straight from the domain.
const Set<String> libraryInfographicOnlyIds = {
  libraryMeridiansId,
  libraryLymphaticId,
  libraryFasciaId,
  libraryGuaShaId,
};

const Map<Crystal, LibraryCollection> crystalCollections = {
  Crystal.jade: LibraryCollection(
    id: 'jade',
    name: 'JADE',
    detail: 'Balance\n& Harmony',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_jade.png',
    photoHeight: 54,
  ),
  Crystal.whiteQuartz: LibraryCollection(
    id: 'whiteQuartz',
    name: 'WHITE QUARTZ',
    detail: 'Clarity\n& Renewal',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_white_quartz.png',
    photoHeight: 54,
  ),
  Crystal.redJasper: LibraryCollection(
    id: 'redJasper',
    name: 'RED JASPER',
    detail: 'Vitality\n& Grounding',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_red_jasper.png',
    photoHeight: 54,
  ),
  Crystal.obsidian: LibraryCollection(
    id: 'obsidian',
    name: 'OBSIDIAN',
    detail: 'Protection\n& Transformation',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_obsidian.png',
    photoHeight: 54,
  ),
};

final List<LibraryCollection> libraryCollections = [
  merkabaCollection,
  crystalCollections[Crystal.jade]!,
  crystalCollections[Crystal.whiteQuartz]!,
  crystalCollections[Crystal.redJasper]!,
  crystalCollections[Crystal.obsidian]!,
  ritualsCollection,
];

/// Pages of The Hikaru Ritual, in swipe order. The ritual itself comes
/// first; the four method topics follow as its chapters rather than as
/// separate circles in the library.
const List<LibraryCollection> libraryRitualPages = [
  ritualsCollection,
  guaShaCollection,
  meridiansCollection,
  lymphaticCollection,
  fasciaCollection,
];

/// Short tab label of each ritual page.
const Map<String, String> libraryRitualPageLabels = {
  libraryRitualsId: 'THE RITUAL',
  libraryGuaShaId: 'GUA SHA',
  libraryMeridiansId: 'MERIDIANS',
  libraryLymphaticId: 'LYMPHATIC',
  libraryFasciaId: 'FASCIA',
};

/// Index of [id] among the ritual pages, or -1.
int libraryRitualPageIndex(String id) =>
    libraryRitualPages.indexWhere((page) => page.id == id);

LibraryCollection? libraryCollectionFor(String id) {
  for (final collection in [...libraryCollections, ...libraryRitualPages]) {
    if (collection.id == id) return collection;
  }
  return null;
}

LibraryCollection? nextLibraryCollection(String id) {
  final index = libraryCollections.indexWhere(
    (collection) => collection.id == id,
  );
  if (index < 0) return null;
  return libraryCollections[(index + 1) % libraryCollections.length];
}
