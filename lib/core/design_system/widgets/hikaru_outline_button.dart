import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class HikaruOutlineButton extends StatelessWidget {
  const HikaruOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.35),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.champagneGold),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: AppSpacing.s36,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTypography.pathLabel.copyWith(color: AppColors.fog),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
