import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/harmony_garden/presentation/harmony_garden_screen.dart';
import 'package:hikaru/features/massage/domain/massage_ritual.dart';
import 'package:hikaru/features/massage/presentation/massage_screen.dart';
import 'package:hikaru/features/merkaba/domain/merkaba_session.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_screen.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_video.dart';
import 'package:hikaru/l10n/app_localizations.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _FailedVideo extends MerkabaVideoPlayback {
  @override
  MerkabaVideoStatus get status => MerkabaVideoStatus.failed;
  @override
  void load() {}
  @override
  Future<void> play(Duration clock) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> seek(Duration clock) async {}
  @override
  Future<void> sync(Duration clock) async {}
  @override
  Future<void> keepForNextTime() async {}
  @override
  Widget buildView() => const SizedBox.shrink();
}

/// Same shape as the real router: Home and its rituals inside a shell
/// branch, the crystal screen at the top level. [merkabaStart] lets a test
/// begin the session right before its end.
GoRouter _router({Duration merkabaStart = Duration.zero}) => GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.crystalResonance,
      builder: (context, state) => const Scaffold(body: Text('CRYSTAL')),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => shell,
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HarmonyGardenScreen(),
              routes: [
                GoRoute(
                  path: 'merkaba',
                  builder: (context, state) => MerkabaMeditationScreen(
                    initialElapsed: merkabaStart,
                    inCycle: AppRoutes.isCycle(state.uri.queryParameters),
                  ),
                ),
                GoRoute(
                  path: 'ritual-face',
                  builder: (context, state) => MassageScreen(
                    surface: MassageSurface.face,
                    inCycle: AppRoutes.isCycle(state.uri.queryParameters),
                  ),
                ),
                GoRoute(
                  path: 'ritual-body',
                  builder: (context, state) => MassageScreen(
                    surface: MassageSurface.body,
                    inCycle: AppRoutes.isCycle(state.uri.queryParameters),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('the full cycle moves screen to screen without errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          merkabaVideoPlaybackFactoryProvider.overrideWithValue(
            (_) => _FailedVideo(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    Future<void> step(String location) async {
      router.go(location);
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(tester.takeException(), isNull, reason: location);
    }

    // The kanji starts the cycle at Merkaba.
    await step(AppRoutes.cycle(AppRoutes.merkaba));
    expect(find.byType(MerkabaMeditationScreen), findsOneWidget);

    // Scrub the bar back and forth fast, crossing scenes and breath phases.
    final bar = find.bySemanticsLabel('Session progress');
    final left = tester.getTopLeft(bar) + const Offset(8, 16);
    final width = tester.getSize(bar).width - 16;
    final gesture = await tester.startGesture(left);
    for (var pass = 0; pass < 6; pass++) {
      for (final share in [0.9, 0.1, 0.6, 0.3]) {
        await gesture.moveTo(left + Offset(width * share, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
    }
    await gesture.up();
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull, reason: 'fast scrubbing');

    await step(AppRoutes.cycle(AppRoutes.ritualFace));
    expect(find.byType(MassageScreen), findsOneWidget);

    await step(AppRoutes.cycle(AppRoutes.ritualBody));
    expect(find.byType(MassageScreen), findsOneWidget);

    await step(AppRoutes.crystalResonanceFor(Crystal.jade.name));
    expect(find.text('CRYSTAL'), findsOneWidget);
  });

  testWidgets('finishing Merkaba and tapping Continue opens the face ritual', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = _router(
      merkabaStart: merkabaDuration - const Duration(seconds: 2),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          merkabaVideoPlaybackFactoryProvider.overrideWithValue(
            (_) => _FailedVideo(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    router.go(AppRoutes.cycle(AppRoutes.merkaba));
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull, reason: 'opening Merkaba');
    expect(find.byType(MerkabaMeditationScreen), findsOneWidget);
    await tester.tap(find.text('PLAY'));
    for (var frame = 0; frame < 80; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull, reason: 'finishing Merkaba');
    expect(find.text('CONTINUE'), findsOneWidget);

    await tester.tap(find.text('CONTINUE'));
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull, reason: 'Merkaba → face ritual');
    expect(find.byType(MassageScreen), findsOneWidget);
  });
}
