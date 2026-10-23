import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'biometric_login.dart';

/// Reads the phone sensor. Face on iPhone, fingerprint everywhere else.
class DeviceBiometricGate implements BiometricGate {
  DeviceBiometricGate({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<BiometricKind> available() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      if (!supported && !canCheck) return BiometricKind.none;
      final types = await _auth.getAvailableBiometrics();
      if (Platform.isIOS) {
        if (types.contains(BiometricType.face)) return BiometricKind.face;
        if (types.contains(BiometricType.fingerprint)) {
          return BiometricKind.touch;
        }
        return BiometricKind.none;
      }
      if (canCheck || types.isNotEmpty) return BiometricKind.fingerprint;
      return BiometricKind.none;
    } catch (error, stackTrace) {
      _report(error, stackTrace);
      return BiometricKind.none;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (error, stackTrace) {
      _report(error, stackTrace);
      return false;
    }
  }

  void _report(Object error, StackTrace stackTrace) {
    log(
      'Biometric gate',
      name: 'hikaru.auth',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Keychain copy of the last password login on this phone.
class SecureBiometricSecretStore implements BiometricSecretStore {
  SecureBiometricSecretStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _usernameKey = 'hikaru_biometric_username';
  static const String _passwordKey = 'hikaru_biometric_password';

  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _usernameKey);
      await _storage.delete(key: _passwordKey);
    } catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  @override
  Future<void> decline(String username) async {}

  @override
  Future<BiometricCredentials?> read() async {
    try {
      final username = await _storage.read(key: _usernameKey);
      final password = await _storage.read(key: _passwordKey);
      if (username == null ||
          username.isEmpty ||
          password == null ||
          password.isEmpty) {
        return null;
      }
      return BiometricCredentials(username: username, password: password);
    } catch (error, stackTrace) {
      _report(error, stackTrace);
      return null;
    }
  }

  @override
  Future<bool> wasDeclined(String username) async => false;

  @override
  Future<void> write(BiometricCredentials credentials) async {
    await _storage.write(key: _usernameKey, value: credentials.username);
    await _storage.write(key: _passwordKey, value: credentials.password);
  }

  void _report(Object error, StackTrace stackTrace) {
    log(
      'Biometric keychain',
      name: 'hikaru.auth',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final biometricGateProvider = Provider<BiometricGate>(
  (ref) => DeviceBiometricGate(),
);

final biometricSecretStoreProvider = Provider<BiometricSecretStore>(
  (ref) => PreferenceDeclineStore(SecureBiometricSecretStore()),
);
