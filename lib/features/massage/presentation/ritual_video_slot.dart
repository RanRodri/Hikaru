import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// Full-bleed ritual video. While it loads, or if it cannot be played, a quiet
/// placeholder in the ritual palette shows instead.
class RitualVideoSlot extends StatelessWidget {
  const RitualVideoSlot({super.key, this.controller, this.failed = false});

  final VideoPlayerController? controller;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final video = controller;
    final ready = video != null && video.value.isInitialized && !failed;
    return Semantics(
      label: AppLocalizations.of(context).ritualVideoSemantics,
      excludeSemantics: true,
      child: ready ? _frame(video) : _placeholder(context),
    );
  }

  /// Fills the screen and crops the sides or ends rather than stretching.
  Widget _frame(VideoPlayerController video) {
    final size = video.value.size;
    return ColoredBox(
      color: AppColors.darkIndigoBlue,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(video),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return DecoratedBox(
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
    );
  }
}
