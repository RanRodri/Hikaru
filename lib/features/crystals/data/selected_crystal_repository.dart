import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/crystal.dart';

part 'selected_crystal_repository.g.dart';

class SelectedCrystalRepository {
  SelectedCrystalRepository(this._preferences);

  static const String _key = 'selected_crystal';

  final SharedPreferencesAsync _preferences;

  Future<Crystal?> read() async =>
      Crystal.fromName(await _preferences.getString(_key));

  Future<void> save(Crystal crystal) =>
      _preferences.setString(_key, crystal.name);
}

@Riverpod(keepAlive: true)
SelectedCrystalRepository selectedCrystalRepository(Ref ref) =>
    SelectedCrystalRepository(SharedPreferencesAsync());
