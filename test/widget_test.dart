import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:hikaru/app.dart';
import 'package:hikaru/features/auth/data/auth_gateway.dart';
import 'package:hikaru/features/auth/data/biometric_login.dart';
import 'package:hikaru/features/auth/data/device_biometric_login.dart';
import 'package:hikaru/core/design_system/widgets/radial_glow_background.dart';
import 'package:hikaru/features/sanctuary/presentation/sanctuary_screen.dart';
import 'package:hikaru/features/splash/presentation/splash_controller.dart';
import 'package:hikaru/features/splash/presentation/splash_screen.dart';

import 'support/quiz_driver.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'hikaru_home_tour_seen': true,
        });
  });

  testWidgets('Shows the splash and then the sanctuary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(_WidgetAuthGateway()),
          biometricGateProvider.overrideWithValue(_WidgetBiometricGate()),
          biometricSecretStoreProvider.overrideWithValue(
            MemoryBiometricSecretStore(),
          ),
        ],
        child: const HikaruApp(),
      ),
    );
    // The animated WebP does not finish decoding inside the fake async zone.
    // Open the gate the logo opens once its first frame is ready.
    final ready = ProviderScope.containerOf(
      tester.element(find.byType(SplashScreen)),
    ).read(splashSymbolReadyProvider);
    if (!ready.isCompleted) ready.complete();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.bySemanticsLabel('Hikaru Lift'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SplashScreen),
        matching: find.byType(RadialGlowBackground),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(splashMinimumDuration - const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(SanctuaryScreen), findsOneWidget);
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('HIKARU SANCTUARY'), findsOneWidget);
    expect(find.text('ENTER THE SANCTUARY'), findsOneWidget);

    await tester.tap(find.text('ENTER THE SANCTUARY'));
    await tester.pumpAndSettle();

    expect(find.byType(SanctuaryScreen), findsNothing);
    expect(find.text('THE DISCOVERY ROOM'), findsOneWidget);
    expect(find.text('Your Journey\nBegins With You'), findsOneWidget);
    expect(find.text('BEGIN MY DISCOVERY'), findsOneWidget);

    await tester.ensureVisible(find.text('BEGIN MY DISCOVERY'));
    await tester.tap(find.text('BEGIN MY DISCOVERY'));
    await tester.pumpAndSettle();

    expect(find.text('Your Sanctuary Is\nAlmost Ready'), findsOneWidget);
    expect(find.text('CHOOSE YOUR PATH'), findsOneWidget);
    expect(find.text('DISCOVER HIKARU'), findsOneWidget);
    expect(find.text('BEGIN MY RITUAL'), findsOneWidget);

    await tester.ensureVisible(find.text('BEGIN MY RITUAL'));
    await tester.tap(find.text('BEGIN MY RITUAL'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Home'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);

    await tester.ensureVisible(find.text('Create one'));
    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();

    expect(find.text('Create Your\nSanctuary'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);

    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Home'), findsOneWidget);

    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Your\nPassword'), findsOneWidget);
    expect(find.text('SEND CODE'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'ada@hikaru.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.ensureVisible(find.text('SIGN IN'));
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    expect(find.text('The\nListening Room'), findsOneWidget);
    expect(
      find.text(
        "Share what's on your mind\n"
        'so we can guide you with a\n'
        'personalized ritual for your skin,\n'
        'your body, and your energy.',
      ),
      findsOneWidget,
    );
    expect(find.text('LISTEN   ·   ALIGN   ·   RECEIVE'), findsNothing);
    expect(find.text('BEGIN'), findsOneWidget);

    await tester.ensureVisible(find.text('BEGIN'));
    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();

    expect(find.text('01 / 10'), findsOneWidget);
    expect(find.text('What is your skin asking for today?'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);

    const quizAnswers = [
      'Calm and comfort',
      'Sensitive or easily irritated',
      'Emotionally overwhelmed',
      'Stress and emotional pressure',
      'Signs of stress or tension',
      'Gentleness and balance',
      'Return to harmony',
      'Calm and nurtured',
      '5 minutes',
      'None of the above',
    ];
    for (final answer in quizAnswers) {
      await tapQuizChoice(tester, answer);
      await tapQuizNext(tester);
    }

    expect(find.text('Your\nRitual Is Ready'), findsOneWidget);
    expect(find.text('ENTER YOUR RITUAL'), findsOneWidget);

    await tester.ensureVisible(find.text('ENTER YOUR RITUAL'));
    await tester.tap(find.text('ENTER YOUR RITUAL'));
    await tester.pumpAndSettle();

    expect(find.text('THE MIRROR GARDEN'), findsOneWidget);
    expect(
      find.text('Add A Photo Of Your Face For Personal Tracking'),
      findsOneWidget,
    );
    expect(find.text('CONTINUE'), findsOneWidget);

    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR HIKARU JOURNEY'), findsOneWidget);
    expect(find.text('HAS BEEN REVEALED'), findsOneWidget);
    expect(find.bySemanticsLabel('Assigned crystal JADE'), findsOneWidget);
    expect(find.text('YOUR RECOMMENDED PROTOCOL'), findsOneWidget);
    expect(find.text('ENTER MY HIKARU SANCTUARY'), findsOneWidget);

    await tester.ensureVisible(find.text('ENTER MY HIKARU SANCTUARY'));
    await tester.tap(find.text('ENTER MY HIKARU SANCTUARY'));
    await tester.pumpAndSettle();

    expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
    expect(find.bySemanticsLabel('Your crystal JADE'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}

class _WidgetBiometricGate implements BiometricGate {
  @override
  Future<bool> authenticate({required String reason}) async => false;

  @override
  Future<BiometricKind> available() async => BiometricKind.none;
}

class _WidgetAuthGateway implements AuthGateway {
  @override
  Future<void> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {}

  @override
  Future<bool> hasSession() async => false;

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

  @override
  Future<void> requestPasswordReset({required String username}) async {}

  @override
  Future<void> confirmPasswordReset({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {}
}
