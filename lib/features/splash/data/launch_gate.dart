import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_routes.dart';

/// What follows the splash: the intro once, then login, the questions, or home.
///
/// A signed-in member reaches home only after the quiz assigns a crystal and
/// they have seen that reveal.
String routeAfterSplash({
  required bool introSeen,
  required bool sessionOpen,
  required bool crystalAssigned,
  required bool crystalRevealed,
}) {
  if (!introSeen) return AppRoutes.sanctuary;
  if (!sessionOpen) return AppRoutes.login;
  return routeForMember(
    crystalAssigned: crystalAssigned,
    crystalRevealed: crystalRevealed,
  );
}

/// Listening Room until the crystal exists, the reveal until they enter, then home.
String routeForMember({
  required bool crystalAssigned,
  required bool crystalRevealed,
}) {
  if (!crystalAssigned) return AppRoutes.listeningRoom;
  if (!crystalRevealed) return AppRoutes.resonanceChamber;
  return AppRoutes.home;
}

/// Remembers the first opening and whether a sign-in is still open.
class LaunchGate {
  LaunchGate(this._preferences);

  static const String introSeenKey = 'hikaru_intro_seen';
  static const String sessionOpenKey = 'hikaru_session_open';
  static const String crystalRevealedKey = 'hikaru_crystal_revealed';

  final SharedPreferencesAsync _preferences;

  Future<bool> introSeen() async =>
      await _preferences.getBool(introSeenKey) ?? false;

  Future<void> markIntroSeen() => _preferences.setBool(introSeenKey, true);

  Future<bool> sessionOpen() async =>
      await _preferences.getBool(sessionOpenKey) ?? false;

  Future<void> openSession() => _preferences.setBool(sessionOpenKey, true);

  Future<bool> crystalRevealed() async =>
      await _preferences.getBool(crystalRevealedKey) ?? false;

  Future<void> markCrystalRevealed() =>
      _preferences.setBool(crystalRevealedKey, true);
}
