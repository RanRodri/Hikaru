import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/application/member_profile_controller.dart';
import '../data/auth_gateway.dart';

/// A new account is greeted by its username, not by the full name typed at
/// sign-up. Call it once, right after the first sign-in of a new account
/// (never after a regular login, so existing members keep the name they have).
///
/// The full name stays in Cognito's `name` attribute. Only the display name
/// the app shows is set, locally and on the backend profile.
Future<void> useUsernameAsDisplayName(WidgetRef ref, String username) async {
  final name = username.trim();
  // An email typed at login is not a name worth showing.
  if (!usernameIsAllowed(name)) return;
  try {
    await ref.read(memberProfileControllerProvider.notifier).save(name: name);
  } catch (error, stackTrace) {
    log(
      'Default display name',
      name: 'hikaru.auth',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
