import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/core/design_system/widgets/hikaru_navigation_bar.dart';
import 'package:hikaru/core/router/app_router.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/splash/presentation/splash_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'hikaru_home_tour_seen': true,
        });
  });

  testWidgets(
    'logged-in navigation keeps tab stacks and does not return to onboarding',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

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

      await tester.pump(splashMinimumDuration);
      router.go(AppRoutes.resonanceChamber);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('ENTER MY HIKARU SANCTUARY'));
      await tester.tap(find.text('ENTER MY HIKARU SANCTUARY'));
      await tester.pumpAndSettle();

      expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
      expect(find.text('Your 30 Day Journey begins here.'), findsNothing);
      expect(router.canPop(), isFalse);

      // The center kanji starts the full cycle at the Merkaba.
      await tester.tap(find.bySemanticsLabel('Sanctuary'));
      await tester.pumpAndSettle();
      expect(find.text('Human Blueprint'), findsOneWidget);
      final cycleUri = router.routeInformationProvider.value.uri;
      expect(cycleUri.path, AppRoutes.merkaba);
      expect(AppRoutes.isCycle(cycleUri.queryParameters), isTrue);
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);

      await tester.tap(find.bySemanticsLabel('Merkaba'));
      await tester.pumpAndSettle();
      expect(find.text('Human Blueprint'), findsOneWidget);
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
      expect(router.canPop(), isFalse);

      await tester.tap(find.bySemanticsLabel('Hikaru Ritual Face'));
      await tester.pumpAndSettle();
      expect(find.text('THE FACE TEMPLE'), findsOneWidget);
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('THE HARMONY GARDEN'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(HikaruNavigationBar),
          matching: find.bySemanticsLabel('Library'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('JADE, Balance & Harmony'));
      await tester.pumpAndSettle();
      expect(find.text('Temple of Harmony'), findsOneWidget);

      await tester.tap(find.text('Journey'));
      await tester.pumpAndSettle();
      expect(find.text('JOURNEY'), findsOneWidget);
      expect(find.text('Temple of Harmony'), findsNothing);

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(find.text('Temple of Harmony'), findsOneWidget);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('LIBRARY'), findsOneWidget);
      expect(find.text('Temple of Harmony'), findsNothing);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Your crystal'));
      await tester.pumpAndSettle();
      expect(find.text('THE FOUR TEMPLES'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
      expect(find.text('Your 30 Day Journey begins here.'), findsNothing);
      expect(router.canPop(), isFalse);
    },
  );

  testWidgets('crystal detail goes back to the tab that opened it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

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

    await tester.pump(splashMinimumDuration);
    router.go(AppRoutes.journey);
    await tester.pumpAndSettle();
    router.push(AppRoutes.crystalResonanceFor('jade'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('CONTINUE'), findsNothing);
    expect(find.text('JADE'), findsWidgets);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('JOURNEY'), findsOneWidget);
    expect(find.text('Your 30 Day Journey begins here.'), findsNothing);
  });
}
