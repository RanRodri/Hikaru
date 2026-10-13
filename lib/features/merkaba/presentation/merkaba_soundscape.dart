import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../domain/merkaba_session.dart';

/// Breath sounds, phase chimes and an ambient drone for the Merkaba session.
///
/// Breath and chime players mix without requesting audio focus, so they never
/// interrupt the ambient loop on Android.
class MerkabaSoundscape {
  static const double chimeVolume = 0.35;
  static const double breathVolume = 0.6;
  static const double ambientVolume = 0.2;
  static const String ambientAsset = 'audio/merkaba_ambient.wav';

  static const Map<BreathPhase, String> chimeAssets = {
    BreathPhase.inhale: 'audio/merkaba_inhale.wav',
    BreathPhase.hold: 'audio/merkaba_hold.wav',
    BreathPhase.exhale: 'audio/merkaba_exhale.wav',
  };

  static const Map<BreathPhase, String> breathAssets = {
    BreathPhase.inhale: 'audio/merkaba_breath_inhale.m4a',
    BreathPhase.exhale: 'audio/merkaba_breath_exhale.m4a',
  };

  static const int _fadeSteps = 12;
  static const Duration _fadeStep = Duration(milliseconds: 200);

  AudioPlayer? _chime;
  AudioPlayer? _breath;
  AudioPlayer? _ambient;
  bool _ambientStarted = false;
  int _ambientGeneration = 0;
  bool _disposed = false;

  /// Plays the chime of [phase]. Inhale and exhale also play their breath
  /// sound, starting [into] it when the session resumes mid-phase. Hold keeps
  /// the chime and stays silent.
  Future<void> cue(BreathPhase phase, {Duration into = Duration.zero}) async {
    if (_disposed) return;
    try {
      final chime = _chime ??= _mixingPlayer();
      final breathAsset = breathAssets[phase];
      final tasks = <Future<void>>[
        _playOnce(
          player: chime,
          asset: chimeAssets[phase]!,
          volume: chimeVolume,
        ),
      ];
      if (breathAsset == null) {
        final breath = _breath;
        if (breath != null) tasks.add(_stop(breath));
      } else {
        final breath = _breath ??= _mixingPlayer();
        tasks.add(
          _playOnce(
            player: breath,
            asset: breathAsset,
            volume: breathVolume,
            position: into,
          ),
        );
      }
      await Future.wait(tasks);
    } catch (_) {
      // Widget tests have no audio backend. Missing audio stays silent.
    }
  }

  Future<void> startAmbient() async {
    if (_disposed) return;
    _ambientGeneration++;
    try {
      final player = _ambient ??= AudioPlayer();
      await player.setVolume(ambientVolume);
      if (_ambientStarted) {
        await player.resume();
        return;
      }
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(ambientAsset));
      _ambientStarted = true;
    } catch (_) {
      // Widget tests have no audio backend. Missing audio stays silent.
    }
  }

  Future<void> pause() async {
    try {
      await Future.wait([
        if (_breath != null) _breath!.pause(),
        if (_ambient != null) _ambient!.pause(),
      ]);
    } catch (_) {
      // Widget tests have no audio backend.
    }
  }

  /// Lets the last breath ring out and fades the ambient loop into silence.
  Future<void> finish() async {
    final player = _ambient;
    if (player == null || !_ambientStarted) return;
    _ambientStarted = false;
    final generation = ++_ambientGeneration;
    try {
      for (var step = _fadeSteps - 1; step >= 0; step--) {
        await Future<void>.delayed(_fadeStep);
        if (_disposed || generation != _ambientGeneration) return;
        await player.setVolume(ambientVolume * step / _fadeSteps);
      }
      await player.stop();
    } catch (_) {
      // Widget tests have no audio backend.
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    final players = [_chime, _breath, _ambient].whereType<AudioPlayer>();
    try {
      await Future.wait(players.map((player) => player.dispose()));
    } catch (_) {
      // Widget tests have no audio backend.
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
          .catchError((Object _) {}),
    );
    return player;
  }

  Future<void> _stop(AudioPlayer player) async {
    if (_disposed) return;
    try {
      await player.stop();
    } catch (_) {
      // Widget tests have no audio backend. Missing audio stays silent.
    }
  }

  Future<void> _playOnce({
    required AudioPlayer player,
    required String asset,
    required double volume,
    Duration position = Duration.zero,
  }) async {
    if (_disposed) return;
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.stop();
      await player.play(
        AssetSource(asset),
        volume: volume,
        position: position > Duration.zero ? position : null,
      );
    } catch (_) {
      // Widget tests have no audio backend. Missing audio stays silent.
    }
  }
}
