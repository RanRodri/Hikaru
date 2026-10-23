import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profile/data/user_profile_gateway.dart';
import '../data/selected_crystal_repository.dart';
import '../domain/crystal.dart';

part 'selected_crystal_controller.g.dart';

/// Crystal the member chose in the Four Temples.
///
/// The local copy answers immediately; the backend `User.actualCrystalCode`
/// wins when it exists, so a new device shows the same crystal.
@Riverpod(keepAlive: true)
class SelectedCrystal extends _$SelectedCrystal {
  @override
  Future<Crystal?> build() async {
    final repository = ref.watch(selectedCrystalRepositoryProvider);
    final local = await repository.read();
    final remote = await ref.watch(userProfileGatewayProvider).fetchCurrent();
    final synced = remote?.selectedCrystal;
    if (synced == null) return local;
    if (synced != local) await repository.save(synced);
    return synced;
  }

  Future<void> select(Crystal crystal) async {
    // Let a pending build land first so it cannot overwrite the choice.
    await future;
    await ref.read(selectedCrystalRepositoryProvider).save(crystal);
    state = AsyncData(crystal);
    await ref.read(userProfileGatewayProvider).saveSelectedCrystal(crystal);
  }
}
