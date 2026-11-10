import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/member_profile_repository.dart';
import '../data/user_profile_gateway.dart';

final memberProfileRepositoryProvider = Provider<MemberProfileRepository>(
  (ref) => MemberProfileRepository(SharedPreferencesAsync()),
);

final memberProfileControllerProvider =
    AsyncNotifierProvider<MemberProfileController, MemberProfile>(
      MemberProfileController.new,
    );

/// Member name and portrait.
///
/// The name is the first real one of, in order:
/// 1. the backend `User.fullName`;
/// 2. a name the member typed on this phone;
/// 3. the Cognito `name` attribute filled at sign-up;
/// 4. the part of the Cognito email before the `@`.
/// Only with none of them does the placeholder show. A name found in Cognito
/// is also written to `User.fullName`, so the backend catches up.
/// The portrait stays on the device for now.
class MemberProfileController extends AsyncNotifier<MemberProfile> {
  @override
  Future<MemberProfile> build() async {
    final repository = ref.watch(memberProfileRepositoryProvider);
    final local = await repository.read();
    final remote = await ref.watch(userProfileGatewayProvider).fetchCurrent();

    final remoteName = _real(remote?.fullName);
    if (remoteName != null) return _keep(repository, local, remoteName);

    final localName = _real(local.name);
    if (localName != null) return local;

    final identity = await ref.watch(cognitoIdentityReaderProvider)();
    final cognitoName = _real(identity?.name) ?? _emailName(identity?.email);
    if (cognitoName == null) return local;
    unawaited(ref.read(userProfileGatewayProvider).saveFullName(cognitoName));
    return _keep(repository, local, cognitoName);
  }

  Future<MemberProfile> _keep(
    MemberProfileRepository repository,
    MemberProfile local,
    String name,
  ) async {
    if (name != local.name) await repository.save(name: name);
    return MemberProfile(name: name, photo: local.photo);
  }

  /// A trimmed name, or null when empty or still the placeholder.
  static String? _real(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (MemberProfile.isPlaceholder(trimmed)) return null;
    return trimmed;
  }

  /// `camila.v@mail.com` → `Camila V`.
  static String? _emailName(String? email) {
    final local = email?.split('@').first.trim();
    if (local == null || local.isEmpty) return null;
    final words = local
        .split(RegExp(r'[._\-+]+'))
        .where((word) => word.isNotEmpty && !RegExp(r'^\d+$').hasMatch(word))
        .map((word) => word[0].toUpperCase() + word.substring(1));
    final name = words.join(' ');
    return name.isEmpty ? null : name;
  }

  Future<void> save({required String name, Uint8List? photo}) async {
    // Let a pending build land first so it cannot overwrite the save.
    await future;
    final repository = ref.read(memberProfileRepositoryProvider);
    await repository.save(name: name, photo: photo);
    final saved = await repository.read();
    state = AsyncData(saved);
    await ref.read(userProfileGatewayProvider).saveFullName(saved.name);
  }
}
