import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../data/massage_video_source.dart';

/// Opens a ritual video the way the massage screen plays it.
typedef MassageControllerOpener =
    Future<VideoPlayerController?> Function(MassageVideoLocation location);

/// Gets a ritual video ready before the massage screen opens.
///
/// The visible wait is the player reading the start of the file. That starts
/// while the member is still on the splash, home, or the crystal page. The
/// full file is saved afterwards, so the next opening reads it from the phone.
class MassageVideoPreheat {
  MassageVideoPreheat(this._source, {MassageControllerOpener? open})
    : _openController = open ?? _openPlayer;

  final MassageVideoSource _source;
  final MassageControllerOpener _openController;

  final Map<String, Future<VideoPlayerController?>> _slots = {};
  final Set<String> _handedOff = {};
  final Set<String> _fromNetwork = {};
  int _generation = 0;

  /// Starts the player for every path, then the file download.
  ///
  /// A video the screen is already playing is left alone.
  void warm(Iterable<String> paths) {
    for (final path in paths) {
      if (_handedOff.contains(path) || _source.isClaimed(path)) continue;
      _slots.putIfAbsent(path, () => _open(path));
    }
  }

  /// The screen takes the player. Null when it could not be opened.
  Future<VideoPlayerController?> take(String path) async {
    _handedOff.add(path);
    final future = _slots.remove(path) ?? _open(path);
    final controller = await future;
    if (controller == null) {
      _handedOff.remove(path);
      _fromNetwork.remove(path);
      return null;
    }
    if (_fromNetwork.remove(path)) {
      final location = await _source.cachedOrSigned(path);
      if (location is! MassageCachedVideo) _source.claimPlayback(path);
    }
    return controller;
  }

  /// The screen is gone. The file may finish downloading, and the player
  /// for the next opening starts again.
  void release(String path) {
    _handedOff.remove(path);
    _fromNetwork.remove(path);
    _source.releasePlayback(path);
    if (_source.isClaimed(path)) return;
    _slots.putIfAbsent(path, () => _open(path));
  }

  /// Drops players that no screen has taken, for sign-out.
  void discard() {
    _generation++;
    final pending = List<Future<VideoPlayerController?>>.of(_slots.values);
    _slots.clear();
    _handedOff.clear();
    _fromNetwork.clear();
    for (final future in pending) {
      unawaited(future.then((controller) => controller?.dispose()));
    }
  }

  Future<VideoPlayerController?> _open(String path) async {
    final generation = _generation;
    final location = await _source.cachedOrSigned(path);
    if (location == null || generation != _generation) return null;
    if (location is MassageStreamedVideo) _fromNetwork.add(path);
    final controller = await _openController(location);
    if (generation != _generation) {
      await controller?.dispose();
      return null;
    }
    // Save the file unless the screen already took this player and needs
    // the connection for itself. A failed open still saves it for later.
    final saveForLater =
        location is MassageStreamedVideo &&
        !_handedOff.contains(path) &&
        !_source.isClaimed(path);
    if (controller == null) {
      _fromNetwork.remove(path);
      if (saveForLater) _source.warm([path]);
      return null;
    }
    if (saveForLater) _source.warm([path]);
    return controller;
  }
}

Future<VideoPlayerController?> _openPlayer(
  MassageVideoLocation location,
) async {
  final options = VideoPlayerOptions(mixWithOthers: true);
  final controller = switch (location) {
    MassageCachedVideo(:final file) => VideoPlayerController.file(
      file,
      videoPlayerOptions: options,
    ),
    MassageStreamedVideo(:final url) => VideoPlayerController.networkUrl(
      url,
      videoPlayerOptions: options,
    ),
  };
  try {
    await controller.initialize();
    await controller.setLooping(false);
    return controller;
  } catch (_) {
    await controller.dispose();
    return null;
  }
}

final massageVideoPreheatProvider = Provider<MassageVideoPreheat>((ref) {
  final preheat = MassageVideoPreheat(ref.watch(massageVideoSourceProvider));
  ref.onDispose(preheat.discard);
  return preheat;
});
