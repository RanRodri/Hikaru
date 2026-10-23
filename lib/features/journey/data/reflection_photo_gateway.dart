import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/amplify_graphql.dart';
import '../domain/reflection_photo.dart';

/// A `ReflectionPhoto` row. [storageKey] is the S3 path, not a cipher key.
class RemoteReflection {
  const RemoteReflection({
    required this.id,
    required this.dayNumber,
    required this.storageKey,
  });

  final String id;
  final int dayNumber;
  final String storageKey;
}

/// Uploads a face photo and records its private S3 path.
///
/// The bucket encrypts the object with the customer-managed KMS key. This
/// gateway does not encrypt the bytes and does not store the signed URL.
abstract class ReflectionPhotoGateway {
  Future<List<RemoteReflection>> fetchCycle(String cycleId);

  /// Uploads [bytes] and returns the stored S3 path, or null without a session.
  Future<String?> upload({
    required String cycleId,
    required int dayNumber,
    required Uint8List bytes,
  });

  Future<bool> create({
    required String id,
    required String cycleId,
    required int dayNumber,
    required String storageKey,
    required DateTime uploadedAt,
  });

  Future<bool> update({
    required String id,
    required String storageKey,
    required DateTime uploadedAt,
  });

  Future<Uint8List?> download(String storageKey);
}

final reflectionPhotoGatewayProvider = Provider<ReflectionPhotoGateway>(
  (ref) => AmplifyReflectionPhotoGateway(),
);

class AmplifyReflectionPhotoGateway implements ReflectionPhotoGateway {
  static const AmplifyGraphQL _api = AmplifyGraphQL('reflection');

  static const String _listPhotos =
      r'query ListPhotos($cycleId: ID!, $nextToken: String) { '
      r'listReflectionPhotos('
      r'filter: {cycleId: {eq: $cycleId}}, limit: 100, nextToken: $nextToken'
      r') { items { id dayNumber s3EncryptedKey } nextToken } }';

  static const String _createPhoto =
      r'mutation CreatePhoto($input: CreateReflectionPhotoInput!) { '
      r'createReflectionPhoto(input: $input) { id } }';

  static const String _updatePhoto =
      r'mutation UpdatePhoto($input: UpdateReflectionPhotoInput!) { '
      r'updateReflectionPhoto(input: $input) { id } }';

  @override
  Future<List<RemoteReflection>> fetchCycle(String cycleId) async {
    if (await _api.currentUserId() == null) return const [];
    final rows = await listAllPages(_api, _listPhotos, 'listReflectionPhotos', {
      'cycleId': cycleId,
    });
    return rows.map(_fromRow).nonNulls.toList();
  }

  @override
  Future<String?> upload({
    required String cycleId,
    required int dayNumber,
    required Uint8List bytes,
  }) async {
    if (!Amplify.isConfigured) return null;
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) return null;
      final objectName = reflectionObjectName(cycleId, dayNumber, bytes);
      final result = await Amplify.Storage.uploadData(
        data: StorageDataPayload.bytes(
          bytes,
          contentType: reflectionContentType(bytes),
        ),
        path: StoragePath.fromIdentityId(
          (identityId) => 'reflection-photos/$identityId/$objectName',
        ),
      ).result;
      return result.uploadedItem.path;
    } on AmplifyException catch (error) {
      safePrint('Hikaru reflection: ${error.message}');
      return null;
    }
  }

  @override
  Future<bool> create({
    required String id,
    required String cycleId,
    required int dayNumber,
    required String storageKey,
    required DateTime uploadedAt,
  }) async {
    final userId = await _api.currentUserId();
    if (userId == null) return false;
    final data = await _api.mutate(_createPhoto, {
      'input': {
        'id': id,
        'userId': userId,
        'cycleId': cycleId,
        'dayNumber': dayNumber,
        's3EncryptedKey': storageKey,
        'uploadedAt': uploadedAt.toUtc().toIso8601String(),
      },
    });
    return data?['createReflectionPhoto'] != null;
  }

  @override
  Future<bool> update({
    required String id,
    required String storageKey,
    required DateTime uploadedAt,
  }) async {
    if (await _api.currentUserId() == null) return false;
    final data = await _api.mutate(_updatePhoto, {
      'input': {
        'id': id,
        's3EncryptedKey': storageKey,
        'uploadedAt': uploadedAt.toUtc().toIso8601String(),
      },
    });
    return data?['updateReflectionPhoto'] != null;
  }

  @override
  Future<Uint8List?> download(String storageKey) async {
    if (!Amplify.isConfigured || storageKey.isEmpty) return null;
    try {
      final result = await Amplify.Storage.downloadData(
        path: StoragePath.fromString(storageKey),
      ).result;
      final bytes = result.bytes;
      if (bytes.isEmpty) return null;
      return Uint8List.fromList(bytes);
    } on AmplifyException catch (error) {
      safePrint('Hikaru reflection: ${error.message}');
      return null;
    }
  }

  RemoteReflection? _fromRow(Map<String, dynamic> row) {
    final id = row['id'];
    final dayNumber = row['dayNumber'];
    final storageKey = row['s3EncryptedKey'];
    if (id is! String || dayNumber is! int || storageKey is! String) {
      return null;
    }
    return RemoteReflection(
      id: id,
      dayNumber: dayNumber,
      storageKey: storageKey,
    );
  }
}
