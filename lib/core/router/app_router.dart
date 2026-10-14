import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
import '../../features/library/presentation/library_detail_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/massage/domain/massage_ritual.dart';
import '../../features/massage/presentation/massage_screen.dart';
import '../../features/merkaba/presentation/merkaba_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/resonance_chamber/presentation/crystal_resonance_screen.dart';
import '../../features/resonance_chamber/presentation/resonance_chamber_screen.dart';
import '../../features/ritual/presentation/ritual_screen.dart';
import '../../features/sanctuary/presentation/sanctuary_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
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
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
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
                    builder: (context, state) =>
                        const MerkabaMeditationScreen(),
                  ),
                  GoRoute(
                    path: 'ritual-face',
                    builder: (context, state) =>
                        const MassageScreen(surface: MassageSurface.face),
                  ),
                  GoRoute(
                    path: 'ritual-body',
                    builder: (context, state) =>
                        const MassageScreen(surface: MassageSurface.body),
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
                      return libraryArticleFor(topic) == null
                          ? AppRoutes.library
                          : null;
                    },
                    builder: (context, state) => LibraryDetailScreen(
                      article: libraryArticleFor(
                        state.pathParameters[AppRoutes.libraryTopicParam],
                      )!,
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
