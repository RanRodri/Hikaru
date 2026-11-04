import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'remote_file_cache.dart';

/// Saves signed images under the app support directory.
class DirectoryRemoteFileStore implements RemoteFileStore {
  DirectoryRemoteFileStore({Future<Directory> Function()? directory})
    : _directory = directory ?? _cacheDirectory;

  final Future<Directory> Function() _directory;

  @override
  Future<List<int>?> read(String fileName) async {
    try {
      final file = await _file(fileName);
      if (!await file.exists()) return null;
      final length = await file.length();
      if (length <= 0) return null;
      return const [1];
    } catch (error, stackTrace) {
      _report(error, stackTrace);
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
      _report(error, stackTrace);
      return null;
    }
  }

  Future<File> _file(String fileName) async {
    final directory = await _directory();
    return File('${directory.path}/$fileName');
  }

  void _report(Object error, StackTrace stackTrace) {
    log(
      'Remote image cache',
      name: 'hikaru.media',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final remoteImageCacheProvider = Provider<RemoteFileCache>(
  (ref) => RemoteFileCache(
    storagePrefix: 'crystal-images',
    canFetch: _signedIn,
    download: _amplifyDownload,
    store: DirectoryRemoteFileStore(),
  ),
);

final remoteImagePathProvider = FutureProvider.family<String?, String>((
  ref,
  fileName,
) async {
  final cache = ref.watch(remoteImageCacheProvider);
  final first = await cache.resolve(fileName);
  if (first != null) return first;
  // The first attempt can run before the identity credentials are ready.
  await Future<void>.delayed(const Duration(milliseconds: 600));
  if (!ref.mounted) return null;
  return cache.resolve(fileName);
});

Future<bool> _signedIn() async {
  if (!Amplify.isConfigured) return false;
  try {
    final session = await Amplify.Auth.fetchAuthSession();
    return session.isSignedIn;
  } on AmplifyException {
    return false;
  }
}

/// Reads the object with the signed-in role. A presigned URL plus a raw
/// HTTP GET fails for these KMS objects and the screen stays blank.
Future<List<int>?> _amplifyDownload(String storagePath) async {
  try {
    final result = await Amplify.Storage.downloadData(
      path: StoragePath.fromString(storagePath),
    ).result;
    if (result.bytes.isEmpty) return null;
    return result.bytes;
  } on AmplifyException catch (error, stackTrace) {
    log(
      'Remote image $storagePath',
      name: 'hikaru.media',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}

/// Puts the Listening Room and quiz photos on the device before those
/// screens open, so the first frame is not a blank background.
Future<void> prepareListeningRoomImages(RemoteFileCache cache) async {
  final heroes = [
    cache.resolve('listening_room.png'),
    cache.resolve('listening_room_quiz.png'),
  ];
  cache.resolve('ritual_ready.png');
  cache.resolve('mirror_garden.png');
  try {
    await Future.wait(heroes).timeout(const Duration(seconds: 6));
  } on TimeoutException {
    // Open the screen anyway. The photo appears if the download catches up.
  }
}

/// Puts the Home garden photo on the device before that screen opens.
Future<void> prepareHomeBackground(RemoteFileCache cache) async {
  final home = cache.resolve('harmony_garden_background.png');
  cache.resolve('garden_sunset_reflections.png');
  cache.resolve('library.png');
  try {
    await home.timeout(const Duration(seconds: 6));
  } on TimeoutException {
    // Open Home anyway. The photo appears if the download catches up.
  }
}

Future<Directory> _cacheDirectory() async {
  final support = await getApplicationSupportDirectory();
  return Directory('${support.path}/crystal-images');
}
