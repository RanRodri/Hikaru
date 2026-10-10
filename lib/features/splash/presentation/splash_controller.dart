import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_routes.dart';
import 'splash_logo.dart';

part 'splash_controller.g.dart';

const splashMinimumDuration = splashLogoDuration;

/// Resolves the route to open once the splash screen finishes.
///
/// Will check the Amplify auth session when authentication is added.
@riverpod
Future<String> splashDestination(Ref ref) async {
  await Future<void>.delayed(splashMinimumDuration);
  return AppRoutes.sanctuary;
}
