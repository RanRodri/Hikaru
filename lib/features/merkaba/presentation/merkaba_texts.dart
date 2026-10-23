import '../../../l10n/app_localizations.dart';
import '../domain/merkaba_session.dart';

/// Localized copy for the Merkaba meditation.
///
/// The domain keeps the English scene text as a reference and as the key for
/// artwork (see [MerkabaScene.mudraAsset]). Mudra names are Sanskrit terms
/// and are shown as they are in every language.
extension MerkabaTexts on AppLocalizations {
  String merkabaPhaseLabel(BreathPhase phase) => switch (phase) {
    BreathPhase.inhale => merkabaPhaseInhale,
    BreathPhase.hold => merkabaPhaseHold,
    BreathPhase.exhale => merkabaPhaseExhale,
  };

  String merkabaSceneTitle(MerkabaScene scene) =>
      switch (merkabaScenes.indexOf(scene)) {
        0 => merkabaScene1Title,
        1 => merkabaScene2Title,
        2 => merkabaScene3Title,
        3 => merkabaScene4Title,
        4 => merkabaScene5Title,
        _ => scene.title,
      };

  String merkabaScenePurpose(MerkabaScene scene) =>
      switch (merkabaScenes.indexOf(scene)) {
        0 => merkabaScene1Purpose,
        1 => merkabaScene2Purpose,
        2 => merkabaScene3Purpose,
        3 => merkabaScene4Purpose,
        4 => merkabaScene5Purpose,
        _ => scene.mudraPurpose,
      };
}
