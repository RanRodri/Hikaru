import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/features/crystals/application/selected_crystal_controller.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/harmony_garden/presentation/harmony_garden_screen.dart';
import 'package:hikaru/features/library/domain/library_article.dart';
import 'package:hikaru/features/library/presentation/library_detail_screen.dart';
import 'package:hikaru/features/library/presentation/library_screen.dart';
import 'package:hikaru/features/massage/domain/massage_ritual.dart';
import 'package:hikaru/features/massage/presentation/massage_screen.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

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

  Future<GoRouter> pumpGarden(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
        child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
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
    expect(find.text('Gyan Mudra'), findsNWidgets(2));
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
    expect(find.bySemanticsLabel('Ritual video'), findsOneWidget);
    expect(find.text('01 / 05'), findsOneWidget);
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
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
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
    await tester.drag(
      find.bySemanticsLabel('Ritual sheet'),
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.bySemanticsLabel('Ritual sheet')).dy,
      greaterThan(800),
    );
    expect(_crystalOpacity(tester), 0);
    expect(find.bySemanticsLabel('Ritual video'), findsOneWidget);

    await tester.drag(
      find.bySemanticsLabel('Ritual sheet'),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(_crystalOpacity(tester), 1);
    expect(find.text('00:00'), findsNothing);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Hikaru Ritual Body'));
    await tester.pumpAndSettle();
    expect(find.text('THE BODY TEMPLE'), findsOneWidget);
    expect(find.text('01 / 04'), findsOneWidget);
    expect(find.text('CHEST'), findsWidgets);
    expect(find.bySemanticsLabel('Assigned crystal JADE'), findsOneWidget);
    expect(find.text('INHALE'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_bottom_outlined), findsOneWidget);
    expect(find.text('PRESSURE'), findsNothing);

    await tester.drag(
      find.bySemanticsLabel('Ritual sheet'),
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.bySemanticsLabel('Ritual sheet')).dy,
      greaterThan(800),
    );
    expect(_crystalOpacity(tester), 0);
    expect(find.bySemanticsLabel('Ritual video'), findsOneWidget);

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
    final merkabaDetail = tester.widget<Text>(find.text('Geometry & Energy'));
    expect(merkabaName.style?.fontSize, greaterThanOrEqualTo(11));
    expect(merkabaDetail.style?.fontSize, greaterThanOrEqualTo(10));

    Future<void> openTopic(String label, String heading) async {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      expect(find.textContaining(heading), findsWidgets);
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('LIBRARY'), findsOneWidget);
    }

    await openTopic(
      'MERKABA, Geometry & Energy',
      'Inhale 4 seconds. Hold 4 seconds. Exhale 6 seconds.',
    );
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

  testWidgets('home accesses are equal circles in clockwise order', (
    tester,
  ) async {
    await pumpGarden(tester);

    final face = tester.getSize(find.bySemanticsLabel('Hikaru Ritual Face'));
    expect(tester.getSize(find.bySemanticsLabel('Merkaba')), face);
    expect(tester.getSize(find.bySemanticsLabel('Red Jasper')), face);
    expect(tester.getSize(find.bySemanticsLabel('Hikaru Ritual Body')), face);
    expect(face, const Size(homeCircleDiameter, homeCircleDiameter));
    expect(face.width, face.height);
    final librarySizes = [
      for (final element in tester.elementList(
        find.bySemanticsLabel('Library'),
      ))
        tester.getSize(
          find.byElementPredicate((candidate) => identical(candidate, element)),
        ),
    ];
    expect(librarySizes, contains(face));

    final merkaba = tester.getTopLeft(find.bySemanticsLabel('Merkaba'));
    expect(merkaba.dx + face.width / 2, closeTo(390 / 2, 0.5));
    final faceOrigin = tester.getTopLeft(
      find.bySemanticsLabel('Hikaru Ritual Face'),
    );
    final bodyOrigin = tester.getTopLeft(
      find.bySemanticsLabel('Hikaru Ritual Body'),
    );
    final crystal = tester.getTopLeft(find.bySemanticsLabel('Red Jasper'));
    expect(merkaba.dy, lessThan(faceOrigin.dy));
    expect(faceOrigin.dx, greaterThan(merkaba.dx));
    expect(bodyOrigin.dy, greaterThan(faceOrigin.dy));
    expect(bodyOrigin.dx, greaterThan(crystal.dx));
    expect(bodyOrigin.dx, faceOrigin.dx);
    final libraryElement = tester
        .elementList(find.bySemanticsLabel('Library'))
        .firstWhere(
          (element) =>
              tester.getSize(
                find.byElementPredicate(
                  (candidate) => identical(candidate, element),
                ),
              ) ==
              face,
        );
    final library = tester.getTopLeft(
      find.byElementPredicate(
        (candidate) => identical(candidate, libraryElement),
      ),
    );
    expect(library.dx, crystal.dx);
    expect(library.dy, faceOrigin.dy);
    expect(crystal.dy, bodyOrigin.dy);
    expect(crystal.dy, greaterThan(faceOrigin.dy));
    expect(find.text('Red Jasper'), findsOneWidget);
    expect(find.text('Listening Sanctuary'), findsNothing);
    final label = tester.widget<Text>(find.text('Red Jasper'));
    expect(label.style?.fontSize, greaterThanOrEqualTo(12));
    expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
    expect(find.text('Your Journey Begins Within'), findsOneWidget);
  });

  testWidgets('red jasper stays when another crystal is assigned', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(selectedCrystalProvider.notifier).select(Crystal.jade);

    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HarmonyGardenScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final face = tester.getSize(find.bySemanticsLabel('Hikaru Ritual Face'));
    expect(tester.getSize(find.bySemanticsLabel('Red Jasper')), face);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/library_red_jasper.png',
      ),
      findsOneWidget,
    );
    expect(find.text('JADE'), findsNothing);
    expect(find.text('Red Jasper'), findsOneWidget);
  });
}
