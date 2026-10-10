import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hiraku/core/design_system/theme/app_theme.dart';
import 'package:hiraku/core/design_system/tokens/app_colors.dart';
import 'package:hiraku/features/crystals/application/selected_crystal_controller.dart';
import 'package:hiraku/features/crystals/domain/crystal.dart';
import 'package:hiraku/core/router/app_routes.dart';
import 'package:hiraku/features/harmony_garden/presentation/harmony_garden_screen.dart';
import 'package:hiraku/features/library/domain/library_article.dart';
import 'package:hiraku/features/library/presentation/library_detail_screen.dart';
import 'package:hiraku/features/library/presentation/library_screen.dart';
import 'package:hiraku/features/massage/domain/massage_ritual.dart';
import 'package:hiraku/features/massage/presentation/massage_screen.dart';
import 'package:hiraku/features/merkaba/presentation/merkaba_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

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
    expect(find.text('Harmony Garden'), findsOneWidget);
  });

  testWidgets('facial and body rituals open with timer, pressure, and zones', (
    tester,
  ) async {
    await pumpGarden(tester);

    await tester.tap(find.bySemanticsLabel('Hikaru Ritual Face'));
    await tester.pumpAndSettle();
    expect(find.text('FACIAL'), findsOneWidget);
    expect(find.text('Gua Sha'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Moderate'), findsOneWidget);
    expect(find.text('Firm'), findsOneWidget);
    expect(
      find.text('Follow the meridian path (Stomach & Gallbladder)'),
      findsOneWidget,
    );
    expect(find.text('00:00'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('00:00'), findsNothing);
    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    await tester.tap(find.text('RESTART'));
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);

    await tester.tap(find.text('Firm'));
    await tester.pump();
    await tester.tap(find.text('NEXT'));
    await tester.pump();
    expect(find.text('Jawline'), findsWidgets);
    await tester.tap(find.text('NEXT'));
    await tester.pump();
    expect(find.text('Meridians'), findsOneWidget);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Hikaru Ritual Body'));
    await tester.pumpAndSettle();
    expect(find.text('BODY'), findsOneWidget);
    expect(find.text('Chest'), findsWidgets);
    expect(find.text('BODY RITUAL'), findsOneWidget);
    expect(find.text('Meridians'), findsOneWidget);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('Harmony Garden'), findsOneWidget);
  });

  testWidgets('library circles open a detail page and back returns', (
    tester,
  ) async {
    final router = await pumpGarden(tester);
    router.go(AppRoutes.library);
    await tester.pumpAndSettle();

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
  });

  testWidgets('merkaba and listening match the other destination circles', (
    tester,
  ) async {
    await pumpGarden(tester);

    final face = tester.getSize(find.bySemanticsLabel('Hikaru Ritual Face'));
    expect(tester.getSize(find.bySemanticsLabel('Merkaba')), face);
    expect(tester.getSize(find.bySemanticsLabel('Listening Sanctuary')), face);
    expect(find.byWidgetPredicate(_isDestinationRing), findsNWidgets(2));
  });

  testWidgets('listening circle shows the selected crystal inside the ring', (
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
    expect(
      tester.getSize(find.bySemanticsLabel('Listening Sanctuary, JADE')),
      face,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == Crystal.jade.imageAsset,
      ),
      findsOneWidget,
    );
    expect(find.byWidgetPredicate(_isDestinationRing), findsNWidgets(2));
  });
}

bool _isDestinationRing(Widget widget) {
  if (widget is! DecoratedBox) return false;
  final decoration = widget.decoration;
  if (decoration is! BoxDecoration) return false;
  final border = decoration.border;
  if (border is! Border) return false;
  return border.top.color == AppColors.champagneGold &&
      border.left.color == AppColors.champagneGold &&
      border.top.width > 1;
}
