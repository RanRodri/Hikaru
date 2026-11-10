import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/media/download_to_file.dart';

/// Direct bucket address. It is the last resort when no signed address can be
/// made, for instance before the user signs in.
Uri massageVideoPublicUrl(String storagePath) => Uri.parse(
  'https://amplify-hikaruliftbe-robi-hikaruliftfilesbucket1e5-zbfl7l0c3j0t'
  '.s3.us-east-1.amazonaws.com/$storagePath',
);

/// Where the player should read a ritual video from.
sealed class MassageVideoLocation {
  const MassageVideoLocation();
}

/// Copy already saved on the device.
class MassageCachedVideo extends MassageVideoLocation {
  const MassageCachedVideo(this.file);

  final File file;
}

/// Video streamed from S3.
class MassageStreamedVideo extends MassageVideoLocation {
  const MassageStreamedVideo(this.url);

  final Uri url;
}

/// Streaming address and on-device copy for the ritual videos.
///
/// A signed address is remembered for [signedUrlLifetime], short of the hour
/// S3 grants, so opening a massage does not ask Amplify again. The file is
/// downloaded ahead of that opening; playback uses it when it is ready.
class MassageVideoSource {
  MassageVideoSource({
    Future<Uri?> Function(String storagePath)? signedUrl,
    Future<Directory> Function()? directory,
    Future<int> Function(Uri url, File target, bool Function() shouldStop)?
    download,
    DateTime Function()? clock,
    Uri Function(String storagePath)? publicUrl,
  }) : _signedUrl = signedUrl ?? _amplifySignedUrl,
       _directory = directory ?? _cacheDirectory,
       _download = download ?? _downloadToFile,
       _clock = clock ?? DateTime.now,
       _publicUrl = publicUrl ?? massageVideoPublicUrl;

  /// How long a signed address is reused. The S3 grant lasts one hour.
  static const Duration signedUrlLifetime = Duration(minutes: 50);

  final Future<Uri?> Function(String storagePath) _signedUrl;
  final Future<Directory> Function() _directory;
  final Future<int> Function(Uri url, File target, bool Function() shouldStop)
  _download;
  final DateTime Function() _clock;
  final Uri Function(String storagePath) _publicUrl;

  final Map<String, ({Uri url, DateTime expiresAt})> _signed = {};
  final Map<String, Future<Uri?>> _signing = {};
  final Map<String, Future<void>> _saves = {};

  /// Storage path whose player is using the network, so its download waits.
  String? _streaming;

  /// The saved copy when there is one, otherwise a streaming address.
  ///
  /// Marks [storagePath] as playing so a background download of that same
  /// file does not compete with the player.
  Future<MassageVideoLocation> resolve(String storagePath) async {
    final peeked = await cachedOrSigned(storagePath);
    if (peeked is MassageCachedVideo) return peeked;
    _streaming = storagePath;
    if (peeked is MassageStreamedVideo) return peeked;
    return MassageStreamedVideo(await _address(storagePath));
  }

  /// The file already on disk, or a signed address, without starting playback.
  ///
  /// Returns null when the file is absent and no signed address can be made.
  /// Unlike [resolve], this does not pause the download.
  Future<MassageVideoLocation?> cachedOrSigned(String storagePath) async {
    final file = await _existing(storagePath);
    if (file != null) return MassageCachedVideo(file);
    final url = await _sign(storagePath);
    if (url == null) return null;
    return MassageStreamedVideo(url);
  }

  /// The player is using [storagePath], so its download waits.
  void claimPlayback(String storagePath) {
    _streaming = storagePath;
  }

  /// True when [claimPlayback] is holding this video's download.
  bool isClaimed(String storagePath) => _streaming == storagePath;

  /// Downloads [paths] together, skipping a video that is playing now.
  ///
  /// Safe to call again: a file already on disk or already downloading is
  /// not fetched twice. Never throws.
  Future<void> prepare(Iterable<String> paths) {
    final saves = <Future<void>>[];
    for (final path in paths) {
      if (path == _streaming) continue;
      saves.add(
        _saves[path] ??= _save(path).whenComplete(() {
          _saves.remove(path);
        }),
      );
    }
    return Future.wait(saves);
  }

