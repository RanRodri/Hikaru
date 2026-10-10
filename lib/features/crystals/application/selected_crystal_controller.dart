import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/selected_crystal_repository.dart';
import '../domain/crystal.dart';

part 'selected_crystal_controller.g.dart';

@Riverpod(keepAlive: true)
class SelectedCrystal extends _$SelectedCrystal {
  @override
  Future<Crystal?> build() =>
      ref.watch(selectedCrystalRepositoryProvider).read();

  Future<void> select(Crystal crystal) async {
    await ref.read(selectedCrystalRepositoryProvider).save(crystal);
    state = AsyncData(crystal);
  }
}
