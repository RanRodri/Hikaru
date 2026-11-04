import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../crystals/domain/crystal.dart';
import '../presentation/cymatic_audio_loader.dart';

/// Real length of a crystal's track, read from its precomputed envelope.
/// Null while loading or when the envelope asset is unavailable.
final crystalTrackDurationProvider =
    FutureProvider.family<Duration?, Crystal>(
      (ref, crystal) async =>
          (await loadCymaticEnvelope(crystal.audioAsset))?.duration,
    );

/// `4:32` style label for a track length.
String formatTrackDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
