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
      expect(find.text('What is your skin asking for today?'), findsOneWidget);

      await tester.ensureVisible(find.text('NEXT'));
      await tester.tap(find.text('NEXT'));
      await tester.pump();
      expect(find.text('Select an option.'), findsOneWidget);

      await tapQuizChoice(tester, 'Calm and comfort');
      await tapQuizNext(tester);

      expect(find.text('02 / 10'), findsOneWidget);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('01 / 10'), findsOneWidget);
      expect(find.text('Calm and comfort'), findsOneWidget);

      const labels = [
        'Sensitive or easily irritated',
        'Emotionally overwhelmed',
        'Stress and emotional pressure',
        'Signs of stress or tension',
        'Gentleness and balance',
        'Return to harmony',
        'Calm and nurtured',
        '5 minutes',
        'None of the above',
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
      expect(saved.selectedIds(1), {QuizOptionIds.q1CalmComfort});
      expect(saved.selectedIds(2), {QuizOptionIds.q2Sensitive});
      expect(saved.selectedIds(8), {QuizOptionIds.q8CalmNurtured});
      expect(saved.selectedIds(9), {QuizOptionIds.q9FiveMinutes});
      expect(saved.selectedIds(10), {QuizOptionIds.q10None});
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
      expect((await stored.read()).selectedIds(8), {
        QuizOptionIds.q8CalmNurtured,
      });
      expect(await stored.readStep(), 0);
    },
  );

  testWidgets('Q10 none is exclusive of safety concerns', (tester) async {
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
      'Calm and comfort',
      'Sensitive or easily irritated',
      'Calm and balanced',
      'Stress and emotional pressure',
      'Signs of stress or tension',
      'Gentleness and balance',
      'Return to harmony',
      'Calm and nurtured',
      '5 minutes',
    ];
    for (final label in path) {
      await tapQuizChoice(tester, label);
      await tapQuizNext(tester);
    }

    expect(find.text('10 / 10'), findsOneWidget);
    expect(find.text('Select all that apply'), findsOneWidget);

    await tapQuizChoice(tester, 'Open or broken skin');
    await tapQuizChoice(tester, 'None of the above');
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'None of the above' &&
            widget.properties.checked == true,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Open or broken skin' &&
            widget.properties.checked == true,
      ),
      findsNothing,
    );

    await tapQuizChoice(tester, 'Active irritation or painful inflammation');
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'None of the above' &&
            widget.properties.checked == true,
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Active irritation or painful inflammation' &&
            widget.properties.checked == true,
      ),
      findsOneWidget,
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
    await tapQuizChoice(tester, 'Calm and comfort');
    await tapQuizNext(tester);
    expect(find.text('02 / 10'), findsOneWidget);

    await openQuiz();
    expect(find.text('02 / 10'), findsOneWidget);
    expect(find.text('How does your skin feel right now?'), findsOneWidget);
    expect(
      (await QuizAnswersRepository(
        SharedPreferencesAsync(),
      ).read()).selectedIds(1),
      {QuizOptionIds.q1CalmComfort},
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
            widget.properties.label == 'Calm and comfort' &&
            widget.properties.checked == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('options sit on the photo and fit small and large phones', (
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

      final options = tester.getRect(find.byType(SingleChildScrollView).first);
      expect(options.left, greaterThanOrEqualTo(24));
      expect(options.right, lessThanOrEqualTo(size.width - 24));

      // The options start to the right of the photo's window, as designed,
      // and the text never leaves the screen.
      final label = tester.getRect(find.text('Calm and comfort'));
      expect(label.left, greaterThan(size.width * 0.3));
      expect(label.right, lessThan(size.width));

      // They sit straight on the photo: no dark panel behind them.
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == AppColors.scrim60;
        }),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
