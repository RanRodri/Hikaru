import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

class HikaruPillButton extends StatelessWidget {
  const HikaruPillButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  static const double height = 52;

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.champagneGold,
            foregroundColor: AppColors.darkIndigoBlue,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: Text(
            label,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.darkIndigoBlue,
              fontSize: 11,
              letterSpacing: 1.65,
            ),
          ),
        ),
      ),
    );
  }
}
