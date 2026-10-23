import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/features/crystals/application/selected_crystal_controller.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/four_temples/presentation/four_temples_screen.dart';
import 'package:hikaru/features/listening_room/application/journey_recommendation_controller.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';
import 'package:hikaru/features/listening_room/domain/journey_recommendation.dart';
import 'package:hikaru/features/listening_room/domain/quiz_answers.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets(
    'recommended label stays on quiz crystal when another is selected',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final recommendation = buildJourneyRecommendation(
        Crystal.jade,
        const QuizAnswers({
          1: {QuizOptionIds.q1CalmComfort},
          9: {QuizOptionIds.q9FiveMinutes},
        }),
      );
      await container
          .read(journeyRecommendationControllerProvider.notifier)
          .save(recommendation);
      await container
          .read(selectedCrystalProvider.notifier)
          .select(Crystal.obsidian);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FourTemplesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RECOMMENDED'), findsOneWidget);
      expect(find.text('SELECTED'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'JADE, Temple of Harmony, recommended for you',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'OBSIDIAN, Temple of Transformation, currently selected',
        ),
        findsOneWidget,
      );

      // Selecting a sound crystal must not rewrite the saved protocol.
      final stored = await container.read(
        journeyRecommendationControllerProvider.future,
      );
      expect(stored!.crystal, Crystal.jade);
      expect(stored.facialRitual, 'Soothing Comfort Protocol');
      expect(
        await container.read(selectedCrystalProvider.future),
        Crystal.obsidian,
      );
    },
  );
}
