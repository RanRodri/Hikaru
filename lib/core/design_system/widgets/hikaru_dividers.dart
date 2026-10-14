import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class HikaruGoldRule extends StatelessWidget {
  const HikaruGoldRule({
    super.key,
    required this.width,
    required this.height,
    this.opacity = 1,
  });

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: AppColors.champagneGold.withValues(alpha: opacity),
      ),
    );
  }
}

class HikaruGoldDivider extends StatelessWidget {
  const HikaruGoldDivider({
    super.key,
    this.width = AppSpacing.s30,
    this.height = AppSpacing.s2,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.champagneGold,
    );
  }
}

class HikaruGlyphStarDivider extends StatelessWidget {
  const HikaruGlyphStarDivider({super.key, required this.lineWidth});

  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HikaruGoldRule(width: lineWidth, height: AppSpacing.s1, opacity: 0.5),
        const SizedBox(width: AppSpacing.s6),
        Text(
          '✦',
          style: AppTypography.glyphStar.copyWith(
            color: AppColors.champagneGold,
          ),
        ),
        const SizedBox(width: AppSpacing.s6),
        HikaruGoldRule(width: lineWidth, height: AppSpacing.s1, opacity: 0.5),
      ],
    );
  }
}

class HikaruAssetDivider extends StatelessWidget {
  const HikaruAssetDivider({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      fit: BoxFit.fill,
      excludeFromSemantics: true,
    );
  }
}
