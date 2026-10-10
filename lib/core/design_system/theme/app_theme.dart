import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import 'hikaru_tokens.dart';

abstract final class AppTheme {
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: AppColors.darkIndigoBlue,
    fontFamily: AppFontFamilies.inter,
    textTheme: _textTheme,
    extensions: const [HikaruTokens.standard],
  );

  static final ColorScheme _darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.champagneGold,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.champagneGold,
        onPrimary: AppColors.darkIndigoBlue,
        primaryContainer: AppColors.matteChampagne,
        onPrimaryContainer: AppColors.champagneGold20,
        secondary: AppColors.matteChampagne,
        onSecondary: AppColors.fog,
        surface: AppColors.darkIndigoBlue,
        onSurface: AppColors.fog,
        onSurfaceVariant: AppColors.indigoBlue40,
        surfaceContainer: AppColors.indigoBlue,
        outline: AppColors.darkIndigoBlue80,
      );

  static final TextTheme _textTheme = const TextTheme(
    headlineLarge: AppTypography.title,
    headlineMedium: AppTypography.subtitle,
    headlineSmall: AppTypography.headline,
    titleLarge: AppTypography.heading,
    labelLarge: AppTypography.subheadline,
    bodyMedium: AppTypography.body,
    bodySmall: AppTypography.footnote,
    labelSmall: AppTypography.bodyAccent,
  ).apply(bodyColor: AppColors.fog, displayColor: AppColors.fog);
}
