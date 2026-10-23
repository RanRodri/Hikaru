import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// Reserved space for the ritual video. Until a [videoUrl] is wired to a
/// player it shows a quiet placeholder in the ritual palette.
class RitualVideoSlot extends StatelessWidget {
  const RitualVideoSlot({super.key, this.videoUrl});

  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).ritualVideoSemantics,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.1),
            radius: 0.9,
            colors: [
              AppColors.indigoBlue80.withValues(alpha: 0.55),
              AppColors.indigoBlue,
              AppColors.darkIndigoBlue,
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.s52,
                height: AppSpacing.s52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.champagneGold80.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s10),
              Text(
                AppLocalizations.of(context).ritualVideoPlaceholder,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.fog.withValues(alpha: 0.55),
                  fontSize: AppFontSizes.s9,
                  letterSpacing: 2.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
