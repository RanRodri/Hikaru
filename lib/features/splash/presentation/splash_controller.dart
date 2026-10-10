import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_routes.dart';

part 'splash_controller.g.dart';

const splashMinimumDuration = Duration(seconds: 3);

/// Resolves the route to open once the splash screen finishes.
///
/// Will check the Amplify auth session when authentication is added.
@riverpod
Future<String> splashDestination(Ref ref) async {
  await Future<void>.delayed(splashMinimumDuration);
  return AppRoutes.sanctuary;
}
