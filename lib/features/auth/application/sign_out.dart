import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../journey/application/ritual_cycle_controller.dart';
import '../../journey/data/ritual_cycle_repository.dart';
import '../../profile/application/member_profile_controller.dart';
import '../../profile/application/ritual_reminders_controller.dart';
import '../data/auth_gateway.dart';
import 'biometric_login_controller.dart';

/// Signs the member out and forgets their data on this device.
///
/// With a session, progress, profile and reminders are already mirrored to
/// the backend and come back on the next sign-in. Clearing the local copies
/// keeps another account on the same phone from seeing them. The selected
/// crystal and quiz result stay: the backend copy wins on sign-in anyway.
///
/// The fingerprint / Face ID credentials are kept on purpose: signing back in
/// with the sensor is the point of enabling it. They only unlock this phone,
/// need the owner's biometric, and are replaced when a different account
/// signs in with a password.
Future<void> signOutMember(WidgetRef ref) async {
  await ref.read(authGatewayProvider).signOut();

  await ref.read(ritualCycleRepositoryProvider).clear();
  await ref.read(memberProfileRepositoryProvider).clear();
  await SharedPreferencesAsync().remove(RitualRemindersController.morningKey);
  await SharedPreferencesAsync().remove(RitualRemindersController.eveningKey);

  ref
    // Re-reads the saved credentials so Login shows the sensor button.
    ..invalidate(biometricLoginControllerProvider)
    ..invalidate(ritualCycleControllerProvider)
    ..invalidate(memberProfileControllerProvider)
    ..invalidate(ritualRemindersControllerProvider);
}
