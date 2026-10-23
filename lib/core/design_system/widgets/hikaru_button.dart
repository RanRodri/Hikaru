import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_font_sizes.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_typography.dart';

/// Primary call to action. It matches the primary buttons of the sign in and
/// register screens: solid gold pill, full width, with a soft gold glow.
class HikaruButton extends StatelessWidget {
  const HikaruButton({super.key, required this.label, required this.onPressed});

  static const double height = 48;

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.r32),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.champagneGold,
          foregroundColor: AppColors.darkIndigoBlue,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        // Scales long labels down instead of cutting them, which matters in
        // languages that run longer than English.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.darkIndigoBlue,
              fontSize: AppFontSizes.s11,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
