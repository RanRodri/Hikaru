import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/media/remote_image_store.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/data/auth_gateway.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
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
  final sessionOpen = await ref.read(authGatewayProvider).hasSession();
  if (!ref.mounted) return AppRoutes.sanctuary;
  if (!sessionOpen) {
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
    crystalRevealed: await gate.crystalRevealed(),
  );
  if (route == AppRoutes.listeningRoom && ref.mounted) {
    await prepareListeningRoomImages(ref.read(remoteImageCacheProvider));
  }
  if (route == AppRoutes.home && ref.mounted) {
    await prepareHomeBackground(ref.read(remoteImageCacheProvider));
  }
  return route;
}

/// Home only after the Listening Room has assigned a crystal and the member
/// has opened that reveal. Otherwise the questions, or the reveal, continue.
Future<String> routeForOpenSession(WidgetRef ref) async {
  final recommendation = await ref.read(
    journeyRecommendationControllerProvider.future,
  );
  final revealed = await LaunchGate(SharedPreferencesAsync()).crystalRevealed();
  final route = routeForMember(
    crystalAssigned: recommendation != null,
    crystalRevealed: revealed,
  );
  if (route == AppRoutes.listeningRoom) {
    await prepareListeningRoomImages(ref.read(remoteImageCacheProvider));
  }
  if (route == AppRoutes.home) {
    await prepareHomeBackground(ref.read(remoteImageCacheProvider));
  }
  return route;
}
