import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class HikaruFaceIdButton extends StatelessWidget {
  const HikaruFaceIdButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.fingerprint = false,
  });

  static const String _iconAsset = 'assets/images/face_id.svg';
  static const double _circleSize = AppSpacing.s52;
  static const double _iconSize = 26;
  static const List<Shadow> _labelShadow = [
    Shadow(color: AppColors.scrim80, offset: Offset(0, 1), blurRadius: 8),
  ];

  final VoidCallback onPressed;
  final String label;
  final bool fingerprint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.r16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _circleSize,
                height: _circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkIndigoBlue.withValues(alpha: 0.4),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.7),
                    width: AppSpacing.s0_75,
                  ),
                ),
                child: fingerprint
                    ? const Icon(
                        Icons.fingerprint,
                        size: _iconSize,
                        color: AppColors.champagneGold,
                      )
                    : SvgPicture.asset(
                        _iconAsset,
                        width: _iconSize,
                        height: _iconSize,
                        colorFilter: const ColorFilter.mode(
                          AppColors.champagneGold,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                label,
                style: AppTypography.faceIdLabel.copyWith(
                  color: AppColors.champagneGold,
                  shadows: _labelShadow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
