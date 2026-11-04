import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user has already seen the first-visit glow on Home's crystal
/// circle. The glow shows on the first Home visit after the crystal reveal and
/// stops once the user taps the circle or leaves Home.
class HomeCrystalGlow {
  const HomeCrystalGlow(this._preferences);

  static const String seenKey = 'hikaru_home_crystal_glow_seen';

  final SharedPreferencesAsync _preferences;

  Future<bool> seen() async => await _preferences.getBool(seenKey) ?? false;

  Future<void> markSeen() => _preferences.setBool(seenKey, true);
}

/// True until the first-visit glow has been seen.
final homeCrystalGlowPendingProvider = FutureProvider<bool>(
  (ref) async => !await HomeCrystalGlow(SharedPreferencesAsync()).seen(),
);
