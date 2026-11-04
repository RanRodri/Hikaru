import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../../core/audio/audio_report.dart';
import '../domain/merkaba_session.dart';

/// Sanctuary ambient loop and soft breath sounds for the Merkaba session.
///
/// There are no bells. The ambient loop fades in when the session plays and
/// out when it pauses, ends or the user leaves. The breath player mixes
/// without requesting audio focus, so it never interrupts the ambient loop on
/// Android.
class MerkabaSoundscape {
  // Kept well below the ambient bed. The visual breath guide carries the
  // rhythm; this sound should be perceived more than consciously heard.
  static const double breathVolume = 0.10;
  static const double ambientVolume = 0.16;

  /// Looping sanctuary ambience.
  static const String ambientAsset = 'audio/merkaba_ambient.wav';

  /// Soft breath that accompanies the inhale and the exhale. The hold stays
  /// silent.
  static const Map<BreathPhase, String> breathAssets = {
    BreathPhase.inhale: 'audio/merkaba_breath_inhale.m4a',
    BreathPhase.exhale: 'audio/merkaba_breath_exhale.m4a',
  };

  static const Duration fadeIn = Duration(milliseconds: 4000);
  static const Duration fadeOut = Duration(milliseconds: 3200);
  static const Duration leaveFade = Duration(milliseconds: 1200);
  static const Duration _fadeTick = Duration(milliseconds: 100);

  AudioPlayer? _breath;
  AudioPlayer? _ambient;
  bool _ambientLoaded = false;
  int _fadeGeneration = 0;
  bool _disposed = false;

  /// Plays the breath sound of [phase], starting [into] it when the session
  /// resumes mid-phase. The hold stops the breath and stays silent.
  Future<void> cue(BreathPhase phase, {Duration into = Duration.zero}) async {
    if (_disposed) return;
    try {
      final asset = breathAssets[phase];
      if (asset == null) {
        final breath = _breath;
        if (breath != null) await _stop(breath);
        return;
      }
      final breath = _breath ??= _mixingPlayer();
      await breath.setReleaseMode(ReleaseMode.stop);
      await breath.stop();
      await breath.play(
        AssetSource(asset),
        volume: breathVolume,
        position: into > Duration.zero ? into : null,
      );
    } catch (error, stackTrace) {
      reportAudioFailure('Merkaba breath $phase', error, stackTrace);
    }
  }

  /// Starts the ambient loop, or brings it back after a pause, fading in.
  Future<void> startAmbient() async {
    if (_disposed) return;
    final generation = ++_fadeGeneration;
    try {
      final player = _ambient ??= _mixingPlayer();
      if (_ambientLoaded) {
        await player.resume();
      } else {
        await player.setVolume(0);
        await player.setReleaseMode(ReleaseMode.loop);
        await player.play(AssetSource(ambientAsset), volume: 0);
        _ambientLoaded = true;
      }
      await _fade(player, ambientVolume, fadeIn, generation);
    } catch (error, stackTrace) {
      reportAudioFailure('Merkaba ambient', error, stackTrace);
    }
  }

  /// Fades the ambient out and holds it, and silences the breath.
  Future<void> pause() async {
    final generation = ++_fadeGeneration;
    try {
      final breath = _breath;
      if (breath != null) await breath.pause();
      final ambient = _ambient;
      if (ambient == null || !_ambientLoaded) return;
      await _fade(ambient, 0, leaveFade, generation);
      if (generation == _fadeGeneration && !_disposed) await ambient.pause();
    } catch (error, stackTrace) {
      reportAudioFailure('Merkaba pause', error, stackTrace);
    }
  }

  /// Lets the last breath ring out and fades the ambient loop into silence.
  Future<void> finish() async {
    final player = _ambient;
    if (player == null || !_ambientLoaded) return;
    final generation = ++_fadeGeneration;
    try {
      await _fade(player, 0, fadeOut, generation);
      if (generation == _fadeGeneration && !_disposed) await player.stop();
      if (generation == _fadeGeneration) _ambientLoaded = false;
    } catch (error, stackTrace) {
      reportAudioFailure('Merkaba ambient fade', error, stackTrace);
    }
  }

  /// Fades the sound out, then releases the players. It keeps running after
  /// the screen is gone.
  Future<void> dispose() async {
    if (_disposed) return;
    final generation = ++_fadeGeneration;
    final ambient = _ambient;
    try {
      await _breath?.stop();
      if (ambient != null && _ambientLoaded) {
        await _fade(ambient, 0, leaveFade, generation);
      }
    } catch (error, stackTrace) {
      reportAudioFailure('Merkaba leave fade', error, stackTrace);
    }
    _disposed = true;
    final players = [_breath, ambient].whereType<AudioPlayer>();
    try {
      await Future.wait(players.map((player) => player.dispose()));
    } catch (error, stackTrace) {
      reportAudioFailure('Merkaba dispose', error, stackTrace);
    }
  }

  /// Moves the volume of [player] to [target] in small steps. A newer fade
  /// replaces this one.
  Future<void> _fade(
    AudioPlayer player,
    double target,
    Duration duration,
    int generation,
  ) async {
    final steps = (duration.inMilliseconds / _fadeTick.inMilliseconds).round();
    final from = player.volume;
    for (var step = 1; step <= steps; step++) {
      await Future<void>.delayed(_fadeTick);
      if (_disposed || generation != _fadeGeneration) return;
      await player.setVolume(from + (target - from) * step / steps);
    }
  }

  AudioPlayer _mixingPlayer() {
    final player = AudioPlayer();
    unawaited(
      player
          .setAudioContext(
            AudioContextConfig(
              focus: AudioContextConfigFocus.mixWithOthers,
            ).build(),
          )
          .catchError((Object error, StackTrace stackTrace) {
            reportAudioFailure('Merkaba mix context', error, stackTrace);
          }),
    );
    return player;
  }

  Future<void> _stop(AudioPlayer player) async {
    if (_disposed) return;
    try {
      await player.stop();
    } catch (error, stackTrace) {
      reportAudioFailure('Merkaba breath stop', error, stackTrace);
    }
  }
}
