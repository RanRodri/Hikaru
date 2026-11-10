import 'dart:developer';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Direct bucket address. It is the last resort when no signed address can be
/// made, for instance before the user signs in.
Uri massageVideoPublicUrl(String storagePath) => Uri.parse(
  'https://amplify-hikaruliftbe-robi-hikaruliftfilesbucket1e5-zbfl7l0c3j0t'
  '.s3.us-east-1.amazonaws.com/$storagePath',
);

/// Streaming address for a ritual video stored under `Merkaba/`.
///
/// The bucket is private, so a signed address is preferred. Never throws.
class MassageVideoSource {
  MassageVideoSource({Future<Uri?> Function(String storagePath)? signedUrl})
    : _signedUrl = signedUrl ?? _amplifySignedUrl;

  final Future<Uri?> Function(String storagePath) _signedUrl;

  Future<Uri> resolve(String storagePath) async {
    try {
      return await _signedUrl(storagePath) ??
          massageVideoPublicUrl(storagePath);
    } catch (error, stackTrace) {
      log(
        'Ritual video could not be signed',
        name: 'hikaru.massage',
        error: error,
        stackTrace: stackTrace,
      );
      return massageVideoPublicUrl(storagePath);
    }
  }
}

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

final massageVideoSourceProvider = Provider<MassageVideoSource>(
  (ref) => MassageVideoSource(),
);
