import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/features/crystals/application/selected_crystal_controller.dart';
import 'package:hikaru/core/media/remote_image.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/listening_room/application/journey_recommendation_controller.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';
import 'package:hikaru/features/listening_room/domain/journey_recommendation.dart';
import 'package:hikaru/features/listening_room/domain/quiz_answers.dart';
import 'package:hikaru/features/resonance_chamber/presentation/resonance_chamber_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('reveals crystal and protocol without frequency audio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final recommendation = buildJourneyRecommendation(
      Crystal.obsidian,
      const QuizAnswers({
        2: {QuizOptionIds.q2Dry},
        9: {QuizOptionIds.q9FiveMinutes},
      }),
    );

    await container
        .read(selectedCrystalProvider.notifier)
        .select(Crystal.obsidian);
    await container
        .read(journeyRecommendationControllerProvider.notifier)
        .save(recommendation);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ResonanceChamberScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your 30 Day Journey begins here.'), findsOneWidget);
    expect(
      find.text(
        'Your personalized journey brings together crystal symbolism, mindful '
        'touch, music, and intention to accompany you through 30 days of '
        'beauty, balance, and self-discovery.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Assigned crystal OBSIDIAN'), findsOneWidget);
    expect(find.text('The Mirror of the Unseen'), findsOneWidget);
    expect(find.text('YOUR RECOMMENDED PROTOCOL'), findsOneWidget);
    expect(find.text('Hydration Protocol'), findsOneWidget);
    expect(find.text('5 minutes'), findsOneWidget);
    expect(find.text('ENTER MY HIKARU SANCTUARY'), findsOneWidget);
    expect(find.text('639 Hz'), findsNothing);
    expect(find.text('THE ALIGNMENT TRIAD'), findsNothing);
    expect(find.bySemanticsLabel('Your cymatic signature'), findsNothing);
    expect(_sceneImage('obsidian.png'), findsOneWidget);
  });

  testWidgets('falls back to selected crystal when recommendation is absent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(selectedCrystalProvider.notifier).select(Crystal.jade);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ResonanceChamberScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Assigned crystal JADE'), findsOneWidget);
    expect(find.text('The Garden of Harmony'), findsOneWidget);
    expect(_sceneImage('jade.png'), findsOneWidget);
  });
}

Finder _sceneImage(String fileName) => find.byWidgetPredicate(
  (widget) => widget is RemoteImage && widget.fileName == fileName,
);
