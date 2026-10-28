import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/core/media/remote_image.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/resonance_chamber/data/cymatic_headphones_prompts.dart';
import 'package:hikaru/features/resonance_chamber/presentation/crystal_resonance_screen.dart';
import 'package:hikaru/features/resonance_chamber/presentation/crystal_temple_pages.dart';
import 'package:hikaru/features/resonance_chamber/presentation/cymatic_signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:hikaru/l10n/app_localizations.dart';

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

  testWidgets('play opens the headphones note, then a rotatable cymatic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpCrystal(tester);

    expect(_remoteImage('jade.png'), findsOneWidget);
    expect(find.bySemanticsLabel('JADE crystal'), findsOneWidget);
    expect(find.textContaining('immersive experience'), findsNothing);
    expect(find.bySemanticsLabel('Cymatic'), findsNothing);
    expect(find.bySemanticsLabel('Exit'), findsNothing);

    await tester.ensureVisible(find.text('ENTER THE FREQUENCY'));
    await tester.tap(find.text('ENTER THE FREQUENCY'));
    await tester.pumpAndSettle();

    expect(find.text('AWAKEN YOUR SENSES'), findsOneWidget);
    expect(find.text('ACTIVATE MY FREQUENCY'), findsOneWidget);
    expect(find.text('CONTINUE WITHOUT HEADPHONES'), findsNothing);
    expect(find.byIcon(Icons.headphones_outlined), findsOneWidget);
    expect(find.bySemanticsLabel('Cymatic'), findsNothing);

    await tester.tap(find.text('ACTIVATE MY FREQUENCY'));
    await _pumpUntil(tester, find.bySemanticsLabel('Cymatic'));

    expect(find.text('AWAKEN YOUR SENSES'), findsNothing);
    await tester.pump(const Duration(milliseconds: 800));
    expect(_remoteImage('jade.png'), findsNothing);
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
    expect(find.bySemanticsLabel('Stop'), findsOneWidget);
    expect(_assetImage('assets/images/merkaba_starry_night.jpg'), findsNothing);
    expect(orientations.last, [
      'DeviceOrientation.portraitUp',
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);

    expect(tester.getSize(find.byType(CymaticSignature)), const Size(390, 844));
    expect(
      tester.widget<CymaticSignature>(find.byType(CymaticSignature)).style,
      CymaticStyle.kaleidoscope,
    );
    expect(
      await SharedPreferencesAsync().getInt(
        CymaticHeadphonesPrompts.storageKey,
      ),
      1,
    );

    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();

    expect(tester.getSize(find.byType(CymaticSignature)), const Size(844, 390));

    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    expect(find.bySemanticsLabel('Play'), findsOneWidget);
    expect(find.bySemanticsLabel('Cymatic'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Stop'));
    tester.view.physicalSize = const Size(390, 844);
    await _pumpUntil(tester, find.text('RETURN TO COHERENCE'));

    expect(find.bySemanticsLabel('Cymatic'), findsNothing);
    expect(find.text('Carry this moment of harmony with you.'), findsOneWidget);
    expect(find.text('COMPLETE MY RITUAL'), findsOneWidget);
    expect(orientations.last, ['DeviceOrientation.portraitUp']);
  });

  testWidgets('the headphones note still reminds after earlier confirms', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await SharedPreferencesAsync().setInt(
      CymaticHeadphonesPrompts.storageKey,
      CymaticHeadphonesPrompts.showLimit,
    );
    await _pumpCrystal(tester);

    await tester.ensureVisible(find.text('ENTER THE FREQUENCY'));
    await tester.tap(find.text('ENTER THE FREQUENCY'));
    await tester.pumpAndSettle();

    expect(find.text('ACTIVATE MY FREQUENCY'), findsOneWidget);
    expect(find.text('CONTINUE WITHOUT HEADPHONES'), findsNothing);
    expect(find.byIcon(Icons.headphones_outlined), findsOneWidget);
    expect(find.bySemanticsLabel('Cymatic'), findsNothing);
  });

  testWidgets(
    'the temple keeps only the short entry and a skippable tutorial',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: AppRoutes.crystalResonanceFor('jade'),
        routes: [
          GoRoute(
            path: AppRoutes.crystalResonance,
            builder: (context, state) =>
                const CrystalResonanceScreen(crystal: Crystal.jade),
          ),
          GoRoute(
            path: AppRoutes.libraryTopic,
            builder: (context, state) =>
                Text('library:${state.pathParameters['topic']}'),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Text('sanctuary'),
          ),
          GoRoute(
            path: AppRoutes.fourTemples,
            builder: (context, state) => const Text('four temples'),
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
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('JADE'), findsOneWidget);
      expect(find.text('Temple of Harmony'), findsOneWidget);
      expect(find.text('528 Hz'), findsOneWidget);
      expect(
        find.text('Awaken your senses. Enter the resonance.'),
        findsOneWidget,
      );
      expect(find.text('LEARN YOUR CRYSTAL RITUAL'), findsOneWidget);
      expect(find.text('ENTER THE FREQUENCY'), findsOneWidget);
      expect(find.textContaining('Therapeutic'), findsNothing);
      expect(find.textContaining('Illuminated'), findsNothing);
      expect(find.textContaining('nervous system'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Open the crystal library'));
      await tester.pumpAndSettle();
      expect(find.text('library:jade'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('LEARN YOUR CRYSTAL RITUAL'));
      await tester.pump();
      await tester.pump();

      expect(find.text(crystalTutorialAsset(Crystal.jade)), findsOneWidget);
      expect(
        find.text('Your crystal ritual is ready. Now enter the frequency.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Pause tutorial'), findsOneWidget);
      expect(find.bySemanticsLabel('Repeat tutorial'), findsOneWidget);

      await tester.tap(find.text('CONTINUE TO RESONANCE'));
      await tester.pumpAndSettle();
      expect(find.text('ACTIVATE MY FREQUENCY'), findsOneWidget);

      await tester.tap(find.text('ACTIVATE MY FREQUENCY'));
      await _pumpUntil(tester, find.bySemanticsLabel('Cymatic'));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.bySemanticsLabel('Watch the tutorial again'));
      await tester.pump();
      await tester.pump();
      expect(find.bySemanticsLabel('Cymatic'), findsNothing);
      expect(find.text('CONTINUE TO RESONANCE'), findsOneWidget);

      await tester.tap(find.text('CONTINUE TO RESONANCE'));
      await _pumpUntil(tester, find.bySemanticsLabel('Cymatic'));
      expect(find.text('AWAKEN YOUR SENSES'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Stop'));
      await _pumpUntil(tester, find.text('COMPLETE MY RITUAL'));
      expect(
        find.text('Carry this moment of harmony with you.'),
        findsOneWidget,
      );

      await tester.tap(find.text('EXPLORE ANOTHER TEMPLE'));
      await tester.pumpAndSettle();
      expect(find.text('four temples'), findsOneWidget);

      router.go(AppRoutes.crystalResonanceFor('jade'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ENTER THE FREQUENCY'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ACTIVATE MY FREQUENCY'));
      await _pumpUntil(tester, find.bySemanticsLabel('Cymatic'));
      await tester.tap(find.bySemanticsLabel('Stop'));
      await _pumpUntil(tester, find.text('COMPLETE MY RITUAL'));
      await tester.tap(find.text('COMPLETE MY RITUAL'));
      await tester.pumpAndSettle();
      expect(find.text('sanctuary'), findsOneWidget);
    },
  );
}

Future<void> _pumpCrystal(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CrystalResonanceScreen(crystal: Crystal.jade),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 20; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

Finder _remoteImage(String fileName) => find.byWidgetPredicate(
  (widget) => widget is RemoteImage && widget.fileName == fileName,
);

Finder _assetImage(String asset) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == asset,
);
