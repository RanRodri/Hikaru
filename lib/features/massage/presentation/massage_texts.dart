import '../../../l10n/app_localizations.dart';
import '../domain/massage_ritual.dart';

/// Localized copy for the massage rituals.
///
/// The domain keeps the English text as a reference. Zones are recognized by
/// their English name, which is unique across the face and body rituals; a
/// zone that is not recognized keeps its original text.
extension MassageTexts on AppLocalizations {
  String massageTemple(MassageRitual ritual) => switch (ritual.surface) {
    MassageSurface.face => massageFaceTemple,
    MassageSurface.body => massageBodyTemple,
  };

  String massageSubtitle(MassageRitual ritual) => switch (ritual.surface) {
    MassageSurface.face => massageFaceSubtitle,
    MassageSurface.body => massageBodySubtitle,
  };

  String massageZoneName(MassageZone zone) => switch (zone.name) {
    'Jawline' => massageZoneJawline,
    'Neck' => massageZoneNeck,
    'Cheeks' => massageZoneCheeks,
    'Nasolabial' => massageZoneNasolabial,
    'Forehead' => massageZoneForehead,
    'Glutes' => massageZoneGlutes,
    'Legs' => massageZoneLegs,
    'Abdomen' => massageZoneAbdomen,
    'Chest' => massageZoneChest,
    _ => zone.name,
  };

  String massageZoneInstruction(MassageZone zone) => switch (zone.name) {
    'Jawline' => massageInstructionJawline,
    'Neck' => massageInstructionNeck,
    'Cheeks' => massageInstructionCheeks,
    'Nasolabial' => massageInstructionNasolabial,
    'Forehead' => massageInstructionForehead,
    'Glutes' => massageInstructionGlutes,
    'Legs' => massageInstructionLegs,
    'Abdomen' => massageInstructionAbdomen,
    'Chest' => massageInstructionChest,
    _ => zone.instruction,
  };
}
