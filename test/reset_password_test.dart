import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/auth/data/auth_gateway.dart';
import 'package:hikaru/features/auth/data/biometric_login.dart';
import 'package:hikaru/features/auth/data/device_biometric_login.dart';
import 'package:hikaru/features/auth/presentation/reset_password_screen.dart';
import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  testWidgets('reset emails a code, then confirms the new password', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = _ResetAuthGateway();
    final secrets = MemoryBiometricSecretStore()
      ..credentials = const BiometricCredentials(
        username: 'ada',
        password: 'Secret1!',
      );
    final router = GoRouter(
      initialLocation: AppRoutes.resetPassword,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Text('LOGIN READY'),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (context, state) => const ResetPasswordScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(auth),
          biometricGateProvider.overrideWithValue(_ResetBiometricGate()),
          biometricSecretStoreProvider.overrideWithValue(secrets),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'ada@example.com');
    await tester.tap(find.text('SEND CODE'));
    await tester.pumpAndSettle();

    expect(auth.requested, 'ada@example.com');
    expect(find.text('We sent a code to your email.'), findsOneWidget);
    expect(find.text('Verification code'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '123456');
    await tester.enterText(fields.at(2), 'Secret1!');
    await tester.enterText(fields.at(3), 'Secret1!');
    await tester.ensureVisible(find.text('RESET PASSWORD'));
    await tester.tap(find.text('RESET PASSWORD'));
    await tester.pumpAndSettle();

    expect(auth.confirmedUsername, 'ada@example.com');
    expect(auth.confirmedCode, '123456');
    expect(auth.confirmedPassword, 'Secret1!');
    expect(secrets.credentials, isNull);
    expect(find.text('LOGIN READY'), findsOneWidget);
  });
}

class _ResetBiometricGate implements BiometricGate {
  @override
  Future<bool> authenticate({required String reason}) async => false;

  @override
  Future<BiometricKind> available() async => BiometricKind.none;
}

class _ResetAuthGateway implements AuthGateway {
  String? requested;
  String? confirmedUsername;
  String? confirmedCode;
  String? confirmedPassword;

  @override
  Future<void> confirmPasswordReset({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    confirmedUsername = username;
    confirmedCode = confirmationCode;
    confirmedPassword = newPassword;
  }

  @override
  Future<void> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {}

  @override
  Future<bool> hasSession() async => false;

  @override
  Future<void> requestPasswordReset({required String username}) async {
    requested = username;
  }

  @override
  Future<void> signIn({
    required String username,
    required String password,
  }) async {}

  @override
  Future<AuthSignUpOutcome> signUp({
    required String username,
    required String password,
    required String email,
    required String name,
    String? birthdate,
  }) async => AuthSignUpOutcome.signedIn;
}
