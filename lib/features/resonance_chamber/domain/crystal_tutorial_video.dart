import '../../crystals/domain/crystal.dart';

/// Key in S3 (private bucket) of each crystal's vertical tutorial video.
///
/// Null means the video has not been delivered yet, so the UI shows the
/// placeholder. When the video arrives, only the key needs to be filled in
/// (e.g. 'crystal-tutorials/jade_tutorial.mp4').
///
/// Every key lives under [crystalTutorialStoragePrefix].
const String crystalTutorialStoragePrefix = 'crystal-tutorials';

// TODO(rances): fill in each key once the vertical tutorial videos are
// delivered and uploaded under `crystal-tutorials/` in the private bucket.
const Map<Crystal, String?> crystalTutorialVideoKeys = {
  Crystal.whiteQuartz: null,
  Crystal.jade: null,
  Crystal.obsidian: null,
  Crystal.redJasper: null,
};

String? tutorialVideoKeyFor(Crystal crystal) =>
    crystalTutorialVideoKeys[crystal];
