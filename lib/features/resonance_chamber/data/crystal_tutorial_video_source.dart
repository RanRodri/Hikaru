import 'dart:developer';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../crystals/domain/crystal.dart';
import '../domain/crystal_tutorial_video.dart';

/// Resolves a short-lived signed address for a crystal's tutorial video.
///
/// The bucket is private, so this uses the same Amplify Storage signed-URL
/// mechanism as the crystal audio. The video is streamed from that address;
/// nothing is downloaded to disk.
class CrystalTutorialVideoSource {
  CrystalTutorialVideoSource({
    required Future<bool> Function() canFetch,
    required Future<Uri?> Function(String storagePath) signedUrl,
    String? Function(Crystal crystal) keyFor = tutorialVideoKeyFor,
  }) : _canFetch = canFetch,
       _signedUrl = signedUrl,
       _keyFor = keyFor;

  final Future<bool> Function() _canFetch;
  final Future<Uri?> Function(String storagePath) _signedUrl;
  final String? Function(Crystal crystal) _keyFor;

  /// Streaming address for [crystal]'s tutorial, or null when there is no
  /// video yet, no session, or the address cannot be made. Never throws.
  Future<Uri?> resolve(Crystal crystal) async {
    final key = _keyFor(crystal);
    if (key == null) return null;

    // Only the folder that grants read access may be requested.
    if (!key.startsWith('$crystalTutorialStoragePrefix/')) {
      log(
        'Tutorial key outside $crystalTutorialStoragePrefix/: $key',
        name: 'hikaru.tutorial',
      );
      return null;
    }

    try {
      if (!await _canFetch()) return null;
      return await _signedUrl(key);
    } catch (error, stackTrace) {
      log(
        'Tutorial video for ${crystal.name} could not be signed',
        name: 'hikaru.tutorial',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

final crystalTutorialVideoSourceProvider = Provider<CrystalTutorialVideoSource>(
  (ref) => CrystalTutorialVideoSource(
    canFetch: _signedIn,
    signedUrl: _amplifySignedUrl,
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
