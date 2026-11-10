import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/media/remote_file_cache.dart';
import '../../../core/media/remote_image_prefetch.dart';
import '../../../core/media/remote_image_store.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/application/sign_out.dart';
import '../../auth/data/auth_gateway.dart';
import '../../massage/application/massage_video_preheat.dart';
import '../../massage/domain/massage_ritual.dart';
import '../../../core/backend/cognito_session.dart';
import '../../auth/data/session_inactivity.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
import '../../listening_room/domain/journey_recommendation.dart';
import '../../profile/data/user_profile_gateway.dart';
import '../../resonance_chamber/presentation/crystal_scene_photo.dart';
import '../data/launch_gate.dart';
import 'splash_logo.dart';

part 'splash_controller.g.dart';

const splashMinimumDuration = splashLogoDuration;

/// Completed once the splash symbol's first frame has been decoded.
final splashSymbolReadyProvider = Provider<Completer<void>>((ref) {
  final ready = Completer<void>();
  ref.onDispose(() {
    if (!ready.isCompleted) ready.complete();
  });
  return ready;
});

/// Resolves the route to open once the splash screen finishes.
///
/// The wait starts after the WebP decodes, so the ending is not cut off by
/// the time spent loading the symbol. The sanctuary intro plays only on the
/// first launch. Later openings keep the splash, then login or home.
@riverpod
Future<String> splashDestination(Ref ref) async {
  // The logo holds the screen for about ten seconds. Use that time to open
  // the ritual players so a massage is ready when home appears.
  unawaited(_warmRitualVideos(ref));
  await ref.watch(splashSymbolReadyProvider).future;
  if (!ref.mounted) return AppRoutes.sanctuary;
  await Future<void>.delayed(splashMinimumDuration);
  if (!ref.mounted) return AppRoutes.sanctuary;

  final gate = LaunchGate(SharedPreferencesAsync());
  final introSeen = await gate.introSeen();
  if (!ref.mounted) return AppRoutes.sanctuary;
  if (!introSeen) {
    await gate.markIntroSeen();
    return AppRoutes.sanctuary;
  }
  var sessionOpen = await ref.read(authGatewayProvider).hasSession();
  if (!ref.mounted) return AppRoutes.sanctuary;
  final inactivity = ref.read(sessionInactivityProvider);
  if (sessionOpen && await inactivity.hasExpired()) {
    // Not opened for 48 hours: ask for the password or the sensor again.
    await ref.read(memberSignOutProvider)();
    sessionOpen = false;
    if (!ref.mounted) return AppRoutes.login;
  } else if (sessionOpen) {
    await inactivity.touch();
    await ref.read(claimLocalDataProvider)();
    if (!ref.mounted) return AppRoutes.sanctuary;
  }
  if (!sessionOpen) {
    // Cognito ended the session (30-day token, user removed): say so, and
    // keep the phone's progress for when the same member signs back in.
    if (cognitoSessionExpired.value) {
      return AppRoutes.loginSessionExpired;
    }
    return routeAfterSplash(
      introSeen: true,
      sessionOpen: false,
      crystalAssigned: false,
      crystalRevealed: false,
    );
  }
  final recommendation = await ref.read(
    journeyRecommendationControllerProvider.future,
  );
  if (!ref.mounted) return AppRoutes.sanctuary;
  final route = routeForMember(
    crystalAssigned: recommendation != null,
    crystalRevealed: await _crystalRevealedForAccount(
      ref.read(userProfileGatewayProvider),
    ),
  );
  if (ref.mounted) {
    await _prepareImagesFor(
      ref.read(remoteImageCacheProvider),
      route,
      recommendation,
    );
  }
  return route;
}

/// Home only after the Listening Room has assigned a crystal and this
/// account has seen that reveal. Otherwise the questions, or the reveal,
/// continue. The decision is `User.isRevealedCrystal`, not a phone flag.
Future<String> routeForOpenSession(WidgetRef ref) async {
  ref.read(massageVideoPreheatProvider).warm(massageVideoWarmOrder);
  // Every sign-in ends here: it starts the 48 hour inactivity clock.
  await ref.read(sessionInactivityProvider).touch();
  cognitoSessionExpired.value = false;
  // Keeps or clears the phone's progress depending on who signed in, and
  // sends what was done while the session was gone.
  await ref.read(claimLocalDataProvider)();
  final recommendation = await ref.read(
    journeyRecommendationControllerProvider.future,
  );
  final route = routeForMember(
    crystalAssigned: recommendation != null,
    crystalRevealed: await _crystalRevealedForAccount(
      ref.read(userProfileGatewayProvider),
    ),
  );
  await _prepareImagesFor(
    ref.read(remoteImageCacheProvider),
    route,
    recommendation,
  );
  return route;
}

/// Puts the photos of the screen about to open on the device, so its first
/// frame is not an empty background. The rest download quietly afterwards.
Future<void> _prepareImagesFor(
  RemoteFileCache cache,
  String route,
  JourneyRecommendation? recommendation,
) {
  if (route == AppRoutes.listeningRoom) {
    return prepareListeningRoomImages(cache);
  }
  if (route == AppRoutes.resonanceChamber) {
    return prepareRevelationImages(
      cache,
      crystalSceneFile(recommendation?.crystal),
    );
  }
  if (route == AppRoutes.home) return prepareHomeBackground(cache);
  return Future<void>.value();
}

Future<void> _warmRitualVideos(Ref ref) async {
  try {
    if (!await ref.read(authGatewayProvider).hasSession()) return;
    if (!ref.mounted) return;
    ref.read(massageVideoPreheatProvider).warm(massageVideoWarmOrder);
  } catch (error, stackTrace) {
    log(
      'Ritual videos were not prepared',
      name: 'hikaru.massage',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// True only when this account's `User.isRevealedCrystal` is true.
///
/// A missing profile, a failed read, or an old flag saved on the phone all
/// count as not revealed. The phone flag belonged to whoever used the device
/// before, so it must not send a new account home.
Future<bool> _crystalRevealedForAccount(UserProfileGateway gateway) async {
  final profile = await gateway.fetchCurrent();
  return profile?.isRevealedCrystal == true;
}
