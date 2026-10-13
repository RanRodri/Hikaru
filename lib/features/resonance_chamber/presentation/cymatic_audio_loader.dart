import 'package:flutter/services.dart';

import '../../../core/audio/audio_report.dart';
import '../domain/cymatic_audio.dart';

final Map<String, Future<CymaticEnvelope?>> _envelopeCache = {};

/// Loads the precomputed envelope for [audioAsset]. A missing or unreadable
/// asset returns null so the mandala can keep the simulated rhythm.
Future<CymaticEnvelope?> loadCymaticEnvelope(String audioAsset) {
  return _envelopeCache.putIfAbsent(audioAsset, () async {
    try {
      final data = await rootBundle.load(cymaticEnvelopeAsset(audioAsset));
      return CymaticEnvelope.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic envelope $audioAsset', error, stackTrace);
      return null;
    }
  });
}
