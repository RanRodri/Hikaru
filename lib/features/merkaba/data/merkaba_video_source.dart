import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Pre-rendered five minute Merkaba video, without sound.
const String merkabaVideoFileName = 'merkaba_full_5min.mp4';


/// Storage path of the video in the Hikaru bucket.
const String merkabaVideoStoragePath = 'Merkaba/$merkabaVideoFileName';

/// Direct bucket address. It is the last resort when no signed address can be
/// made, for instance before the user signs in.
final Uri merkabaVideoPublicUrl = Uri.parse(
  'https://amplify-hikaruliftbe-robi-hikaruliftfilesbucket1e5-zbfl7l0c3j0t'
  '.s3.us-east-1.amazonaws.com/$merkabaVideoStoragePath',
);

/// Where the player should read the video from.
sealed class MerkabaVideoLocation {
  const MerkabaVideoLocation();
}

/// Copy saved on the device by an earlier session.
class MerkabaCachedVideo extends MerkabaVideoLocation {
  const MerkabaCachedVideo(this.file);

  final File file;
}

/// Video streamed from S3.
class MerkabaStreamedVideo extends MerkabaVideoLocation {
  const MerkabaStreamedVideo(this.url);

  final Uri url;
}

abstract interface class MerkabaVideoSource {
  /// The saved copy when there is one, otherwise a streaming address.
  Future<MerkabaVideoLocation> resolve();

  /// Saves the video on the device for the next session. Does nothing when a
  /// copy exists or a download is already running. Never throws.
  Future<void> cache();
}

/// Streams the video the first time and keeps a copy for later sessions.
class CachedMerkabaVideoSource implements MerkabaVideoSource {
  CachedMerkabaVideoSource({
    required Future<Directory> Function() directory,
    required Future<Uri?> Function() signedUrl,
    required Uri publicUrl,
    Future<int> Function(Uri url, File target)? download,
  }) : _directory = directory,
       _signedUrl = signedUrl,
       _publicUrl = publicUrl,
       _download = download ?? downloadToFile;

  final Future<Directory> Function() _directory;
  final Future<Uri?> Function() _signedUrl;
  final Uri _publicUrl;
  final Future<int> Function(Uri url, File target) _download;

  Future<void>? _caching;

  @override
  Future<MerkabaVideoLocation> resolve() async {
    final file = await _file();
    if (await _isUsable(file)) return MerkabaCachedVideo(file);
    return MerkabaStreamedVideo(await _address());
  }

  @override
  Future<void> cache() => _caching ??= _saveCopy().whenComplete(() {
    _caching = null;
  });

  Future<void> _saveCopy() async {
    try {
      final file = await _file();
      if (await _isUsable(file)) return;
      await file.parent.create(recursive: true);
      final part = File('${file.path}.part');
      final written = await _download(await _address(), part);
      if (written <= 0) {
        if (await part.exists()) await part.delete();
        return;
      }
      if (await file.exists()) await file.delete();
      await part.rename(file.path);
    } catch (error, stackTrace) {
      log(
        'Merkaba video was not saved on the device',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Uri> _address() async {
    try {
      return await _signedUrl() ?? _publicUrl;
    } catch (error, stackTrace) {
      log(
        'Merkaba video could not be signed',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
      return _publicUrl;
    }
  }

  Future<File> _file() async {
    final directory = await _directory();
    return File('${directory.path}/$merkabaVideoFileName');
  }

  Future<bool> _isUsable(File file) async {
    try {
      return await file.exists() && await file.length() > 0;
    } on FileSystemException {
      return false;
    }
  }
}

/// Streams [url] into [target] without holding the video in memory. Returns
/// the bytes written, or 0 when the server refused or the transfer was short.
Future<int> downloadToFile(Uri url, File target) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      return 0;
    }
    final sink = target.openWrite();
    var written = 0;
    try {
      await for (final chunk in response) {
        sink.add(chunk);
        written += chunk.length;
      }
    } finally {
      await sink.close();
    }
    final expected = response.contentLength;
    if (expected >= 0 && written != expected) return 0;
    return written;
  } finally {
    client.close();
  }
}

Future<Uri?> _amplifySignedUrl() async {
  if (!Amplify.isConfigured) return null;
  try {
    final session = await Amplify.Auth.fetchAuthSession();
    if (!session.isSignedIn) return null;
    final result = await Amplify.Storage.getUrl(
      path: StoragePath.fromString(merkabaVideoStoragePath),
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
  return Directory('${support.path}/merkaba');
}

final merkabaVideoSourceProvider = Provider<MerkabaVideoSource>(
  (ref) => CachedMerkabaVideoSource(
    directory: _cacheDirectory,
    signedUrl: _amplifySignedUrl,
    publicUrl: merkabaVideoPublicUrl,
  ),
);
