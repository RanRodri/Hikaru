import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/crystals/application/selected_crystal_controller.dart';
import 'package:hikaru/features/crystals/data/selected_crystal_repository.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('starts without a crystal and remembers the chosen one', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(selectedCrystalProvider.future), isNull);

    await container.read(selectedCrystalProvider.notifier).select(Crystal.jade);

    expect(container.read(selectedCrystalProvider).value, Crystal.jade);
    expect(
      await SelectedCrystalRepository(SharedPreferencesAsync()).read(),
      Crystal.jade,
    );
  });

  test('ignores unknown stored values', () {
    expect(Crystal.fromName('amethyst'), isNull);
    expect(Crystal.fromName('redJasper'), Crystal.redJasper);
  });
}
