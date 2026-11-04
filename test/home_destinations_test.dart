import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/features/crystals/application/selected_crystal_controller.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/four_temples/presentation/four_temples_screen.dart';
import 'package:hikaru/features/harmony_garden/data/home_crystal_glow.dart';
import 'package:hikaru/features/harmony_garden/presentation/harmony_garden_screen.dart';
import 'package:hikaru/l10n/app_localizations_en.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hikaru/features/library/domain/library_article.dart';
import 'package:hikaru/features/library/presentation/library_detail_screen.dart';
import 'package:hikaru/features/library/presentation/library_screen.dart';
import 'package:hikaru/features/massage/domain/massage_ritual.dart';
import 'package:hikaru/features/massage/presentation/massage_screen.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:hikaru/l10n/app_localizations.dart';

double _sheetTop(WidgetTester tester) =>
    tester.getTopLeft(find.bySemanticsLabel('Ritual sheet')).dy;

double _crystalOpacity(WidgetTester tester) {
  final crystal = find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == Crystal.jade.imageAsset,
  );
  final opacity = tester.widget<Opacity>(
    find.ancestor(of: crystal, matching: find.byType(Opacity)).first,
  );
  return opacity.opacity;
}

Finder _ritualLotus() {
  return find.byWidgetPredicate((widget) {
    if (widget is! SvgPicture) return false;
    final loader = widget.bytesLoader;
    return loader is SvgAssetLoader &&
        loader.assetName == 'assets/images/ritual_lotus.svg';
  });
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<GoRouter> pumpGarden(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HarmonyGardenScreen(),
          routes: [
            GoRoute(
              path: 'merkaba',
              builder: (context, state) => const MerkabaMeditationScreen(),
            ),
            GoRoute(
              path: 'ritual-face',
              builder: (context, state) =>
                  const MassageScreen(surface: MassageSurface.face),
            ),
            GoRoute(
              path: 'ritual-body',
              builder: (context, state) =>
                  const MassageScreen(surface: MassageSurface.body),
            ),
            GoRoute(
              path: 'four-temples',
              builder: (context, state) => const FourTemplesScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.library,
          builder: (context, state) => const LibraryScreen(),
          routes: [
            GoRoute(
              path: ':topic',
              builder: (context, state) => LibraryDetailScreen(
                article: libraryArticleFor(state.pathParameters['topic'])!,
              ),
            ),
          ],
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
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('Merkaba opens from the garden, plays, and returns', (
    tester,
  ) async {
    await pumpGarden(tester);

    await tester.tap(find.bySemanticsLabel('Merkaba'));
    await tester.pumpAndSettle();

    expect(find.text('Human Blueprint'), findsOneWidget);
    expect(find.text('Gyan Mudra'), findsOneWidget);
    expect(find.text('Inhale'), findsOneWidget);
    expect(find.text('00:00 / 05:00'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('00:00 / 05:00'), findsNothing);

    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    final paused = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && (widget.data?.contains('/ 05:00') ?? false),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(paused.data!), findsOneWidget);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
  });

  testWidgets('facial and body rituals open with timer, pressure, and zones', (
    tester,
  ) async {
    await pumpGarden(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HarmonyGardenScreen)),
    );
    await container.read(selectedCrystalProvider.notifier).select(Crystal.jade);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Hikaru Ritual Face'));
    await tester.pumpAndSettle();
    expect(find.text('THE FACE TEMPLE'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Ritual video')), findsOneWidget);
    expect(find.text('01 / 05'), findsOneWidget);
    expect(find.text('3 MIN'), findsOneWidget);
    expect(find.text('5 MIN'), findsOneWidget);
    expect(find.text('10 MIN'), findsOneWidget);
    expect(find.text(faceRitual.zones.first.instruction), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('MERIDIAN'), findsNothing);
    expect(find.bySemanticsLabel('Assigned crystal JADE'), findsOneWidget);
    expect(_ritualLotus(), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == Crystal.jade.imageAsset,
      ),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('00:00'), findsNothing);
    expect(_sheetTop(tester), greaterThan(800));
    expect(_crystalOpacity(tester), 0);

    await tester.tap(find.bySemanticsLabel(RegExp('Pause ritual video')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(_sheetTop(tester), inInclusiveRange(300, 520));
    expect(tester.getBottomLeft(find.text('RESTART')).dy, lessThan(844));
    expect(_crystalOpacity(tester), 1);
    final pausedClock = find.textContaining(RegExp(r'^00:0[1-9]$'));
    expect(pausedClock, findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Play ritual video')), findsOneWidget);

    await tester.tapAt(const Offset(195, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(_sheetTop(tester), greaterThan(800));
    expect(
      find.bySemanticsLabel(RegExp('^Pause ritual video')),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(195, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(_sheetTop(tester), inInclusiveRange(300, 520));
    expect(find.bySemanticsLabel(RegExp('^Play ritual video')), findsOneWidget);
    await tester.tap(find.text('RESTART'));
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('PRESSURE'), findsNothing);
    expect(find.text('INHALE'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_bottom_outlined), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Next zone'));
    await tester.pump();
    expect(find.text('02 / 05'), findsOneWidget);
    expect(find.text(faceRitual.zones[1].instruction), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Forehead'));
    await tester.pump();
    expect(find.text('05 / 05'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(_sheetTop(tester), greaterThan(800));
    expect(_crystalOpacity(tester), 0);
    expect(find.bySemanticsLabel(RegExp('Ritual video')), findsOneWidget);

    await tester.drag(
      find.bySemanticsLabel('Ritual sheet'),
      const Offset(0, -500),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(_crystalOpacity(tester), 1);
    expect(find.text('00:00'), findsNothing);
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.bySemanticsLabel('Ritual sheet'),
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();
    expect(_sheetTop(tester), greaterThan(800));
    expect(_crystalOpacity(tester), 0);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Hikaru Ritual Body'));
    await tester.pumpAndSettle();
    expect(find.text('THE BODY TEMPLE'), findsOneWidget);
    expect(find.text('01 / 04'), findsOneWidget);
    expect(find.text('GLUTES'), findsWidgets);
    expect(bodyRitual.zones.map((zone) => zone.name), [
      'Glutes',
      'Legs',
      'Abdomen',
      'Chest',
    ]);
    expect(find.bySemanticsLabel('Assigned crystal JADE'), findsOneWidget);
    expect(find.text('INHALE'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_bottom_outlined), findsOneWidget);
    expect(find.text('PRESSURE'), findsNothing);

    await tester.fling(
      find.bySemanticsLabel('Ritual sheet'),
      const Offset(0, 160),
      800,
    );
    await tester.pumpAndSettle();
    expect(_sheetTop(tester), greaterThan(800));
    expect(_crystalOpacity(tester), closeTo(0, 0.001));
    expect(find.bySemanticsLabel(RegExp('Ritual video')), findsOneWidget);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
  });

  testWidgets('library circles open a detail page and back returns', (
    tester,
  ) async {
    final router = await pumpGarden(tester);
    router.go(AppRoutes.library);
    await tester.pumpAndSettle();

    final merkabaName = tester.widget<Text>(find.text('MERKABA'));
    expect(merkabaName.style?.fontSize, greaterThanOrEqualTo(8));
    expect(find.text('Geometry & Energy'), findsNothing);

    Future<void> openTopic(String label, String heading) async {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      expect(find.textContaining(heading), findsWidgets);
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('LIBRARY'), findsOneWidget);
    }

    await openTopic('MERKABA, Geometry & Energy', 'BREATHING 4 - 4 - 6');
    await openTopic('JADE, Balance & Harmony', 'Temple of Harmony');
    await openTopic(
      'WHITE QUARTZ, Clarity & Renewal',
      'Temple of Illumination',
    );
    await openTopic('RED JASPER, Vitality & Grounding', 'Temple of Vitality');
    await openTopic(
      'OBSIDIAN, Protection & Transformation',
      'Temple of Transformation',
    );
    await openTopic('HIKARU RITUALS, Face & Body', 'Light, Moderate, Firm');

    await tester.tap(find.bySemanticsLabel('JADE, Balance & Harmony'));
    await tester.pumpAndSettle();
    expect(find.text('CRYSTAL GUIDE'), findsOneWidget);
    expect(find.text('528 Hz'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Go to chapter 2, Purpose'));
    await tester.pumpAndSettle();
    expect(find.text('CHAPTER 02'), findsOneWidget);

    final intentionTile = find.bySemanticsLabel('Open chapter 7, Intention');
    await tester.ensureVisible(intentionTile);
    await tester.tap(intentionTile);
    await tester.pumpAndSettle();
    expect(find.text('CHAPTER 07'), findsOneWidget);
    expect(find.text('Harmony, Self-Love, Renewal'), findsOneWidget);

    await tester.ensureVisible(find.bySemanticsLabel('Show all chapters'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Show all chapters'));
    await tester.pumpAndSettle();
    expect(find.text('CHAPTER 01'), findsOneWidget);

    await tester.ensureVisible(
      find.bySemanticsLabel('Next in library, WHITE QUARTZ, Clarity & Renewal'),
    );
    await tester.tap(
      find.bySemanticsLabel('Next in library, WHITE QUARTZ, Clarity & Renewal'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Temple of Illumination'), findsWidgets);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('LIBRARY'), findsOneWidget);
  });


  group('home layout', () {
    Offset captionCenter(WidgetTester tester, String text) =>
        tester.getCenter(find.text(text));

    testWidgets('five identical circles run clockwise, numbered 1 to 5', (
      tester,
    ) async {
      await pumpGarden(tester);
      final l10n = AppLocalizationsEn();

      // Captions carry the step numbers, in clockwise order.
      final labels = [
        '1\nMERKABA',
        '2\n${l10n.homeRitualFace}',
        '3\n${l10n.homeRitualBody}',
        '4\n${l10n.homeYourCrystal}',
        '5\n${l10n.homeLibrary}',
      ];
      for (final label in labels) {
        expect(find.text(label), findsOneWidget, reason: label);
      }

      // Same size for every circle, Merkaba included.
      const size = Size(homeCircleDiameter, homeCircleDiameter);
      expect(tester.getSize(find.bySemanticsLabel('Merkaba')), size);
      expect(tester.getSize(find.bySemanticsLabel('Hikaru Ritual Face')), size);
      expect(tester.getSize(find.bySemanticsLabel('Hikaru Ritual Body')), size);
      expect(tester.getSize(find.bySemanticsLabel('Your crystal')), size);

      // Captions sit at the same offset inside every circle, so their centers
      // give the circle positions relative to each other.
      final merkaba = tester.getCenter(find.bySemanticsLabel('Merkaba'));
      final face = tester.getCenter(find.bySemanticsLabel('Hikaru Ritual Face'));
      final body = tester.getCenter(find.bySemanticsLabel('Hikaru Ritual Body'));
      final crystal = tester.getCenter(find.bySemanticsLabel('Your crystal'));
      final captionShift =
          captionCenter(tester, labels[1]) - face; // caption → circle center
      final library = captionCenter(tester, labels[4]) - captionShift;

      final orbit = Offset(merkaba.dx, merkaba.dy + 138);
      double degrees(Offset point) =>
          (math.atan2(point.dy - orbit.dy, point.dx - orbit.dx) * 180 / math.pi +
              360) %
          360;
      expect(degrees(merkaba), closeTo(270, 1));
      expect(degrees(face), closeTo(335, 1));
      expect(degrees(body), closeTo(25, 1));
      expect(degrees(crystal), closeTo(155, 1));
      expect(degrees(library), closeTo(205, 1));
      for (final point in [face, body, crystal, library]) {
        expect((point - orbit).distance, closeTo(138, 1));
      }
    });

    for (final screen in const [
      Size(390, 844),
      Size(360, 640),
      Size(430, 932),
    ]) {
      testWidgets(
        'Merkaba stays above her head at ${screen.width.toInt()}x${screen.height.toInt()}',
        (tester) async {
          await pumpGarden(tester, size: screen);

          final backgroundScale = math.max(
            screen.width / 1024,
            screen.height / 1536,
          );
          final backgroundTop = (screen.height - 1536 * backgroundScale) / 2;
          final headTop = backgroundTop + 1536 * backgroundScale * 0.31;
          expect(
            tester.getBottomLeft(find.bySemanticsLabel('Merkaba')).dy,
            lessThan(headTop),
          );
          expect(
            tester.getCenter(find.bySemanticsLabel('Merkaba')).dx,
            closeTo(screen.width / 2, 0.5),
          );
        },
      );
    }

    testWidgets('without a crystal the slot still shows step 4', (
      tester,
    ) async {
      await pumpGarden(tester);
      expect(find.text('4\nYOUR CRYSTAL'), findsOneWidget);
    });
  });

  testWidgets('the crystal circle shows the selected crystal and opens the '
      'Four Temples map', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await SharedPreferencesAsync().setBool(HomeCrystalGlow.seenKey, true);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(selectedCrystalProvider.notifier).select(Crystal.jade);

    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HarmonyGardenScreen(),
          routes: [
            GoRoute(
              path: 'four-temples',
              builder: (context, state) => const FourTemplesScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final face = tester.getSize(find.bySemanticsLabel('Hikaru Ritual Face'));
    expect(tester.getSize(find.bySemanticsLabel('Your crystal JADE')), face);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/library_jade.png',
      ),
      findsOneWidget,
    );
    expect(find.text('4\nJADE'), findsOneWidget);
    expect(find.text('RED JASPER'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Your crystal JADE'));
    await tester.pumpAndSettle();
    expect(find.byType(FourTemplesScreen), findsOneWidget);
  });

  group('first-visit crystal glow', () {
    /// A halo with spread is only drawn by the first-visit pulse.
    Finder halo() => find.descendant(
      of: find.byType(HarmonyGardenScreen),
      matching: find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            (decoration.boxShadow ?? const []).any(
              (shadow) => shadow.spreadRadius > 0,
            );
      }),
    );

    Future<void> assignJade(WidgetTester tester) async {
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HarmonyGardenScreen)),
      );
      await container
          .read(selectedCrystalProvider.notifier)
          .select(Crystal.jade);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('glows on the first visit after the reveal', (tester) async {
      await pumpGarden(tester);
      await assignJade(tester);
      expect(halo(), findsOneWidget);
    });

    testWidgets('does not glow when the crystal has not been assigned', (
      tester,
    ) async {
      await pumpGarden(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(halo(), findsNothing);
    });

    testWidgets('does not glow once it was seen', (tester) async {
      await SharedPreferencesAsync().setBool(HomeCrystalGlow.seenKey, true);
      await pumpGarden(tester);
      await assignJade(tester);
      expect(halo(), findsNothing);
    });

    testWidgets('tapping the circle ends it and remembers it', (tester) async {
      await pumpGarden(tester);
      await assignJade(tester);
      expect(halo(), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Your crystal JADE'));
      await tester.pumpAndSettle();

      expect(await SharedPreferencesAsync().getBool(HomeCrystalGlow.seenKey),
          isTrue);
    });

    testWidgets('leaving Home ends it and remembers it', (tester) async {
      final router = await pumpGarden(tester);
      await assignJade(tester);
      expect(await SharedPreferencesAsync().getBool(HomeCrystalGlow.seenKey),
          isNull);

      router.go(AppRoutes.library);
      await tester.pumpAndSettle();

      expect(await SharedPreferencesAsync().getBool(HomeCrystalGlow.seenKey),
          isTrue);
    });
  });
}
