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

    expect(find.text('YOUR SANCTUARY'), findsOneWidget);
    expect(
      find.text(
        'This is your sanctuary. The numbers mark the order of the day.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('THE ORDER'), findsOneWidget);
    expect(
      find.text(
        'Merkaba is 1. Face and body are 2. Your crystal is 3. Each circle opens on its own.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('BEGIN TODAY'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('THE BAR'), findsOneWidget);
    expect(
      find.text(
        'Journey keeps your day, streak, and photos. Settings keeps your account, language, and reminders.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR SANCTUARY'), findsNothing);
    expect(find.text('THE HARMONY GARDEN'), findsOneWidget);
    expect(await HomeTourStore().seen(), isTrue);

    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();
    expect(find.text('YOUR SANCTUARY'), findsNothing);
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

    expect(find.text('YOUR SANCTUARY'), findsNothing);
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
