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
    Future<Uri?> Function(String storagePath)? signedUrl,
    Future<List<int>?> Function(Uri url)? readUrl,
    Future<List<int>?> Function(String storagePath)? download,
    required RemoteFileStore store,
  }) : _canFetch = canFetch,
       _signedUrl = signedUrl,
       _readUrl = readUrl,
       _download = download,
       _store = store;

  final String storagePrefix;
  final Future<bool> Function() _canFetch;
  final Future<Uri?> Function(String storagePath)? _signedUrl;
  final Future<List<int>?> Function(Uri url)? _readUrl;
  final Future<List<int>?> Function(String storagePath)? _download;
  final RemoteFileStore _store;

  final Map<String, Future<String?>> _inFlight = {};
  final Map<String, String> _ready = {};

  /// Path already resolved in this session, so the first frame can paint it.
  String? cachedPath(String asset) {
    final fileName = bareName(asset);
    if (fileName == null) return null;
    return _ready[fileName];
  }

  /// Absolute path of [asset], or null when it cannot be shown.
  Future<String?> resolve(String asset) {
    final fileName = bareName(asset);
    if (fileName == null) return Future<String?>.value();
    final ready = _ready[fileName];
    if (ready != null) return Future<String?>.value(ready);
    final pending = _inFlight[fileName];
    if (pending != null) return pending;
    final future = _resolve(asset);
    _inFlight[fileName] = future;
    future.whenComplete(() => _inFlight.remove(fileName));
    return future;
  }

  Future<String?> _resolve(String asset) async {
    final fileName = bareName(asset);
    if (fileName == null) return null;

    final cached = await _store.read(fileName);
    if (cached != null && cached.isNotEmpty) {
      final path = await _store.pathOf(fileName);
      if (path != null) {
        _ready[fileName] = path;
        return path;
      }
    }

    if (!await _canFetch()) return null;

    try {
      final storagePath = '$storagePrefix/$fileName';
      final download = _download;
      final signedUrl = _signedUrl;
      final readUrl = _readUrl;
      final List<int>? bytes;
      if (download != null) {
        bytes = await download(storagePath);
      } else if (signedUrl != null && readUrl != null) {
        final url = await signedUrl(storagePath);
        if (url == null) return null;
        bytes = await readUrl(url);
      } else {
        return null;
      }
      if (bytes == null || bytes.isEmpty) return null;
      await _store.write(fileName, bytes);
      final path = await _store.pathOf(fileName);
      if (path != null) _ready[fileName] = path;
      return path;
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
