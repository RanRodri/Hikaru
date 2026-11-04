import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_typography.dart';

/// Text styles shared by the infographic topic screens.
///
/// Headings are uppercase with wide tracking; body copy is 16 px with a 1.5
/// line height so it stays readable on a phone. Sizes are plain logical
/// pixels, so the system text scale applies on top of them.
abstract final class LibraryTopicStyles {
  static final TextStyle eyebrow = AppTypography.subheadline.copyWith(
    color: AppColors.white,
    fontSize: AppFontSizes.s11,
    letterSpacing: 2.4,
    height: 1.4,
  );

  static final TextStyle title = AppTypography.title.copyWith(
    color: AppColors.champagneGold,
    fontSize: AppFontSizes.s26,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 2.6,
  );

  static final TextStyle tagline = AppTypography.subheadline.copyWith(
    color: AppColors.cymaticTurquoise,
    fontSize: AppFontSizes.s12,
    letterSpacing: 2,
    height: 1.5,
  );

  static final TextStyle subtitle = AppTypography.subheadline.copyWith(
    color: AppColors.cymaticIndigoLight,
    fontSize: AppFontSizes.s12,
    letterSpacing: 2,
    height: 1.5,
  );

  static final TextStyle sectionHeading = AppTypography.subheadline.copyWith(
    color: AppColors.champagneGold,
    fontSize: AppFontSizes.s14,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.2,
    height: 1.4,
  );

  static final TextStyle body = AppTypography.body.copyWith(
    color: AppColors.fog,
    fontSize: AppFontSizes.s16,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final TextStyle cardLabel = AppTypography.subheadline.copyWith(
    color: AppColors.champagneGold,
    fontSize: AppFontSizes.s12,
    letterSpacing: 1.2,
    height: 1.4,
  );

  static final TextStyle cardKeyword = AppTypography.subheadline.copyWith(
    color: AppColors.cymaticTurquoise,
    fontSize: AppFontSizes.s11,
    letterSpacing: 1.6,
    height: 1.4,
  );

  static final TextStyle cardDesc = AppTypography.body.copyWith(
    color: AppColors.fog,
    fontSize: AppFontSizes.s14,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final TextStyle link = AppTypography.subheadline.copyWith(
    color: AppColors.champagneGold,
    fontSize: AppFontSizes.s12,
    letterSpacing: 1.6,
  );
}
