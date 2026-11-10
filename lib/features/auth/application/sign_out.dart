import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/ritual_notifications.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/data/selected_crystal_repository.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../../massage/application/massage_video_preheat.dart';
import '../../journey/data/ritual_cycle_repository.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
import '../../listening_room/data/journey_recommendation_repository.dart';
import '../../listening_room/data/quiz_answers_repository.dart';
import '../../profile/application/member_profile_controller.dart';
import '../../profile/application/ritual_reminders_controller.dart';
import '../../splash/data/launch_gate.dart';
import '../data/auth_gateway.dart';
import '../data/local_data_owner.dart';
import '../data/session_inactivity.dart';
import 'biometric_login_controller.dart';

/// Forgets the member's progress, profile, quiz and crystal on this phone.
/// Used on sign-out, and when a different account signs in on a phone that
/// still holds someone else's data.
final localMemberDataClearProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    await ref.read(ritualCycleRepositoryProvider).clear();
    await ref.read(memberProfileRepositoryProvider).clear();
    await ref.read(quizAnswersRepositoryProvider).clear();
    await ref.read(journeyRecommendationRepositoryProvider).clear();
    await ref.read(selectedCrystalRepositoryProvider).clear();
    await ref.read(localDataOwnerProvider).clear();
    await SharedPreferencesAsync().remove(LaunchGate.legacyCrystalRevealedKey);
    await SharedPreferencesAsync().remove(RitualRemindersController.morningKey);
    await SharedPreferencesAsync().remove(RitualRemindersController.eveningKey);
    await SharedPreferencesAsync().remove(
      RitualRemindersController.morningTimeKey,
    );
    await SharedPreferencesAsync().remove(
      RitualRemindersController.eveningTimeKey,
    );
    // Another account on this phone must not get this member's reminders.
    await ref.read(ritualNotificationsProvider).cancelAll();

    ref
      ..invalidate(ritualCycleControllerProvider)
      ..invalidate(manualStepCompletionUnlockedProvider)
      ..invalidate(memberProfileControllerProvider)
      ..invalidate(ritualRemindersControllerProvider)
      ..invalidate(journeyRecommendationControllerProvider)
      ..invalidate(selectedCrystalProvider);
  },
);

/// Runs on every sign-in and on launch with a session.
///
/// - A different account, or a phone with no recorded owner: the questionnaire,
///   the recommendation and the old reveal flag are cleared first.
/// - The same account (e.g. back after its session expired): the data stays,
///   and the screens reload so anything done meanwhile is sent now.
final claimLocalDataProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    final userId = await ref.read(currentMemberIdProvider)();
    if (userId == null) return;
    final owner = ref.read(localDataOwnerProvider);
    final previous = await owner.read();
    // A different account, or a phone whose owner was never recorded, must
    // not keep the previous questionnaire and reveal.
    if (previous != userId) {
      await ref.read(localMemberDataClearProvider)();
    }
    await owner.save(userId);
    ref
      ..invalidate(ritualCycleControllerProvider)
      ..invalidate(memberProfileControllerProvider)
      ..invalidate(ritualRemindersControllerProvider)
      ..invalidate(journeyRecommendationControllerProvider)
      ..invalidate(selectedCrystalProvider);
  },
);

/// The sign-out routine as a provider, so it runs from a screen
/// ([signOutMember]) and from the splash or the app lifecycle, which only
/// have a provider `Ref`, with the same steps.
final memberSignOutProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    ref.read(massageVideoPreheatProvider).discard();
    await ref.read(authGatewayProvider).signOut();
    await ref.read(sessionInactivityProvider).clear();
    await ref.read(localMemberDataClearProvider)();
    // Re-reads the saved credentials so Login shows the sensor button.
    ref.invalidate(biometricLoginControllerProvider);
  },
);

/// Signs the member out and forgets their data on this device.
///
/// With a session, progress, profile and reminders are already mirrored to
/// the backend and come back on the next sign-in. Clearing the local copies
/// keeps another account on the same phone from seeing them. The quiz draft
/// and the revealed crystal are cleared too, so the next account fills the
/// questionnaire and sees the reveal. This account's own progress comes back
/// from its answers and from `User.isRevealedCrystal`.
///
/// The fingerprint / Face ID credentials are kept on purpose: signing back in
/// with the sensor is the point of enabling it. They only unlock this phone,
/// need the owner's biometric, and are replaced when a different account
/// signs in with a password.
Future<void> signOutMember(WidgetRef ref) => ref.read(memberSignOutProvider)();
