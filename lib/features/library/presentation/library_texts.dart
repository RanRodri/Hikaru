import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../listening_room/domain/journey_recommendation.dart';
import '../domain/library_article.dart';
import '../domain/library_collection.dart';

/// Localized copy for the library.
///
/// The domain keeps stable ids and English text as a reference. Screens ask
/// for the text in the active language through these helpers, so navigation
/// by id keeps working when the user changes language.
extension LibraryCollectionTexts on LibraryCollection {
  /// Crystal collections reuse the crystal name; the others have their own.
  String localizedName(AppLocalizations l10n) {
    if (libraryInfographicOnlyIds.contains(id)) return name;
    final crystal = Crystal.fromName(id);
    return crystal?.localizedName(l10n) ?? l10n.libraryTextCollectionName(id);
  }

  /// Two-line detail, as shown inside the collection circles.
  String localizedDetail(AppLocalizations l10n) =>
      libraryInfographicOnlyIds.contains(id)
      ? detail
      : l10n.libraryTextCollectionDetail(id);

  String localizedInlineDetail(AppLocalizations l10n) =>
      localizedDetail(l10n).replaceAll('\n', ' ');

  String localizedCategory(AppLocalizations l10n) =>
      libraryInfographicOnlyIds.contains(id)
      ? category
      : l10n.libraryTextCollectionCategory(id);

  String localizedSemanticsLabel(AppLocalizations l10n) =>
      '${localizedName(l10n)}, ${localizedInlineDetail(l10n)}';
}

/// Rebuilds [article] in the active language.
///
/// Articles for crystals are composed from the crystal's own copy, and the
/// Merkaba and Rituals articles come from the ARB files. An unknown id is
/// returned unchanged.
///
/// When [recommendation] is the user's saved recommendation and it is for the
/// same crystal as [article], the article opens with a "why we recommended
/// this crystal" chapter. Any other crystal keeps its usual chapters.
LibraryArticle localizedLibraryArticle(
  AppLocalizations l10n,
  LibraryArticle article, {
  JourneyRecommendation? recommendation,
}) {
  final crystal = Crystal.fromName(article.id);
  if (crystal != null) {
    return _crystalArticle(
      l10n,
      crystal,
      recommendation: recommendation?.crystal == crystal
          ? recommendation
          : null,
    );
  }

  return switch (article.id) {
    libraryMerkabaId => _merkabaArticle(l10n),
    libraryRitualsId => _ritualsArticle(l10n),
    _ => article,
  };
}

LibraryArticle _crystalArticle(
  AppLocalizations l10n,
  Crystal crystal, {
  JourneyRecommendation? recommendation,
}) {
  return LibraryArticle(
    id: crystal.name,
    title: crystal.localizedName(l10n),
    blocks: [
      if (recommendation != null)
        LibraryBlock(
          l10n.libraryCrystalHeadingWhyRecommended,
          _whyRecommendedCopy(l10n, crystal, recommendation),
        ),
      LibraryBlock(
        l10n.libraryCrystalHeadingTemple,
        crystal.localizedTemple(l10n),
      ),
      LibraryBlock(
        l10n.libraryCrystalHeadingPurpose,
        crystal.localizedPurpose(l10n),
      ),
      LibraryBlock(
        l10n.libraryCrystalHeadingSkin,
        crystal.localizedSkinBenefit(l10n),
      ),
      LibraryBlock(
        l10n.libraryCrystalHeadingMeridians,
        crystal.localizedMeridians(l10n),
      ),
      LibraryBlock(
        l10n.libraryCrystalHeadingFrequency,
        _frequencyCopy(l10n, crystal),
      ),
      LibraryBlock(
        l10n.libraryCrystalHeadingEnvironment,
        crystal.localizedEnvironment(l10n),
      ),
      LibraryBlock(
        l10n.libraryCrystalHeadingIntention,
        l10n.libraryCrystalIntention(crystal.name),
      ),
    ],
  );
}

/// The revelation text and the protocol rows from the reveal screen, each
/// on its own line. Reuses existing copy only.
String _whyRecommendedCopy(
  AppLocalizations l10n,
  Crystal crystal,
  JourneyRecommendation recommendation,
) => [
  crystal.localizedRevelation(l10n),
  '${l10n.resonanceProtocolIntention}: '
      '${l10n.recommendationIntention(recommendation.intention)}',
  '${l10n.resonanceProtocolSkinFocus}: '
      '${l10n.recommendationSkinFocus(recommendation.skinFocus)}',
  '${l10n.resonanceProtocolFacialRitual}: '
      '${l10n.recommendationFacialRitual(recommendation.facialRitual)}',
].join('\n');

/// Same composition as the domain article: frequency, detail and protocol.
String _frequencyCopy(AppLocalizations l10n, Crystal crystal) =>
    '${crystal.localizedFrequency(l10n)}. '
    '${crystal.localizedFrequencyDetail(l10n)}. '
    '${crystal.localizedProtocol(l10n)}.';

LibraryArticle _merkabaArticle(AppLocalizations l10n) {
  return LibraryArticle(
    id: libraryMerkabaId,
    title: 'MERKABA',
    blocks: [
      LibraryBlock(l10n.libraryMerkabaHeadingDuration, l10n.recDuration(5)),
      LibraryBlock(l10n.libraryMerkabaHeadingBreath, l10n.libraryMerkabaBreath),
      LibraryBlock(
        l10n.libraryMerkabaHeadingScenes,
        [
          l10n.libraryMerkabaScene1,
          l10n.libraryMerkabaScene2,
          l10n.libraryMerkabaScene3,
          l10n.libraryMerkabaScene4,
          l10n.libraryMerkabaScene5,
        ].join('\n'),
      ),
      LibraryBlock(l10n.libraryMerkabaHeadingCues, l10n.libraryMerkabaCues),
    ],
  );
}

LibraryArticle _ritualsArticle(AppLocalizations l10n) {
  return LibraryArticle(
    id: libraryRitualsId,
    title: l10n.libraryTextCollectionName(libraryRitualsId),
    blocks: [
      LibraryBlock(
        l10n.libraryRitualsHeadingSequence,
        l10n.libraryRitualsSequence,
      ),
    ],
  );
}
