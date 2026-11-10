import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_gateway.dart';
import '../../features/auth/presentation/confirm_sign_up_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/discovery/presentation/discovery_screen.dart';
import '../../features/listening_room/presentation/listening_room_quiz_screen.dart';
import '../../features/listening_room/presentation/listening_room_screen.dart';
import '../../features/listening_room/presentation/ritual_ready_screen.dart';
import '../../features/mirror_garden/presentation/mirror_garden_screen.dart';
import '../../features/crystals/domain/crystal.dart';
import '../../features/four_temples/presentation/four_temples_screen.dart';
import '../../features/harmony_garden/presentation/harmony_garden_screen.dart';
import '../../features/journey/presentation/journey_screen.dart';
import '../../features/library/domain/library_article.dart';
import '../../features/library/domain/library_topic_content.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/library/presentation/library_topic_page.dart';
import '../../features/massage/domain/massage_ritual.dart';
import '../../features/massage/presentation/massage_screen.dart';
import '../../features/merkaba/presentation/merkaba_screen.dart';
import '../../features/profile/presentation/profile_account_screen.dart';
import '../../features/profile/presentation/profile_privacy_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/resonance_chamber/presentation/crystal_resonance_screen.dart';
import '../../features/resonance_chamber/presentation/resonance_chamber_screen.dart';
import '../../features/ritual/presentation/ritual_screen.dart';
import '../../features/sanctuary/presentation/sanctuary_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/store/presentation/store_web_view_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.sanctuary,
        builder: (context, state) => const SanctuaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.discovery,
        builder: (context, state) => const DiscoveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.ritual,
        builder: (context, state) => const RitualScreen(),
      ),
      GoRoute(
        path: AppRoutes.store,
        builder: (context, state) => const StoreWebViewScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          sessionExpired: AppRoutes.isSessionExpired(state.uri.queryParameters),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.confirmSignUp,
        builder: (context, state) {
          final pending = state.extra;
          if (pending is! PendingConfirmation) return const LoginScreen();
          return ConfirmSignUpScreen(pending: pending);
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.listeningRoom,
        builder: (context, state) => const ListeningRoomScreen(),
      ),
      GoRoute(
        path: AppRoutes.listeningRoomQuiz,
        builder: (context, state) => const ListeningRoomQuizScreen(),
      ),
      GoRoute(
        path: AppRoutes.ritualReady,
        builder: (context, state) => const RitualReadyScreen(),
      ),
      GoRoute(
        path: AppRoutes.mirrorGarden,
        builder: (context, state) => const MirrorGardenScreen(),
      ),
      GoRoute(
        path: AppRoutes.resonanceChamber,
        builder: (context, state) => const ResonanceChamberScreen(),
      ),
      GoRoute(
        path: AppRoutes.crystalResonance,
        redirect: (context, state) {
          final crystal = Crystal.fromName(
            state.pathParameters[AppRoutes.crystalResonanceParam],
          );
          return crystal == null ? AppRoutes.fourTemples : null;
        },
        builder: (context, state) => CrystalResonanceScreen(
          crystal: Crystal.fromName(
            state.pathParameters[AppRoutes.crystalResonanceParam],
          )!,
        ),
        routes: [
          // Same guide as the Library tab, but a child of the crystal route
          // so it can be pushed and popped without losing the crystal screen.
          GoRoute(
            path: 'library',
            builder: (context, state) => LibraryTopicPage(
              topicId: Crystal.fromName(
                state.pathParameters[AppRoutes.crystalResonanceParam],
              )!.name,
            ),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journey,
                builder: (context, state) => const JourneyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.library,
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: ':${AppRoutes.libraryTopicParam}',
                    redirect: (context, state) {
                      final topic =
                          state.pathParameters[AppRoutes.libraryTopicParam];
                      final known =
                          libraryArticleFor(topic) != null ||
                          libraryTopicSources.containsKey(topic);
                      return known ? null : AppRoutes.library;
                    },
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      key: state.pageKey,
                      transitionDuration: const Duration(milliseconds: 380),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 280,
                      ),
                      child: LibraryTopicPage(
                        topicId:
                            state.pathParameters[AppRoutes.libraryTopicParam]!,
                      ),
                      transitionsBuilder:
                          (context, animation, secondary, child) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            );
                            return FadeTransition(
                              opacity: curved,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.025),
                                  end: Offset.zero,
                                ).animate(curved),
                                child: child,
                              ),
                            );
                          },
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'account',
                    builder: (context, state) => const ProfileAccountScreen(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    builder: (context, state) => const ProfilePrivacyScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.fourTemples,
        builder: (context, state) => const FourTemplesScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}
