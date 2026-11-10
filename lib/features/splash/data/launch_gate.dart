import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_routes.dart';

/// What follows the splash: the intro once, then login, the questions, or home.
///
/// A signed-in member reaches home only after the quiz assigns a crystal and
/// the account's `User.isRevealedCrystal` is true. That flag is not stored
/// on the phone.
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

/// Home once this account has seen the crystal, even if the phone does not
/// have the recommendation yet. Otherwise the questions, then the reveal.
String routeForMember({
  required bool crystalAssigned,
  required bool crystalRevealed,
}) {
  if (crystalRevealed) return AppRoutes.home;
  if (!crystalAssigned) return AppRoutes.listeningRoom;
  return AppRoutes.resonanceChamber;
}

/// Remembers the first opening and whether a sign-in is still open.
class LaunchGate {
  LaunchGate(this._preferences);

  static const String introSeenKey = 'hikaru_intro_seen';
  static const String sessionOpenKey = 'hikaru_session_open';

  /// Previous on-device reveal flag. Sign-out deletes it; the account flag
  /// `User.isRevealedCrystal` decides the questionnaire and the reveal now.
  static const String legacyCrystalRevealedKey = 'hikaru_crystal_revealed';

  final SharedPreferencesAsync _preferences;

  Future<bool> introSeen() async =>
      await _preferences.getBool(introSeenKey) ?? false;

  Future<void> markIntroSeen() => _preferences.setBool(introSeenKey, true);

  Future<bool> sessionOpen() async =>
      await _preferences.getBool(sessionOpenKey) ?? false;

  Future<void> openSession() => _preferences.setBool(sessionOpenKey, true);
}
