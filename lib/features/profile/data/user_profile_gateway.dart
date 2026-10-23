import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/amplify_graphql.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/domain/crystal_code.dart';

/// The signed-in member's `User` row as the backend stores it.
class RemoteUserProfile {
  const RemoteUserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.selectedCrystal,
    required this.morningRitualReminder,
    required this.eveningReflectionReminder,
    required this.biometricsEnabled,
  });

  final String id;
  final String email;
  final String fullName;
  final Crystal? selectedCrystal;
  final bool morningRitualReminder;
  final bool eveningReflectionReminder;
  final bool biometricsEnabled;

  static RemoteUserProfile? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final email = json['email'];
    final fullName = json['fullName'];
    if (id is! String || email is! String || fullName is! String) return null;
    return RemoteUserProfile(
      id: id,
      email: email,
      fullName: fullName,
      selectedCrystal: CrystalCode.fromBackendCode(
        json['actualCrystalCode'] as String?,
      ),
      morningRitualReminder: json['morningSacredRitualEnabled'] == true,
      eveningReflectionReminder: json['eveningReflectionAndBreath'] == true,
      biometricsEnabled: json['biometricsEnabled'] == true,
    );
  }
}

/// Reads and updates the member's profile in AppSync.
///
/// Every call is safe to make without a session or without Amplify configured:
/// reads return `null` and writes do nothing, so the app keeps working from
/// its local cache.
abstract class UserProfileGateway {
  Future<RemoteUserProfile?> fetchCurrent();

  Future<void> saveSelectedCrystal(Crystal crystal);

  Future<void> saveFullName(String fullName);

  Future<void> saveReminders({required bool morning, required bool evening});

  Future<void> saveBiometrics(bool enabled);
}

final userProfileGatewayProvider = Provider<UserProfileGateway>(
  (ref) => AmplifyUserProfileGateway(),
);

class AmplifyUserProfileGateway implements UserProfileGateway {
  static const AmplifyGraphQL _api = AmplifyGraphQL('profile');

  static const String _profileFields =
      'id email fullName actualCrystalCode morningSacredRitualEnabled '
      'eveningReflectionAndBreath biometricsEnabled';

  static const String _getUser =
      r'query GetUser($id: ID!) { getUser(id: $id) { '
      '$_profileFields } }';

  static const String _updateUser =
      r'mutation UpdateUser($input: UpdateUserInput!) { '
      r'updateUser(input: $input) { '
      '$_profileFields } }';

  @override
  Future<RemoteUserProfile?> fetchCurrent() async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;
    final data = await _api.query(_getUser, {'id': userId});
    return RemoteUserProfile.fromJson(data?['getUser']);
  }

  @override
  Future<void> saveSelectedCrystal(Crystal crystal) =>
      _update({'actualCrystalCode': crystal.backendCode});

  @override
  Future<void> saveFullName(String fullName) => _update({'fullName': fullName});

  @override
  Future<void> saveReminders({required bool morning, required bool evening}) =>
      _update({
        'morningSacredRitualEnabled': morning,
        'eveningReflectionAndBreath': evening,
      });

  @override
  Future<void> saveBiometrics(bool enabled) =>
      _update({'biometricsEnabled': enabled});

  Future<void> _update(Map<String, Object?> changes) async {
    final userId = await _api.currentUserId();
    if (userId == null) return;
    await _api.mutate(_updateUser, {
      'input': {'id': userId, ...changes},
    });
  }
}
