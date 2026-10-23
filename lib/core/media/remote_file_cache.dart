import 'dart:developer';

/// Bytes already stored on the device, keyed by file name.
abstract class RemoteFileStore {
  Future<List<int>?> read(String fileName);

  Future<void> write(String fileName, List<int> bytes);

  /// Absolute path a widget can open, when [read] has bytes.
  Future<String?> pathOf(String fileName);
}

/// Resolves a shared S3 object to a file on the device.
///
/// The first view with a session asks S3 for a short-lived signed URL and
/// saves the bytes. Later views use that file. Without a session, or when
/// the download fails, there is no file: these objects are not bundled.
class RemoteFileCache {
  RemoteFileCache({
    required this.storagePrefix,
    required Future<bool> Function() canFetch,
    required Future<Uri?> Function(String storagePath) signedUrl,
    required Future<List<int>?> Function(Uri url) readUrl,
    required RemoteFileStore store,
  }) : _canFetch = canFetch,
       _signedUrl = signedUrl,
       _readUrl = readUrl,
       _store = store;

  final String storagePrefix;
  final Future<bool> Function() _canFetch;
  final Future<Uri?> Function(String storagePath) _signedUrl;
  final Future<List<int>?> Function(Uri url) _readUrl;
  final RemoteFileStore _store;

  final Map<String, Future<String?>> _inFlight = {};

  /// Absolute path of [asset], or null when it cannot be shown.
  Future<String?> resolve(String asset) {
    final pending = _inFlight[asset];
    if (pending != null) return pending;
    final future = _resolve(asset);
    _inFlight[asset] = future;
    future.whenComplete(() => _inFlight.remove(asset));
    return future;
  }

  Future<String?> _resolve(String asset) async {
    final fileName = bareName(asset);
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
      log(
        'Remote file $fileName',
        name: 'hikaru.media',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// `assets/images/jade.png` → `jade.png`. Rejects path traversal.
  static String? bareName(String asset) {
    final slash = asset.lastIndexOf('/');
    final name = slash >= 0 ? asset.substring(slash + 1) : asset;
    if (name.isEmpty || name.contains('..') || name.contains(r'\')) {
      return null;
    }
    return name;
  }
}
