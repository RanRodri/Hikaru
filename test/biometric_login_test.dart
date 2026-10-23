import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/auth/application/biometric_login_controller.dart';
import 'package:hikaru/features/auth/data/auth_gateway.dart';
import 'package:hikaru/features/auth/data/biometric_login.dart';
import 'package:hikaru/features/auth/data/device_biometric_login.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/profile/data/user_profile_gateway.dart';

void main() {
  test('no sensor never asks and never shows the button', () async {
    final harness = _Harness(kind: BiometricKind.none);

    expect(await harness.prompt('ada'), isNull);
    expect((await harness.offer()).showButton, isFalse);
  });

  test('face on a new phone asks once', () async {
    final harness = _Harness(kind: BiometricKind.face);

    expect(await harness.prompt('ada'), BiometricKind.face);
  });

  test('not now is remembered for that username', () async {
    final harness = _Harness(kind: BiometricKind.fingerprint);

    expect(await harness.prompt('ada'), BiometricKind.fingerprint);
    await harness.controller.decline('ada');

    expect(await harness.prompt('ada'), isNull);
    expect(await harness.prompt('bea'), BiometricKind.fingerprint);
  });

  test('accept stores the password and marks the profile', () async {
    final harness = _Harness(kind: BiometricKind.fingerprint);

    final enabled = await harness.controller.enable(
      username: 'ada',
      password: 'Secret1!',
      reason: 'confirm',
    );

    expect(enabled, isTrue);
    expect(harness.gate.reasons, ['confirm']);
    expect(harness.store.credentials?.username, 'ada');
    expect(harness.store.credentials?.password, 'Secret1!');
    expect(harness.profile.biometrics, isTrue);
    expect((await harness.offer()).showButton, isTrue);
    expect((await harness.offer()).kind, BiometricKind.fingerprint);
  });

  test('a different account replaces the saved copy', () async {
    final harness = _Harness(kind: BiometricKind.face);
    await harness.store.write(
      const BiometricCredentials(username: 'ada', password: 'Secret1!'),
    );
    harness.profile.biometrics = true;

    expect(await harness.prompt('bea'), BiometricKind.face);
    expect(harness.store.credentials, isNull);
    expect(harness.profile.biometrics, isFalse);
  });

  test('the same account updates the password without asking', () async {
    final harness = _Harness(kind: BiometricKind.face);
    await harness.store.write(
      const BiometricCredentials(username: 'ada', password: 'Secret1!'),
    );

    expect(await harness.prompt('ada'), isNull);
    await harness.controller.keepPassword(
      username: 'ada',
      password: 'Secret2!',
    );

    expect(harness.store.credentials?.password, 'Secret2!');
    expect(await harness.prompt('ada'), isNull);
  });

  test('clear removes the secret', () async {
    final harness = _Harness(kind: BiometricKind.fingerprint);
    await harness.store.write(
      const BiometricCredentials(username: 'ada', password: 'Secret1!'),
    );

    await harness.controller.clear();

    expect(harness.store.credentials, isNull);
    expect((await harness.offer()).showButton, isFalse);
  });

  test('the button signs in with the saved password', () async {
    final harness = _Harness(kind: BiometricKind.fingerprint);
    await harness.store.write(
      const BiometricCredentials(username: 'ada', password: 'Secret1!'),
    );

    final signedIn = await harness.controller.signIn(reason: 'open');

    expect(signedIn, isTrue);
    expect(harness.auth.username, 'ada');
    expect(harness.auth.password, 'Secret1!');
  });
}

class _Harness {
  _Harness({required BiometricKind kind})
    : gate = _Gate(kind),
      store = MemoryBiometricSecretStore(),
      profile = _ProfileGateway(),
      auth = _AuthGateway() {
    container = ProviderContainer(
      overrides: [
        biometricGateProvider.overrideWithValue(gate),
        biometricSecretStoreProvider.overrideWithValue(store),
        userProfileGatewayProvider.overrideWithValue(profile),
        authGatewayProvider.overrideWithValue(auth),
      ],
    );
  }

  late final ProviderContainer container;
  final _Gate gate;
  final MemoryBiometricSecretStore store;
  final _ProfileGateway profile;
  final _AuthGateway auth;

  BiometricLoginController get controller =>
      container.read(biometricLoginControllerProvider.notifier);

  Future<BiometricKind?> prompt(String username) =>
      controller.promptKind(username);

  Future<BiometricLoginOffer> offer() =>
      container.read(biometricLoginControllerProvider.future);
}

class _Gate implements BiometricGate {
  _Gate(this.kind);

  final BiometricKind kind;
  final List<String> reasons = [];

  @override
  Future<bool> authenticate({required String reason}) async {
    reasons.add(reason);
    return true;
  }

  @override
  Future<BiometricKind> available() async => kind;
}

class _ProfileGateway implements UserProfileGateway {
  bool? biometrics;

  @override
  Future<RemoteUserProfile?> fetchCurrent() async => null;

  @override
  Future<void> saveBiometrics(bool enabled) async => biometrics = enabled;

  @override
  Future<void> saveFullName(String fullName) async {}

  @override
  Future<void> saveReminders({
    required bool morning,
    required bool evening,
  }) async {}

  @override
  Future<void> saveSelectedCrystal(Crystal crystal) async {}
}

class _AuthGateway implements AuthGateway {
  String? username;
  String? password;

  @override
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    this.username = username;
    this.password = password;
  }

  @override
  Future<void> confirmPasswordReset({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {}

  @override
  Future<void> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {}

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<void> requestPasswordReset({required String username}) async {}

  @override
  Future<AuthSignUpOutcome> signUp({
    required String username,
    required String password,
    required String email,
    required String name,
    String? birthdate,
  }) async => AuthSignUpOutcome.signedIn;
}
