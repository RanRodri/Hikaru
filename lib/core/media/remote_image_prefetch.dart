import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'remote_file_cache.dart';
import 'remote_image.dart';

/// One scheduler per cache. Every call site shares it, so independent screens
/// cannot create competing background queues.
final Expando<_RemoteImageQueue> _queues = Expando<_RemoteImageQueue>();

_RemoteImageQueue _queueFor(RemoteFileCache cache) =>
    _queues[cache] ??= _RemoteImageQueue(cache);

/// Resolves [asset], retrying when credentials are not ready yet. Amplify
/// owns the lifetime and cancellation of its platform request.
Future<String?> resolveWithRetry(
  RemoteFileCache cache,
  String asset, {
  int attempts = 3,
  Duration pause = const Duration(milliseconds: 500),
}) async {
  for (var attempt = 1; attempt <= attempts; attempt++) {
    try {
      final path = await cache.resolve(asset);
      if (path != null) return path;
    } catch (error, stackTrace) {
      log(
        'Prefetch $asset',
        name: 'hikaru.media',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (attempt < attempts) await Future<void>.delayed(pause);
  }
  return null;
}

class _RemoteImageQueue {
  _RemoteImageQueue(this.cache);

  final RemoteFileCache cache;
  final ListQueue<String> _urgent = ListQueue<String>();
  final ListQueue<String> _background = ListQueue<String>();
  final Map<String, Completer<String?>> _pending = {};
  bool _draining = false;

  Future<String?> enqueue(String asset, {required bool urgent}) {
    final ready = cache.cachedPath(asset);
    if (ready != null) return Future<String?>.value(ready);

    final existing = _pending[asset];
    if (existing != null) {
      if (urgent && _background.remove(asset)) _urgent.addFirst(asset);
      return existing.future;
    }

    final completer = Completer<String?>();
    _pending[asset] = completer;
    (urgent ? _urgent : _background).addLast(asset);
    _drain();
    return completer.future;
  }

  void _drain() {
    if (_draining) return;
    _draining = true;
    unawaited(() async {
      try {
        while (_urgent.isNotEmpty || _background.isNotEmpty) {
          final asset = _urgent.isNotEmpty
              ? _urgent.removeFirst()
              : _background.removeFirst();
          final completer = _pending[asset];
          if (completer == null) continue;
          final path = await resolveWithRetry(cache, asset);
          if (!completer.isCompleted) completer.complete(path);
          _pending.remove(asset);
        }
      } finally {
        _draining = false;
        // Work could have arrived between the loop ending and this flag.
        if (_urgent.isNotEmpty || _background.isNotEmpty) _drain();
      }
    }());
  }
}

/// Promotes [files] to the front of the shared queue. Navigation does not
/// wait: every screen already has a bundled fallback for its first frame.
Future<void> prepareRemoteImages(
  RemoteFileCache cache,
  Iterable<String> files,
) async {
  final queue = _queueFor(cache);
  for (final file in files) {
    unawaited(queue.enqueue(file, urgent: true).then<void>((_) {}));
  }
}

/// Adds future screens to the shared, low-priority queue.
void warmRemoteImages(RemoteFileCache cache, Iterable<String> files) {
  final queue = _queueFor(cache);
  for (final file in files) {
    unawaited(queue.enqueue(file, urgent: false));
  }
}

/// Before the Listening Room: its current photo first. The quiz and later
/// screens follow in likely navigation order.
Future<void> prepareListeningRoomImages(RemoteFileCache cache) async {
  await prepareRemoteImages(cache, [RemoteImages.listeningRoom]);
  warmRemoteImages(cache, [
    RemoteImages.listeningRoomQuiz,
    ...RemoteImages.afterListeningRoom,
  ]);
}

/// Before the crystal reveal: the crystal photo first, then the Home tabs.
Future<void> prepareRevelationImages(
  RemoteFileCache cache,
  String crystalPhoto,
) async {
  await prepareRemoteImages(cache, [crystalPhoto]);
  warmRemoteImages(cache, RemoteImages.homeTabs);
}

/// Before Home: the garden first, then the other tabs' backgrounds.
Future<void> prepareHomeBackground(RemoteFileCache cache) async {
  await prepareRemoteImages(cache, [RemoteImages.harmonyGarden]);
  warmRemoteImages(cache, [RemoteImages.sunsetGarden, RemoteImages.library]);
}
