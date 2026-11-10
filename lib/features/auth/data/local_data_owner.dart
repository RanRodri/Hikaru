import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backend/amplify_graphql.dart';

/// Remembers whose progress the phone holds.
///
/// When a session expires the local data is kept, so nothing done offline is
/// lost. If a different account then signs in, that data must not be sent
/// to it: the owner tells the two cases apart.
class LocalDataOwner {
  LocalDataOwner([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String ownerKey = 'hikaru_local_data_owner';

  final SharedPreferencesAsync _preferences;

  Future<String?> read() => _preferences.getString(ownerKey);

  Future<void> save(String userId) => _preferences.setString(ownerKey, userId);

  Future<void> clear() => _preferences.remove(ownerKey);
}

final localDataOwnerProvider = Provider<LocalDataOwner>(
  (ref) => LocalDataOwner(),
);

/// Cognito `sub` of the member signed in now, `null` without a session.
final currentMemberIdProvider = Provider<Future<String?> Function()>(
  (ref) => const AmplifyGraphQL('auth').currentUserId,
);
