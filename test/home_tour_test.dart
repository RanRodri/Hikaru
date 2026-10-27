import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/features/harmony_garden/data/home_tour_store.dart';
import 'package:hikaru/features/harmony_garden/presentation/harmony_garden_screen.dart';
import 'package:hikaru/l10n/app_localizations.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  testWidgets('the first home visit walks the garden, then stays quiet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('Your sanctuary'), findsOneWidget);
    expect(
      find.text('These circles are today\'s ritual. The numbers show the order.'),
      findsOneWidget,
    );

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('One, then two, then three'), findsOneWidget);
    expect(
      find.text(
        'Merkaba comes first. Face and body are next. Your crystal is last.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('Begin here'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('The rest of Hikaru'), findsOneWidget);
    expect(
      find.text(
        'Journey keeps your day, streak, and photos. Settings keeps your account.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(find.text('Your sanctuary'), findsNothing);
    expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
    expect(await HomeTourStore().seen(), isTrue);

    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();
    expect(find.text('Your sanctuary'), findsNothing);
  });

  testWidgets('skip closes the tour and does not show it again', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    expect(find.text('Your sanctuary'), findsNothing);
    expect(await HomeTourStore().seen(), isTrue);
  });
}

Widget _home() {
  return ProviderScope(
    child: MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      home: HarmonyGardenScreen(),
    ),
  );
}
