import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_routes.dart';
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
/// the time spent loading the symbol. Will check the Amplify auth session
/// when authentication is added.
@riverpod
Future<String> splashDestination(Ref ref) async {
  await ref.watch(splashSymbolReadyProvider).future;
  if (!ref.mounted) return AppRoutes.sanctuary;
  await Future<void>.delayed(splashMinimumDuration);
  if (!ref.mounted) return AppRoutes.sanctuary;
  return AppRoutes.sanctuary;
}
