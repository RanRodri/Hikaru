import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/crystals/presentation/crystal_texts.dart';
import 'package:hikaru/features/resonance_chamber/data/crystal_tutorial_progress.dart';
import 'package:hikaru/features/resonance_chamber/data/cymatic_headphones_prompts.dart';
import 'package:hikaru/features/resonance_chamber/presentation/crystal_resonance_screen.dart';
import 'package:hikaru/features/resonance_chamber/presentation/cymatic_signature.dart';
import 'package:hikaru/l10n/app_localizations.dart';
import 'package:hikaru/l10n/app_localizations_en.dart';
import 'package:hikaru/l10n/app_localizations_es.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String _starryNight = 'assets/images/merkaba_starry_night.jpg';

void main() {
  late List<List<String>> orientations;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    orientations = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            orientations.add([
              for (final value in call.arguments as List<Object?>)
                value.toString(),
            ]);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('start → reminder → headphones → cymatic → Stop → closing', (
    tester,
  ) async {
    _phone(tester);
    await _pumpCrystal(tester);

    expect(find.text('THE RESONANCE CHAMBER'), findsNothing);
    expect(find.text('JADE'), findsOneWidget);
    expect(find.text('VIDEO TUTORIAL'), findsOneWidget);
    expect(find.text('START YOUR FREQUENCY'), findsOneWidget);
    expect(find.text('YOUR CRYSTAL'), findsOneWidget);
    expect(find.text('CHOOSE THIS CRYSTAL'), findsOneWidget);
    // Frequency info, with the real track length from the bundled envelope.
    expect(find.text('YOUR FREQUENCY  ·  4:32'), findsOneWidget);
    expect(find.text('528 Hz'), findsOneWidget);
    expect(find.text('Heart coherence, love & balance'), findsOneWidget);
    // One image: the crystal photo with its cymatic aura.
    expect(find.byType(CymaticSignature), findsOneWidget);

    await tester.tap(find.text('START YOUR FREQUENCY'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Have you watched the video tutorial?'),
        findsOneWidget);
    expect(find.text('WATCH TUTORIAL'), findsOneWidget);

    await tester.tap(find.text('CONTINUE TO RESONANCE'));
    await tester.pumpAndSettle();
    expect(find.text('AWAKEN YOUR SENSES'), findsOneWidget);
    expect(
      find.text('Put on your headphones and let the frequency surround you.'),
      findsOneWidget,
    );
    expect(find.text('CONTINUE WITHOUT HEADPHONES'), findsOneWidget);
    expect(find.byIcon(Icons.headphones_outlined), findsOneWidget);

    await tester.tap(find.text('ACTIVATE MY FREQUENCY'));
    await _pumpUntil(tester, find.bySemanticsLabel('Cymatic'));
    await tester.pump(const Duration(milliseconds: 1200));

    expect(_assetImage(_starryNight), findsOneWidget);
    expect(find.text('JADE'), findsNothing);
    expect(find.text('${Crystal.jade.hertz} Hz'), findsNothing);
    expect(find.bySemanticsLabel('Pause'), findsNothing);
    expect(find.bySemanticsLabel('Stop'), findsNothing);
    expect(tester.getSize(find.byType(CymaticSignature)), const Size(390, 844));
    expect(orientations.last, [
      'DeviceOrientation.portraitUp',
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);
    expect(
      await SharedPreferencesAsync().getInt(
        CymaticHeadphonesPrompts.storageKey,
      ),
      1,
    );

    await tester.tap(find.bySemanticsLabel('Cymatic'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
    expect(find.bySemanticsLabel('Stop'), findsOneWidget);
    expect(find.bySemanticsLabel('Exit'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    expect(find.bySemanticsLabel('Play'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Stop'));
    await _pumpUntil(tester, find.text('RETURN TO COHERENCE'));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Carry this moment of harmony with you'), findsOneWidget);
    expect(find.text('COMPLETE MY RITUAL'), findsOneWidget);
    expect(find.text('EXPLORE ANOTHER TEMPLE'), findsOneWidget);
    expect(find.text('Discover this crystal in the Library'), findsOneWidget);
    expect(find.bySemanticsLabel('Cymatic'), findsNothing);
    expect(orientations.last, ['DeviceOrientation.portraitUp']);

    // Back from the closing screen returns to the crystal.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('START YOUR FREQUENCY'), findsOneWidget);
  });

  testWidgets('(a) a watched tutorial skips the reminder', (tester) async {
    _phone(tester);
    await _watchTutorial(Crystal.jade);
    await _pumpCrystal(tester);

    await tester.tap(find.text('START YOUR FREQUENCY'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Have you watched'), findsNothing);
    expect(find.text('ACTIVATE MY FREQUENCY'), findsOneWidget);
  });

  testWidgets('(b) without a video the tutorial shows the placeholder and '
      'never marks itself watched', (tester) async {
    _phone(tester);
    await _pumpCrystal(tester);

    await tester.tap(find.text('VIDEO TUTORIAL'));
    await _pumpUntil(tester, find.text('Tutorial video coming soon'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    expect(find.text('CONTINUE TO RESONANCE'), findsOneWidget);

    await tester.tap(find.text('CONTINUE TO RESONANCE'));
    await tester.pumpAndSettle();

    // Straight to the headphones note: no reminder after the tutorial.
    expect(find.textContaining('Have you watched'), findsNothing);
    expect(find.text('ACTIVATE MY FREQUENCY'), findsOneWidget);
    expect(
      await CrystalTutorialProgress(
        SharedPreferencesAsync(),
      ).hasWatched(Crystal.jade),
      isFalse,
    );
  });

  testWidgets('(b) closing the placeholder returns to the crystal', (
    tester,
  ) async {
    _phone(tester);
    await _pumpCrystal(tester);

    await tester.tap(find.text('VIDEO TUTORIAL'));
    await _pumpUntil(tester, find.bySemanticsLabel('Close'));
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('START YOUR FREQUENCY'), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('es')]) {
    for (final crystal in Crystal.values) {
      testWidgets(
        '(c) ${crystal.name} fits 360x640 at text x1.3 in ${locale.languageCode}',
        (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await _pumpCrystal(
            tester,
            crystal: crystal,
            locale: locale,
            textScaler: const TextScaler.linear(1.3),
          );
          await tester.pump(const Duration(milliseconds: 600));
          expect(tester.takeException(), isNull);

          final l10n = locale.languageCode == 'es'
              ? AppLocalizationsEs()
              : AppLocalizationsEn();
          // Every action stays on screen.
          for (final label in [
            l10n.crystalTutorialButton,
            l10n.crystalStartFrequencyButton,
            l10n.crystalYourCrystalLibraryButton,
          ]) {
            expect(
              tester.getBottomLeft(find.text(label)).dy,
              lessThanOrEqualTo(640),
              reason: label,
            );
          }

          await tester.tap(find.text(l10n.crystalStartFrequencyButton));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(l10n.crystalContinueToResonance));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text(l10n.headphonesDialogReady), findsOneWidget);
        },
      );
    }
  }

  testWidgets('(d) YOUR CRYSTAL opens the crystal in the Library', (
    tester,
  ) async {
    _phone(tester);
    final router = GoRouter(
      initialLocation: AppRoutes.crystalResonanceFor(Crystal.jade.name),
      routes: [
        GoRoute(
          path: AppRoutes.crystalResonance,
          builder: (context, state) =>
              const CrystalResonanceScreen(crystal: Crystal.jade),
        ),
        GoRoute(
          path: AppRoutes.libraryTopic,
          builder: (context, state) => const Scaffold(body: Text('TOPIC')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('YOUR CRYSTAL'));
    await tester.pumpAndSettle();

    expect(find.text('TOPIC'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.libraryTopicFor(Crystal.jade.name),
    );
  });

  testWidgets('(e) the crystal screen keeps only the essentials', (
    tester,
  ) async {
    _phone(tester);
    await _pumpCrystal(tester);
    final l10n = AppLocalizationsEn();

    for (final hidden in [
      Crystal.jade.localizedPurpose(l10n),
      Crystal.jade.localizedMeridians(l10n),
      Crystal.jade.localizedEnvironment(l10n),
      Crystal.jade.localizedSkinBenefit(l10n),
      'THERAPEUTIC PURPOSE',
      'ILLUMINATED MERIDIANS',
      'VISUAL ENVIRONMENT',
      'SKIN BENEFIT',
    ]) {
      expect(find.text(hidden), findsNothing, reason: hidden);
    }
    expect(find.textContaining('20 min'), findsNothing);
    expect(find.textContaining('Alfano'), findsNothing);
  });
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _watchTutorial(Crystal crystal) =>
    CrystalTutorialProgress(SharedPreferencesAsync()).markWatched(crystal);

Future<void> _pumpCrystal(
  WidgetTester tester, {
  Crystal crystal = Crystal.jade,
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // The cymatic aura breathes forever; reduce motion keeps it still so
        // pumpAndSettle can settle.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: textScaler, disableAnimations: true),
          child: child!,
        ),
        home: CrystalResonanceScreen(crystal: crystal),
      ),
    ),
  );
  // Let the envelope and the track length load.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 40; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

Finder _assetImage(String asset) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == asset,
);
