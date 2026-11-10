import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
import '../application/ritual_cycle_controller.dart';
import '../domain/ritual_cycle.dart';

/// Where the guided cycle goes for each step. Merkaba and the massages run
/// in cycle mode so their closing button leads on; the crystal is the last
/// stop.
String cycleRouteFor(RitualStep step, ProviderContainer container) {
  switch (step) {
    case RitualStep.merkaba:
      return AppRoutes.cycle(AppRoutes.merkaba);
    case RitualStep.facial:
      return AppRoutes.cycle(AppRoutes.ritualFace);
    case RitualStep.body:
      return AppRoutes.cycle(AppRoutes.ritualBody);
    case RitualStep.crystal:
      final crystal =
          container.read(selectedCrystalProvider).value ??
          container
              .read(journeyRecommendationControllerProvider)
              .value
              ?.crystal;
      return crystal == null
          ? AppRoutes.fourTemples
          : AppRoutes.crystalResonanceFor(crystal.name);
  }
}

/// The sanctuary button: the first step still waiting today. With the whole
/// ritual done it starts over from Merkaba, so the member can repeat it.
String cycleEntryRoute(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  final pending = container.read(todayRitualProvider).pending;
  return cycleRouteFor(
    pending.isEmpty ? RitualStep.merkaba : pending.first,
    container,
  );
}

/// The next step after [current] that is still waiting today, in ritual
/// order. `null` when every later step is already done.
String? nextCycleRoute(BuildContext context, {required RitualStep current}) {
  final container = ProviderScope.containerOf(context, listen: false);
  final today = container.read(todayRitualProvider);
  for (final step in RitualStep.values.skip(current.index + 1)) {
    if (!today.isDone(step)) return cycleRouteFor(step, container);
  }
  return null;
}
