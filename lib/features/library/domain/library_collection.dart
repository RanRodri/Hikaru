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
  photoHeight: 79,
  isHighlighted: true,
);

const LibraryCollection ritualsCollection = LibraryCollection(
  id: libraryRitualsId,
  name: 'HIKARU RITUALS',
  detail: 'Face & Body',
  category: 'RITUAL GUIDE',
  imageAsset: 'assets/images/library_rituals.png',
  diameter: 106,
  photoHeight: 74,
);

const Map<Crystal, LibraryCollection> crystalCollections = {
  Crystal.jade: LibraryCollection(
    id: 'jade',
    name: 'JADE',
    detail: 'Balance\n& Harmony',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_jade.png',
    photoHeight: 70,
  ),
  Crystal.whiteQuartz: LibraryCollection(
    id: 'whiteQuartz',
    name: 'WHITE QUARTZ',
    detail: 'Clarity\n& Renewal',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_white_quartz.png',
    photoHeight: 70,
  ),
  Crystal.redJasper: LibraryCollection(
    id: 'redJasper',
    name: 'RED JASPER',
    detail: 'Vitality\n& Grounding',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_red_jasper.png',
    photoHeight: 66,
  ),
  Crystal.obsidian: LibraryCollection(
    id: 'obsidian',
    name: 'OBSIDIAN',
    detail: 'Protection\n& Transformation',
    category: _crystalGuide,
    imageAsset: 'assets/images/library_obsidian.png',
    photoHeight: 66,
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

LibraryCollection? libraryCollectionFor(String id) {
  for (final collection in libraryCollections) {
    if (collection.id == id) return collection;
  }
  return null;
}

LibraryCollection nextLibraryCollection(String id) {
  final index = libraryCollections.indexWhere(
    (collection) => collection.id == id,
  );
  return libraryCollections[(index + 1) % libraryCollections.length];
}
