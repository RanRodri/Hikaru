import '../../../l10n/app_localizations.dart';
import '../../listening_room/domain/journey_recommendation.dart';
import '../domain/crystal.dart';

/// Localized copy for a [Crystal].
///
/// The enum keeps stable names and English text as a reference. Screens ask
/// for the text in the active language through these getters, so the crystal
/// stored by name keeps working when the user changes language.
extension CrystalTexts on Crystal {
  String localizedName(AppLocalizations l10n) => l10n.crystalTextName(name);

  String localizedTemple(AppLocalizations l10n) => l10n.crystalTextTemple(name);

  String localizedProtocol(AppLocalizations l10n) =>
      l10n.crystalTextProtocol(name);

  String localizedFrequency(AppLocalizations l10n) =>
      l10n.crystalTextFrequency(name);

  String localizedFrequencyDetail(AppLocalizations l10n) =>
      l10n.crystalTextFrequencyDetail(name);

  String localizedFrequencyTagline(AppLocalizations l10n) =>
      l10n.crystalTextFrequencyTagline(name);

  String localizedPurpose(AppLocalizations l10n) =>
      l10n.crystalTextPurpose(name);

  String localizedSkinBenefit(AppLocalizations l10n) =>
      l10n.crystalTextSkinBenefit(name);

  String localizedMeridians(AppLocalizations l10n) =>
      l10n.crystalTextMeridians(name);

  String localizedEnvironment(AppLocalizations l10n) =>
      l10n.crystalTextEnvironment(name);

  String localizedSymbolicTitle(AppLocalizations l10n) =>
      l10n.crystalTextSymbolicTitle(name);

  String localizedRevelation(AppLocalizations l10n) =>
      l10n.crystalTextRevelation(name);

  /// Title of the benefit at [index] in [Crystal.benefits].
  String localizedBenefitTitle(AppLocalizations l10n, int index) =>
      l10n.crystalTextBenefitTitle('$name$index');

  /// Detail of the benefit at [index] in [Crystal.benefits].
  String localizedBenefitDetail(AppLocalizations l10n, int index) =>
      l10n.crystalTextBenefitDetail('$name$index');

  /// Default intention for this crystal, in the active language.
  String localizedDefaultIntention(AppLocalizations l10n) =>
      l10n.recommendationIntention(defaultIntention);
}

/// Localized copy for the protocol stored in a [JourneyRecommendation].
///
/// The recommendation persists English text. The domain exposes those values
/// as [RecommendationCopy] constants, and these methods translate the known
/// ones. Text that is not recognized is returned unchanged.
extension RecommendationTexts on AppLocalizations {
  String recommendationIntention(String stored) => switch (stored) {
    RecommendationCopy.intentionSelfAwareness => recIntentionSelfAwareness,
    RecommendationCopy.intentionMentalClarity => recIntentionMentalClarity,
    RecommendationCopy.intentionCalmComfort => recIntentionCalmComfort,
    RecommendationCopy.intentionVitality => recIntentionVitality,
    RecommendationCopy.intentionInnerIllumination =>
      recIntentionInnerIllumination,
    RecommendationCopy.intentionHarmony => recIntentionHarmony,
    RecommendationCopy.intentionGrounding => recIntentionGrounding,
    _ => stored,
  };

  String recommendationSkinFocus(String stored) => switch (stored) {
    RecommendationCopy.skinFocusSoothing => recSkinFocusSoothing,
    RecommendationCopy.skinFocusHydration => recSkinFocusHydration,
    RecommendationCopy.skinFocusLift => recSkinFocusLift,
    RecommendationCopy.skinFocusRadiance => recSkinFocusRadiance,
    _ => stored,
  };

  String recommendationFacialRitual(String stored) => switch (stored) {
    RecommendationCopy.ritualSoothing => recRitualSoothing,
    RecommendationCopy.ritualHydration => recRitualHydration,
    RecommendationCopy.ritualLift => recRitualLift,
    RecommendationCopy.ritualRadiance => recRitualRadiance,
    _ => stored,
  };
}
