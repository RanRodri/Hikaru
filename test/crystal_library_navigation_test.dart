import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/router/app_routes.dart';

/// Mirrors the real router: a top-level crystal route next to a
/// StatefulShellRoute that owns Home and Library.
GoRouter _router(String initial) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(
      path: AppRoutes.crystalResonance,
      builder: (context, state) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go(
              AppRoutes.libraryTopicFor(
                state.pathParameters[AppRoutes.crystalResonanceParam]!,
              ),
            ),
            child: const Text('YOUR CRYSTAL'),
          ),
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => shell,
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const Scaffold(body: Text('HOME')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.library,
              builder: (context, state) =>
                  const Scaffold(body: Text('LIBRARY')),
              routes: [
                GoRoute(
                  path: ':${AppRoutes.libraryTopicParam}',
                  builder: (context, state) => Scaffold(
                    body: Text('TOPIC ${state.pathParameters['topic']}'),
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
  testWidgets(
    'YOUR CRYSTAL opens the Library topic without crashing the Navigator',
    (tester) async {
      // The crystal screen is reached from Home / Four Temples, so the shell
      // is already in the stack underneath it.
      final router = _router(AppRoutes.home);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push(AppRoutes.crystalResonanceFor('jade'));
      await tester.pumpAndSettle();
      expect(find.text('YOUR CRYSTAL'), findsOneWidget);

      // A plain `push` here reserves the Library shell branch's Navigator
      // key a second time and throws `!keyReservation.contains(key)`. The
      // screen must use `go` instead.
      await tester.tap(find.text('YOUR CRYSTAL'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('TOPIC jade'), findsOneWidget);
    },
  );
}
