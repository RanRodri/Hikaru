import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

const List<Shadow> _introShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.6),
    offset: Offset(0, 1),
    blurRadius: 8,
  ),
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
      fontSize: 11,
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
            fontSize: 18,
            height: 1.23,
            letterSpacing: 3.6,
            shadows: _introShadow,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: italicStyle),
        const SizedBox(height: 10),
        const _StarRule(),
        if (introCaption != null) ...[
          const SizedBox(height: 10),
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
      width: 100,
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
