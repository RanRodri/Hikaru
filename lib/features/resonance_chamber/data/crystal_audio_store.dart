import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/audio/audio_report.dart';
import 'crystal_audio_cache.dart';

/// Saves signed crystal audio under the app support directory.
class DirectoryAudioFileStore implements AudioFileStore {
  DirectoryAudioFileStore({Future<Directory> Function()? directory})
    : _directory = directory ?? _cacheDirectory;

  final Future<Directory> Function() _directory;

  @override
  Future<List<int>?> read(String fileName) async {
    try {
      final file = await _file(fileName);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (error, stackTrace) {
      reportAudioFailure('Crystal audio cache', error, stackTrace);
      return null;
    }
  }

  @override
  Future<void> write(String fileName, List<int> bytes) async {
    final file = await _file(fileName);
    await file.parent.create(recursive: true);
    final part = File('${file.path}.part');
    await part.writeAsBytes(bytes, flush: true);
    if (await file.exists()) await file.delete();
    await part.rename(file.path);
  }

  @override
  Future<String?> pathOf(String fileName) async {
    try {
      return (await _file(fileName)).path;
    } catch (error, stackTrace) {
      reportAudioFailure('Crystal audio cache', error, stackTrace);
      return null;
    }
  }

  Future<File> _file(String fileName) async {
    final directory = await _directory();
    return File('${directory.path}/$fileName');
  }
}

final crystalAudioCacheProvider = Provider<CrystalAudioCache>(
  (ref) => CrystalAudioCache(
    canFetch: _signedIn,
    signedUrl: _amplifySignedUrl,
    readUrl: _downloadUrl,
    store: DirectoryAudioFileStore(),
  ),
);

Future<bool> _signedIn() async {
  if (!Amplify.isConfigured) return false;
  try {
    final session = await Amplify.Auth.fetchAuthSession();
    return session.isSignedIn;
  } on AmplifyException {
    return false;
  }
}

Future<Uri?> _amplifySignedUrl(String storagePath) async {
  final result = await Amplify.Storage.getUrl(
    path: StoragePath.fromString(storagePath),
    options: const StorageGetUrlOptions(
      pluginOptions: S3GetUrlPluginOptions(
        validateObjectExistence: true,
        expiresIn: Duration(minutes: 15),
      ),
    ),
  ).result;
  return result.url;
}

Future<List<int>?> _downloadUrl(Uri url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) return null;
    return response.fold<List<int>>(
      <int>[],
      (bytes, chunk) => bytes..addAll(chunk),
    );
  } finally {
    client.close();
  }
}

Future<Directory> _cacheDirectory() async {
  final support = await getApplicationSupportDirectory();
  return Directory('${support.path}/crystal-audio');
}
