import 'package:shared_preferences/shared_preferences.dart';

import '../../crystals/domain/crystal.dart';

/// Remembers which crystal tutorials the user has actually watched.
///
/// A tutorial is only marked as watched after a real video reaches its end.
/// The placeholder never marks it.
class CrystalTutorialProgress {
  const CrystalTutorialProgress(this._preferences);

  final SharedPreferencesAsync _preferences;

  static String storageKeyFor(Crystal crystal) =>
      'crystal_tutorial_watched_${crystal.name}';

  Future<bool> hasWatched(Crystal crystal) async =>
      await _preferences.getBool(storageKeyFor(crystal)) ?? false;

  Future<void> markWatched(Crystal crystal) =>
      _preferences.setBool(storageKeyFor(crystal), true);
}
