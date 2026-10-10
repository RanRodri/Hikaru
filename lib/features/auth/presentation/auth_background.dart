import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.overlay, required this.child});

  static const String asset = 'assets/images/login_background.png';

  final LinearGradient overlay;
  final Widget child;

  static LinearGradient get loginOverlay => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.indigoBlue.withValues(alpha: 0.25),
      AppColors.indigoBlue.withValues(alpha: 0.35),
      AppColors.indigoBlue.withValues(alpha: 0.2),
      AppColors.indigoBlue.withValues(alpha: 0.05),
      AppColors.indigoBlue.withValues(alpha: 0),
      AppColors.indigoBlue.withValues(alpha: 0.15),
      AppColors.indigoBlue.withValues(alpha: 0.4),
      AppColors.indigoBlue.withValues(alpha: 0.65),
      AppColors.indigoBlue.withValues(alpha: 0.8),
      AppColors.indigoBlue.withValues(alpha: 0.85),
    ],
    stops: const [0, 0.1, 0.25, 0.4, 0.5, 0.6, 0.72, 0.84, 0.94, 1],
  );

  static LinearGradient get resetOverlay => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.darkIndigoBlue.withValues(alpha: 0.35),
      AppColors.darkIndigoBlue.withValues(alpha: 0.5),
      AppColors.darkIndigoBlue.withValues(alpha: 0.42),
      AppColors.darkIndigoBlue.withValues(alpha: 0.2),
      AppColors.darkIndigoBlue.withValues(alpha: 0.05),
      AppColors.darkIndigoBlue.withValues(alpha: 0),
      AppColors.darkIndigoBlue.withValues(alpha: 0.1),
      AppColors.darkIndigoBlue.withValues(alpha: 0.4),
      AppColors.darkIndigoBlue.withValues(alpha: 0.62),
      AppColors.darkIndigoBlue.withValues(alpha: 0.75),
      AppColors.darkIndigoBlue.withValues(alpha: 0.82),
      AppColors.darkIndigoBlue.withValues(alpha: 0.85),
    ],
    stops: const [
      0,
      0.12,
      0.22,
      0.32,
      0.42,
      0.5,
      0.58,
      0.66,
      0.74,
      0.82,
      0.9,
      1,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Image(
          image: AssetImage(asset),
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
        DecoratedBox(decoration: BoxDecoration(gradient: overlay)),
        child,
      ],
    );
  }
}
