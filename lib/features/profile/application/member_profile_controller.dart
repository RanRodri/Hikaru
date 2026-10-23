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
/// The name comes from the backend `User.fullName` when a session exists and
/// is cached locally. The portrait stays on the device for now.
class MemberProfileController extends AsyncNotifier<MemberProfile> {
  @override
  Future<MemberProfile> build() async {
    final repository = ref.watch(memberProfileRepositoryProvider);
    final local = await repository.read();
    final remote = await ref.watch(userProfileGatewayProvider).fetchCurrent();
    final remoteName = remote?.fullName.trim();
    if (remoteName == null || remoteName.isEmpty || remoteName == local.name) {
      return local;
    }
    await repository.save(name: remoteName);
    return MemberProfile(name: remoteName, photo: local.photo);
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
