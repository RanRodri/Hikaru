import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers when the member last used the app, so a session left untouched
/// for [limit] can be closed.
///
/// Cognito only knows a fixed refresh-token lifetime, not inactivity, so the
/// idle time is measured here. The timestamp is refreshed on every sign-in,
/// every launch and return to the foreground, and whenever the app goes to
/// the background.
class SessionInactivity {
  SessionInactivity({
    SharedPreferencesAsync? preferences,
    DateTime Function()? clock,
    this.limit = defaultLimit,
  }) : _preferences = preferences ?? SharedPreferencesAsync(),
       _clock = clock ?? DateTime.now;

  static const Duration defaultLimit = Duration(hours: 48);
  static const String lastActiveKey = 'hikaru_last_active_ms';

  final SharedPreferencesAsync _preferences;
  final DateTime Function() _clock;
  final Duration limit;

  /// Marks "now" as the last moment the member used the app.
  Future<void> touch() =>
      _preferences.setInt(lastActiveKey, _clock().millisecondsSinceEpoch);

  Future<void> clear() => _preferences.remove(lastActiveKey);

  /// True when more than [limit] passed since the last [touch].
  ///
  /// Without a record (first run after this feature shipped, or after a
  /// sign-out) the session is not expired: the clock starts on the next touch.
  Future<bool> hasExpired() async {
    final stored = await _preferences.getInt(lastActiveKey);
    if (stored == null) return false;
    final lastActive = DateTime.fromMillisecondsSinceEpoch(stored);
    return _clock().difference(lastActive) > limit;
  }
}

final sessionInactivityProvider = Provider<SessionInactivity>(
  (ref) => SessionInactivity(),
);
