import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

/// Sensor the login button can offer on this phone.
enum BiometricKind { none, face, touch, fingerprint }

/// Username and password kept in the device keychain.
class BiometricCredentials {
  const BiometricCredentials({required this.username, required this.password});

  final String username;
  final String password;
}

/// Asks the operating system for the sensor and for a confirmation.
abstract class BiometricGate {
  Future<BiometricKind> available();

  Future<bool> authenticate({required String reason});
}

/// Local copy of the credentials, plus who declined the offer.
abstract class BiometricSecretStore {
  Future<BiometricCredentials?> read();

  Future<void> write(BiometricCredentials credentials);

  Future<void> clear();

  Future<bool> wasDeclined(String username);

  Future<void> decline(String username);
}

/// Preference record used when the secure plugin is unavailable.
class MemoryBiometricSecretStore implements BiometricSecretStore {
  BiometricCredentials? credentials;
  final Set<String> declined = {};

  @override
  Future<void> clear() async => credentials = null;

  @override
  Future<void> decline(String username) async {
    declined.add(username);
  }

  @override
  Future<BiometricCredentials?> read() async => credentials;

  @override
  Future<bool> wasDeclined(String username) async =>
      declined.contains(username);

  @override
  Future<void> write(BiometricCredentials credentials) async {
    this.credentials = credentials;
  }
}

/// Declines stored in preferences. Credentials live in the platform store.
class PreferenceDeclineStore implements BiometricSecretStore {
  PreferenceDeclineStore(this._inner, {SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String declinedKey = 'hikaru_biometric_declined';

  final BiometricSecretStore _inner;
  final SharedPreferencesAsync _preferences;

  @override
  Future<void> clear() => _inner.clear();

  @override
  Future<BiometricCredentials?> read() => _inner.read();

  @override
  Future<void> write(BiometricCredentials credentials) =>
      _inner.write(credentials);

  @override
  Future<bool> wasDeclined(String username) async {
    try {
      final raw = await _preferences.getString(declinedKey);
      if (raw == null || raw.isEmpty) return false;
      final decoded = jsonDecode(raw);
      return decoded is List && decoded.contains(username);
    } catch (error, stackTrace) {
      _report(error, stackTrace);
      return false;
    }
  }

  @override
  Future<void> decline(String username) async {
    try {
      final raw = await _preferences.getString(declinedKey);
      final names = <String>{};
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) names.addAll(decoded.whereType<String>());
      }
      names.add(username);
      await _preferences.setString(declinedKey, jsonEncode(names.toList()));
    } catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  void _report(Object error, StackTrace stackTrace) {
    log(
      'Biometric decline',
      name: 'hikaru.auth',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
