import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../domain/library_collection.dart';

class LibraryCollectionCircle extends StatelessWidget {
  const LibraryCollectionCircle({
    super.key,
    required this.collection,
    required this.scale,
  });

  final LibraryCollection collection;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final glowBlur = collection.isHighlighted ? 5.0 : 2.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.black,
        border: Border.all(color: AppColors.champagneGold80),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.7),
            blurRadius: glowBlur * scale,
          ),
        ],
      ),
      child: ClipOval(
        child: Column(
          children: [
            SizedBox(
              height: collection.photoHeight * scale,
              width: double.infinity,
              child: _FadedPhoto(asset: collection.imageAsset),
            ),
            Expanded(child: _CollectionCaption(collection, scale: scale)),
          ],
        ),
      ),
    );
  }
}

class _FadedPhoto extends StatelessWidget {
  const _FadedPhoto({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover, excludeFromSemantics: true),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.transparent, AppColors.black],
              stops: [0.78, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionCaption extends StatelessWidget {
  const _CollectionCaption(this.collection, {required this.scale});

  final LibraryCollection collection;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            collection.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s12 * scale,
              height: 1,
              letterSpacing: 0.2 * scale,
            ),
          ),
          Text(
            collection.inlineDetail,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.footnote.copyWith(
              color: AppColors.fog,
              fontSize: AppFontSizes.s11 * scale,
              height: 1.05,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
