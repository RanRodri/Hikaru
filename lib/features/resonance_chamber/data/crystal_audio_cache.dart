import '../../../core/audio/audio_report.dart';

/// Bytes already stored on the device, keyed by file name.
abstract class AudioFileStore {
  Future<List<int>?> read(String fileName);

  Future<void> write(String fileName, List<int> bytes);

  /// Absolute path the player can open, when [read] has bytes.
  Future<String?> pathOf(String fileName);
}

/// Resolves a crystal track to a file on the device.
///
/// The first play with a session asks S3 for a short-lived signed URL and
/// saves the bytes. Later plays use that file. Without a session, or when
/// the download fails, there is no audio: the tracks are not bundled.
class CrystalAudioCache {
  CrystalAudioCache({
    required Future<bool> Function() canFetch,
    required Future<Uri?> Function(String storagePath) signedUrl,
    required Future<List<int>?> Function(Uri url) readUrl,
    required AudioFileStore store,
  }) : _canFetch = canFetch,
       _signedUrl = signedUrl,
       _readUrl = readUrl,
       _store = store;

  static const String storagePrefix = 'crystal-audio';

  final Future<bool> Function() _canFetch;
  final Future<Uri?> Function(String storagePath) _signedUrl;
  final Future<List<int>?> Function(Uri url) _readUrl;
  final AudioFileStore _store;

  final Map<String, Future<String?>> _inFlight = {};

  /// Absolute path of the track, or null when it cannot be played.
  Future<String?> resolve(String audioAsset) {
    final pending = _inFlight[audioAsset];
    if (pending != null) return pending;
    final future = _resolve(audioAsset);
    _inFlight[audioAsset] = future;
    future.whenComplete(() => _inFlight.remove(audioAsset));
    return future;
  }

  Future<String?> _resolve(String audioAsset) async {
    final fileName = _fileName(audioAsset);
    if (fileName == null) return null;

    final cached = await _store.read(fileName);
    if (cached != null && cached.isNotEmpty) {
      final path = await _store.pathOf(fileName);
      if (path != null) return path;
    }

    if (!await _canFetch()) return null;

    try {
      final url = await _signedUrl('$storagePrefix/$fileName');
      if (url == null) return null;
      final bytes = await _readUrl(url);
      if (bytes == null || bytes.isEmpty) return null;
      await _store.write(fileName, bytes);
      return _store.pathOf(fileName);
    } catch (error, stackTrace) {
      reportAudioFailure('Crystal audio $fileName', error, stackTrace);
      return null;
    }
  }

  /// `audio/jade.m4a` → `jade.m4a`. Rejects anything that is not a file name.
  static String? _fileName(String audioAsset) {
    final slash = audioAsset.lastIndexOf('/');
    final name = slash >= 0 ? audioAsset.substring(slash + 1) : audioAsset;
    if (name.isEmpty || name.contains('..') || name.contains(r'\')) {
      return null;
    }
    return name;
  }
}
