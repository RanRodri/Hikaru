import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/user_profile_gateway.dart';
import '../data/auth_gateway.dart';
import '../data/biometric_login.dart';
import '../data/device_biometric_login.dart';

/// Whether the login screen can offer the sensor on this phone.
class BiometricLoginOffer {
  const BiometricLoginOffer({
    this.kind = BiometricKind.none,
    this.enrolled = false,
  });

  static const BiometricLoginOffer hidden = BiometricLoginOffer();

  final BiometricKind kind;
  final bool enrolled;

  bool get showButton => enrolled && kind != BiometricKind.none;
}

final biometricLoginControllerProvider =
    AsyncNotifierProvider<BiometricLoginController, BiometricLoginOffer>(
      BiometricLoginController.new,
    );

/// Face ID or fingerprint for a password already saved on this phone.
class BiometricLoginController extends AsyncNotifier<BiometricLoginOffer> {
  @override
  Future<BiometricLoginOffer> build() async {
    final kind = await ref.watch(biometricGateProvider).available();
    final saved = await ref.watch(biometricSecretStoreProvider).read();
    if (kind == BiometricKind.none || saved == null) {
      return BiometricLoginOffer.hidden;
    }
    return BiometricLoginOffer(kind: kind, enrolled: true);
  }

  /// Signs in with the keychain copy after the phone confirms the sensor.
  Future<bool> signIn({required String reason}) async {
    final gate = ref.read(biometricGateProvider);
    final store = ref.read(biometricSecretStoreProvider);
    final confirmed = await gate.authenticate(reason: reason);
    if (!confirmed) return false;
    final saved = await store.read();
    if (saved == null) return false;
    await ref
        .read(authGatewayProvider)
        .signIn(username: saved.username, password: saved.password);
    return true;
  }

  /// Kind to offer after a password login, or null when no question is due.
  ///
  /// A different account replaces the saved copy. The same account keeps the
  /// new password without asking again.
  Future<BiometricKind?> promptKind(String username) async {
    final gate = ref.read(biometricGateProvider);
    final store = ref.read(biometricSecretStoreProvider);
    final kind = await gate.available();
    final saved = await store.read();
    if (saved != null && saved.username != username) {
      await store.clear();
      await ref.read(userProfileGatewayProvider).saveBiometrics(false);
    } else if (saved != null) {
      return null;
    }
    if (kind == BiometricKind.none) return null;
    if (await store.wasDeclined(username)) return null;
    return kind;
  }

  Future<void> keepPassword({
    required String username,
    required String password,
  }) async {
    final store = ref.read(biometricSecretStoreProvider);
    final saved = await store.read();
    if (saved == null || saved.username != username) return;
    await store.write(
      BiometricCredentials(username: username, password: password),
    );
  }

  Future<bool> enable({
    required String username,
    required String password,
    required String reason,
  }) async {
    final gate = ref.read(biometricGateProvider);
    final confirmed = await gate.authenticate(reason: reason);
    if (!confirmed) return false;
    await ref
        .read(biometricSecretStoreProvider)
        .write(BiometricCredentials(username: username, password: password));
    await ref.read(userProfileGatewayProvider).saveBiometrics(true);
    final kind = await gate.available();
    state = AsyncData(BiometricLoginOffer(kind: kind, enrolled: true));
    return true;
  }

  Future<void> decline(String username) =>
      ref.read(biometricSecretStoreProvider).decline(username);

  Future<void> clear() async {
    await ref.read(biometricSecretStoreProvider).clear();
    state = const AsyncData(BiometricLoginOffer.hidden);
  }
}
