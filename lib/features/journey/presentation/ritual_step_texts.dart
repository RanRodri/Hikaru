import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/ritual_cycle.dart';

extension RitualStepTexts on RitualStep {
  String label(AppLocalizations l10n) => switch (this) {
    RitualStep.merkaba => l10n.ritualStepMerkaba,
    RitualStep.facial => l10n.ritualStepFacial,
    RitualStep.body => l10n.ritualStepBody,
    RitualStep.crystal => l10n.ritualStepCrystal,
  };

  /// Gold line artwork of the Hikaru icon set.
  String get iconAsset => switch (this) {
    RitualStep.merkaba => 'assets/images/ritual_merkaba.svg',
    RitualStep.facial => 'assets/images/ritual_face.svg',
    RitualStep.body => 'assets/images/ritual_body.svg',
    RitualStep.crystal => 'assets/images/ritual_crystal.svg',
  };
}

/// The step's brand icon, tinted to [color] (gold by default).
class RitualStepIcon extends StatelessWidget {
  const RitualStepIcon({
    super.key,
    required this.step,
    required this.size,
    this.color = AppColors.champagneGold,
  });

  final RitualStep step;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      step.iconAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
