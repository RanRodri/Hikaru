import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hiraku/core/design_system/theme/app_theme.dart';
import 'package:hiraku/core/design_system/tokens/app_colors.dart';
import 'package:hiraku/core/router/app_routes.dart';
import 'package:hiraku/features/crystals/application/selected_crystal_controller.dart';
import 'package:hiraku/features/crystals/domain/crystal.dart';
import 'package:hiraku/features/listening_room/data/quiz_answers_repository.dart';
import 'package:hiraku/features/listening_room/domain/discovery_quiz.dart';
import 'package:hiraku/features/listening_room/presentation/listening_room_quiz_screen.dart';
import 'package:hiraku/features/listening_room/presentation/ritual_ready_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'support/quiz_driver.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets(
    'walks the 10 questions, stores answers, and assigns the crystal',
    (tester) async {
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
          child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('01 / 10'), findsOneWidget);
      expect(
        find.text('What would you like to see reflected in the mirror today?'),
        findsOneWidget,
      );
      expect(find.text('Select all that resonate with you'), findsOneWidget);

      await tester.ensureVisible(find.text('NEXT'));
      await tester.tap(find.text('NEXT'));
      await tester.pump();
      expect(find.text('Select an option.'), findsOneWidget);

      await tapQuizChoice(tester, 'Reduce puffiness');
      await tapQuizChoice(tester, 'Reduce visible redness');
      await tapQuizNext(tester);

      expect(find.text('02 / 10'), findsOneWidget);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('01 / 10'), findsOneWidget);
      expect(find.text('Reduce puffiness'), findsOneWidget);

      const labels = [
        'Sensitive',
        'In the morning',
        'Jaw',
        'Jawline',
        'Red or irritated',
        'Deeply relaxed',
        'Renewal',
        '5 minutes',
        'Today is my very first ritual',
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
      expect(saved.selectedIds(1), {
        QuizOptionIds.q1ReducePuffiness,
        QuizOptionIds.q1ReduceRedness,
      });
      expect(saved.selectedIds(2), {QuizOptionIds.q2Sensitive});
      expect(saved.selectedIds(8), {QuizOptionIds.q8Renewal});
      expect(saved.selectedIds(9), {QuizOptionIds.q9DailyRitual});
      expect(
        await container.read(selectedCrystalProvider.future),
        Crystal.jade,
      );

      final stored = QuizAnswersRepository(SharedPreferencesAsync());
      expect((await stored.read()).selectedIds(8), {QuizOptionIds.q8Renewal});
      expect(await stored.readStep(), 0);
    },
  );

  testWidgets('resumes the unfinished quiz at the saved question', (
    tester,
  ) async {
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
          child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    await openQuiz();
    await tapQuizChoice(tester, 'Reduce puffiness');
    await tapQuizNext(tester);
    expect(find.text('02 / 10'), findsOneWidget);

    await openQuiz();
    expect(find.text('02 / 10'), findsOneWidget);
    expect(find.text('How does your skin feel today?'), findsOneWidget);
    expect(
      (await QuizAnswersRepository(
        SharedPreferencesAsync(),
      ).read()).selectedIds(1),
      {QuizOptionIds.q1ReducePuffiness},
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
            widget.properties.label == 'Reduce puffiness' &&
            widget.properties.checked == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('options stay centered on small and large phones', (
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
          child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final options = tester.getRect(find.byType(ListView));
      expect(options.center.dx, closeTo(size.width / 2, 1));
      expect(options.width, lessThanOrEqualTo(280));
      expect(options.left, greaterThan(24));

      final label = tester.getRect(find.text('Reduce puffiness'));
      expect(label.left, greaterThan(options.left));
      expect(label.right, lessThan(options.right));

      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == AppColors.scrim60;
        }),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
