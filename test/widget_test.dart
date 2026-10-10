import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:hiraku/app.dart';
import 'package:hiraku/core/design_system/tokens/app_colors.dart';
import 'package:hiraku/core/design_system/widgets/radial_glow_background.dart';
import 'package:hiraku/features/sanctuary/presentation/sanctuary_screen.dart';
import 'package:hiraku/features/splash/presentation/splash_controller.dart';
import 'package:hiraku/features/splash/presentation/splash_screen.dart';

import 'support/quiz_driver.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Shows the splash and then the sanctuary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HikaruApp()));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.bySemanticsLabel('Hikaru Lift'), findsOneWidget);
    expect(find.byType(RadialGlowBackground), findsNothing);
    expect(
      tester
          .widget<Scaffold>(
            find.descendant(
              of: find.byType(SplashScreen),
              matching: find.byType(Scaffold),
            ),
          )
          .backgroundColor,
      AppColors.darkIndigoBlue,
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
    expect(find.text('RESET PASSWORD'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'ada@hikaru.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.ensureVisible(find.text('SIGN IN'));
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    expect(find.text('The\nListening Room'), findsOneWidget);
    expect(find.text('BEGIN'), findsOneWidget);

    await tester.ensureVisible(find.text('BEGIN'));
    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();

    expect(find.text('01 / 10'), findsOneWidget);
    expect(
      find.text('What would you like to see reflected in the mirror today?'),
      findsOneWidget,
    );
    expect(find.text('NEXT'), findsOneWidget);

    const quizAnswers = [
      'Reduce puffiness',
      'Comfortable and balanced',
      'In the morning',
      'Jaw',
      'Jawline',
      'Calm',
      'Deeply relaxed',
      'Harmony',
      '5 minutes',
      'Today is my very first ritual',
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

    expect(find.text('THE RESONANCE CHAMBER'), findsOneWidget);
    expect(find.bySemanticsLabel('Assigned crystal JADE'), findsOneWidget);
    expect(find.text('THE ALIGNMENT TRIAD'), findsOneWidget);
    expect(find.text('ENTER MY 30-DAY JOURNEY'), findsOneWidget);

    await tester.ensureVisible(find.text('ENTER MY 30-DAY JOURNEY'));
    await tester.tap(find.text('ENTER MY 30-DAY JOURNEY'));
    await tester.pumpAndSettle();

    expect(find.text('Harmony Garden'), findsOneWidget);
    expect(find.bySemanticsLabel('Listening Sanctuary, JADE'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
