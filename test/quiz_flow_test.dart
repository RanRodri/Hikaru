import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/core/design_system/tokens/app_colors.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/crystals/application/selected_crystal_controller.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/listening_room/application/journey_recommendation_controller.dart';
import 'package:hikaru/features/listening_room/data/quiz_answers_repository.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';
import 'package:hikaru/features/listening_room/presentation/listening_room_quiz_screen.dart';
import 'package:hikaru/features/listening_room/presentation/ritual_ready_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'support/quiz_driver.dart';
import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  void usePhoneViewport(WidgetTester tester) {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
  }

  testWidgets(
    'walks the 10 questions, stores answers, and assigns the crystal',
    (tester) async {
      usePhoneViewport(tester);
      final router = GoRouter(
        initialLocation: AppRoutes.listeningRoomQuiz,
        routes: [
          GoRoute(
            path: AppRoutes.listeningRoomQuiz,
            builder: (context, state) => const ListeningRoomQuizScreen(),
          ),
          GoRoute(
            path: AppRoutes.ritualReady,
            builder: (context, state) => const RitualReadyScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      final container = ProviderContainer();
      addTearDown(container.dispose);

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

      expect(find.text('01 / 10'), findsOneWidget);
      expect(
        find.text('What would you like to see reflected in the mirror today?'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('NEXT'));
      await tester.tap(find.text('NEXT'));
      await tester.pump();
      expect(find.text('Select an option.'), findsOneWidget);

      await tapQuizChoice(tester, 'Deeply hydrate');
      await tapQuizNext(tester);

      expect(find.text('02 / 10'), findsOneWidget);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('01 / 10'), findsOneWidget);
      expect(find.text('Deeply hydrate'), findsOneWidget);

      const labels = [
        'Sensitive',
        'After a restless night',
        'Cheeks',
        'Overall facial harmony',
        'Slightly sensitive',
        'Refreshed',
        'Harmony',
        'Clarity and renewal',
        'It is part of my regular routine',
      ];

      await tester.ensureVisible(find.text('NEXT'));
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      for (final label in labels) {
        await tapQuizChoice(tester, label);
        await tapQuizNext(tester);
      }

      expect(find.text('Your\nRitual Is Ready'), findsOneWidget);

      final saved = await container.read(quizAnswersRepositoryProvider).read();
      expect(saved.selectedIds(1), {QuizOptionIds.q1DeeplyHydrate});
      expect(saved.selectedIds(2), {QuizOptionIds.q2Sensitive});
      expect(saved.selectedIds(8), {QuizOptionIds.q8Harmony});
      expect(saved.selectedIds(9), {QuizOptionIds.q9ClarityRenewal});
      expect(saved.selectedIds(10), {QuizOptionIds.q10Routine});
      expect(
        await container.read(selectedCrystalProvider.future),
        Crystal.jade,
      );
      final recommendation = await container.read(
        journeyRecommendationControllerProvider.future,
      );
      expect(recommendation, isNotNull);
      expect(recommendation!.crystal, Crystal.jade);
      expect(recommendation.facialRitual, 'Soothing Comfort Protocol');
      expect(recommendation.durationMinutes, 5);

      final stored = QuizAnswersRepository(SharedPreferencesAsync());
      expect((await stored.read()).selectedIds(8), {QuizOptionIds.q8Harmony});
      expect(await stored.readStep(), 0);
    },
  );

  testWidgets('Q10 familiarity is single choice', (tester) async {
    usePhoneViewport(tester);
    final router = GoRouter(
      initialLocation: AppRoutes.listeningRoomQuiz,
      routes: [
        GoRoute(
          path: AppRoutes.listeningRoomQuiz,
          builder: (context, state) => const ListeningRoomQuizScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    final container = ProviderContainer();
    addTearDown(container.dispose);

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

    const path = [
      'Deeply hydrate',
      'Sensitive',
      'After a restless night',
      'Cheeks',
      'Overall facial harmony',
      'Slightly sensitive',
      'Refreshed',
      'Harmony',
      'Clarity and renewal',
    ];
    for (final label in path) {
      await tapQuizChoice(tester, label);
      await tapQuizNext(tester);
    }

    expect(find.text('10 / 10'), findsOneWidget);
    expect(find.text('Select all that apply'), findsNothing);

    await tapQuizChoice(tester, 'Today is my very first ritual');
    await tapQuizChoice(tester, 'It is part of my regular routine');

    // Single choice: selecting a second option clears the first.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'It is part of my regular routine' &&
            widget.properties.checked == true,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Today is my very first ritual' &&
            widget.properties.checked == true,
      ),
      findsNothing,
    );
  });

  testWidgets('resumes the unfinished quiz at the saved question', (
    tester,
  ) async {
    usePhoneViewport(tester);
    Future<ProviderContainer> openQuiz() async {
      final router = GoRouter(
        initialLocation: AppRoutes.listeningRoomQuiz,
        routes: [
          GoRoute(
            path: AppRoutes.listeningRoomQuiz,
            builder: (context, state) => const ListeningRoomQuizScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);
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
      return container;
    }

    await openQuiz();
    await tapQuizChoice(tester, 'Deeply hydrate');
    await tapQuizNext(tester);
    expect(find.text('02 / 10'), findsOneWidget);

    await openQuiz();
    expect(find.text('02 / 10'), findsOneWidget);
    expect(find.text('How does your skin feel today?'), findsOneWidget);
    expect(
      (await QuizAnswersRepository(
        SharedPreferencesAsync(),
      ).read()).selectedIds(1),
      {QuizOptionIds.q1DeeplyHydrate},
    );

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('01 / 10'), findsOneWidget);

    await openQuiz();
    expect(find.text('01 / 10'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Deeply hydrate' &&
            widget.properties.checked == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('options sit in a centered panel on small and large phones', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in const [
      Size(360, 640),
      Size(360, 800),
      Size(390, 844),
      Size(430, 932),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      final router = GoRouter(
        initialLocation: AppRoutes.listeningRoomQuiz,
        routes: [
          GoRoute(
            path: AppRoutes.listeningRoomQuiz,
            builder: (context, state) => const ListeningRoomQuizScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      final container = ProviderContainer();
      addTearDown(container.dispose);

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
      expect(tester.takeException(), isNull);

      final panel = tester.getRect(
        find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == AppColors.scrim60 &&
              decoration.borderRadius == BorderRadius.circular(16);
        }),
      );
      expect(panel.width, lessThanOrEqualTo(280));
      expect(panel.left, greaterThanOrEqualTo(16));
      expect(panel.right, lessThanOrEqualTo(size.width - 16));
      expect((panel.center.dx - size.width / 2).abs(), lessThan(8));

      final label = tester.getRect(find.text('Deeply hydrate'));
      expect(label.left, greaterThan(panel.left));
      expect(label.right, lessThan(panel.right));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
