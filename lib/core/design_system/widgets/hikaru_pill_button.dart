import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class HikaruPillButton extends StatelessWidget {
  const HikaruPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.buttonHeight = height,
    this.blurRadius = 16,
    this.shadowAlpha = 0.35,
    this.borderAlpha,
    this.labelStyle = AppTypography.pillLabel,
    this.busy = false,
  });

  static const double height = AppSpacing.s52;

  final String label;
  final VoidCallback onPressed;
  final double buttonHeight;
  final double blurRadius;
  final double shadowAlpha;
  final double? borderAlpha;
  final TextStyle labelStyle;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final shape = borderAlpha == null
        ? const StadiumBorder()
        : StadiumBorder(
            side: BorderSide(
              color: AppColors.champagneGold.withValues(alpha: borderAlpha!),
            ),
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonHeight / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: shadowAlpha),
            blurRadius: blurRadius,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: FilledButton(
          onPressed: busy ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.champagneGold,
            disabledBackgroundColor: AppColors.champagneGold,
            foregroundColor: AppColors.darkIndigoBlue,
            disabledForegroundColor: AppColors.darkIndigoBlue,
            shape: shape,
            elevation: 0,
          ),
          child: busy
              ? Semantics(
                  label: label,
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.darkIndigoBlue,
                    ),
                  ),
                )
              : Text(
                  label,
                  style: labelStyle.copyWith(color: AppColors.darkIndigoBlue),
                ),
        ),
      ),
    );
  }
}
