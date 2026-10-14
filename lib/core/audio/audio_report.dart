import 'dart:developer';

/// Records an audio failure without stopping the session.
///
/// Playback stays silent or falls back to the simulated rhythm. The log is
/// what makes a missing backend or a bad asset visible.
void reportAudioFailure(String action, Object error, StackTrace stackTrace) {
  log(action, name: 'hikaru.audio', error: error, stackTrace: stackTrace);
}
