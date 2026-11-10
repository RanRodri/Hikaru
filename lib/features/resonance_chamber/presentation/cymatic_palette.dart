import 'dart:ui';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';

/// The three colors a crystal's cymatic cycles through. Every color is a
/// token of the Hikaru palette.
final class CymaticPalette {
  const CymaticPalette(this.primary, this.secondary, this.tertiary);

  final Color primary;
  final Color secondary;
  final Color tertiary;
}

extension CrystalCymaticPalette on Crystal {
  CymaticPalette get cymaticPalette => switch (this) {
    // Jade greens with a soft gold.
    Crystal.jade => const CymaticPalette(
      AppColors.emerald,
      AppColors.cymaticTurquoise,
      AppColors.champagneGold,
    ),
    // Pearl white and gold.
    Crystal.whiteQuartz => const CymaticPalette(
      AppColors.silver,
      AppColors.goldGlow,
      AppColors.champagneGold,
    ),
    // Terracotta red with amber.
    Crystal.redJasper => const CymaticPalette(
      AppColors.cymaticFire,
      AppColors.accentGold,
      AppColors.champagneGold80,
    ),
    // Silver gray with deep violet.
    Crystal.obsidian => const CymaticPalette(
      AppColors.metal,
      AppColors.cymaticIndigoLight,
      AppColors.indigoBlue40,
    ),
  };
}
