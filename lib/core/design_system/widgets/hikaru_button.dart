import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_gradients.dart';
import '../tokens/app_typography.dart';

class HikaruButton extends StatelessWidget {
  const HikaruButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foregroundColor = AppColors.white,
  });

  final String label;
  final VoidCallback onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkIndigoBlue.withValues(alpha: 0),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: AppGradients.gradientChampagne.colors,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 19),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTypography.subheadline.copyWith(
                      color: foregroundColor,
                      fontSize: 18,
                      letterSpacing: 1.44,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
