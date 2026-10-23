import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_routes.dart';

/// What follows the splash: the intro once, then login or home.
String routeAfterSplash({required bool introSeen, required bool sessionOpen}) {
  if (!introSeen) return AppRoutes.sanctuary;
  if (sessionOpen) return AppRoutes.home;
  return AppRoutes.login;
}

/// Remembers the first opening and whether a sign-in is still open.
class LaunchGate {
  LaunchGate(this._preferences);

  static const String introSeenKey = 'hikaru_intro_seen';
  static const String sessionOpenKey = 'hikaru_session_open';

  final SharedPreferencesAsync _preferences;

  Future<bool> introSeen() async =>
      await _preferences.getBool(introSeenKey) ?? false;

  Future<void> markIntroSeen() => _preferences.setBool(introSeenKey, true);

  Future<bool> sessionOpen() async =>
      await _preferences.getBool(sessionOpenKey) ?? false;

  Future<void> openSession() => _preferences.setBool(sessionOpenKey, true);
}