  /// [prepare] without making the caller wait.
  void warm(Iterable<String> paths) {
    unawaited(prepare(paths));
  }

  /// The massage is gone, so its file may download for the next opening.
  void releasePlayback(String storagePath) {
    if (_streaming == storagePath) _streaming = null;
    warm([storagePath]);
  }

  Future<Uri> _address(String storagePath) async {
    try {
      return await _sign(storagePath) ?? _publicUrl(storagePath);
    } catch (error, stackTrace) {
      log(
        'Ritual video could not be signed',
        name: 'hikaru.massage',
        error: error,
        stackTrace: stackTrace,
      );
      return _publicUrl(storagePath);
    }
  }

  Future<Uri?> _sign(String storagePath) {
    final cached = _signed[storagePath];
    if (cached != null && cached.expiresAt.isAfter(_clock())) {
      return Future<Uri?>.value(cached.url);
    }
    return _signing[storagePath] ??= _fetchSigned(storagePath).whenComplete(() {
      _signing.remove(storagePath);
    });
  }

  Future<Uri?> _fetchSigned(String storagePath) async {
    final url = await _signedUrl(storagePath);
    if (url == null) return null;
    _signed[storagePath] = (
      url: url,
      expiresAt: _clock().add(signedUrlLifetime),
    );
    return url;
  }

  Future<void> _save(String storagePath) async {
    try {
      if (storagePath == _streaming) return;
      if (await _existing(storagePath) != null) return;
      final url = await _sign(storagePath);
      if (url == null || storagePath == _streaming) return;
      final file = await _file(storagePath);
      await file.parent.create(recursive: true);
      final part = File('${file.path}.part');
      final written = await _download(
        url,
        part,
        () => storagePath == _streaming,
      );
      if (written <= 0 || storagePath == _streaming) {
        if (await part.exists()) await part.delete();
        return;
      }
      if (await file.exists()) await file.delete();
      await part.rename(file.path);
    } catch (error, stackTrace) {
      log(
        'Ritual video was not saved on the device',
        name: 'hikaru.massage',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<File?> _existing(String storagePath) async {
    try {
      final file = await _file(storagePath);
      if (await file.exists() && await file.length() > 0) return file;
    } on FileSystemException {
      return null;
    } catch (error, stackTrace) {
      log(
        'Ritual video cache',
        name: 'hikaru.massage',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  Future<File> _file(String storagePath) async {
    final name = _bareName(storagePath);
    final directory = await _directory();
    return File('${directory.path}/$name');
  }

  /// `Merkaba/ritual_face.mp4` → `ritual_face.mp4`. Rejects path traversal.
  static String _bareName(String storagePath) {
    final slash = storagePath.lastIndexOf('/');
    final name = slash >= 0 ? storagePath.substring(slash + 1) : storagePath;
    if (name.isEmpty || name.contains('..') || name.contains(r'\')) {
      return 'ritual.mp4';
    }
    return name;
  }
}

Future<int> _downloadToFile(Uri url, File target, bool Function() shouldStop) =>
    downloadToFile(url, target, shouldStop: shouldStop);

Future<Uri?> _amplifySignedUrl(String storagePath) async {
  if (!Amplify.isConfigured) return null;
  try {
    final session = await Amplify.Auth.fetchAuthSession();
    if (!session.isSignedIn) return null;
    final result = await Amplify.Storage.getUrl(
      path: StoragePath.fromString(storagePath),
      options: const StorageGetUrlOptions(
        pluginOptions: S3GetUrlPluginOptions(expiresIn: Duration(hours: 1)),
      ),
    ).result;
    return result.url;
  } on AmplifyException {
    return null;
  }
}

Future<Directory> _cacheDirectory() async {
  final support = await getApplicationSupportDirectory();
  return Directory('${support.path}/massage-videos');
}

final massageVideoSourceProvider = Provider<MassageVideoSource>(
  (ref) => MassageVideoSource(),
);
