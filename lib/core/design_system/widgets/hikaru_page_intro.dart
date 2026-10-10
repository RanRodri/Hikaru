import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_font_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

const List<Shadow> _introShadow = [
  Shadow(color: AppColors.scrim60, offset: Offset(0, 1), blurRadius: 8),
];

class HikaruPageIntro extends StatelessWidget {
  const HikaruPageIntro({
    super.key,
    required this.title,
    required this.subtitle,
    this.caption,
  });

  final String title;
  final String subtitle;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final introCaption = caption;
    final italicStyle = AppTypography.footnote.copyWith(
      color: AppColors.white,
      fontSize: AppFontSizes.s11,
      fontStyle: FontStyle.italic,
      letterSpacing: 0.3,
      shadows: _introShadow,
    );

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s18,
            height: 1.23,
            letterSpacing: 3.6,
            shadows: _introShadow,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(subtitle, textAlign: TextAlign.center, style: italicStyle),
        const SizedBox(height: AppSpacing.s10),
        const _StarRule(),
        if (introCaption != null) ...[
          const SizedBox(height: AppSpacing.s10),
          Text(
            introCaption,
            textAlign: TextAlign.center,
            style: italicStyle.copyWith(fontStyle: FontStyle.normal),
          ),
        ],
      ],
    );
  }
}

class _StarRule extends StatelessWidget {
  const _StarRule();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.s100,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 0.45, color: AppColors.champagneGold),
          SvgPicture.asset(
            'assets/images/profile_signature_star.svg',
            width: 10,
            height: 10,
            excludeFromSemantics: true,
          ),
        ],
      ),
    );
  }
}
