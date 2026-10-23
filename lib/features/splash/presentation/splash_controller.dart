import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_routes.dart';
import '../../auth/data/auth_gateway.dart';
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
  return routeAfterSplash(
    introSeen: true,
    sessionOpen: await ref.read(authGatewayProvider).hasSession(),
  );
}
