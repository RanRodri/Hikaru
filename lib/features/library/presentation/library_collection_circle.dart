import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../domain/library_collection.dart';

/// A Library collection drawn like the Home access circles: indigo base,
/// gold glow and border, the image fading into indigo and the name below.
class LibraryCollectionCircle extends StatelessWidget {
  const LibraryCollectionCircle({
    super.key,
    required this.collection,
    required this.scale,
  });

  /// Share of the circle height covered by the image before it fades.
  static const double _photoShare = 0.62;

  final LibraryCollection collection;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final diameter = collection.diameter * scale;
    final glowAlpha = collection.isHighlighted ? 0.75 : 0.45;
    final glowBlur = (collection.isHighlighted ? 10 : 6) * scale;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.indigoBlue,
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: glowAlpha),
            blurRadius: glowBlur,
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.champagneGold80,
          width: 0.9 * scale,
        ),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: diameter * _photoShare,
              child: _LitPhoto(
                asset: collection.imageAsset,
                lightBoost: collection.lightBoost,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.transparent, AppColors.indigoBlue],
                    stops: [0.34, 0.6],
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.s8 * scale,
              right: AppSpacing.s8 * scale,
              top: diameter * 0.5,
              bottom: diameter * 0.08,
              child: _CollectionCaption(collection, scale: scale),
            ),
          ],
        ),
      ),
    );
  }
}

class _LitPhoto extends StatelessWidget {
  const _LitPhoto({required this.asset, required this.lightBoost});

  final String asset;
  final double lightBoost;

  /// Saturation, contrast and brightness lift, scaled by [boost], so the
  /// stones glow instead of reading flat at circle size.
  static ColorFilter _lightFilter(double boost) {
    final saturation = 1 + 0.18 * boost;
    final contrast = 1 + 0.05 * boost;
    final shift = 255 * 0.03 * boost + 128 * (1 - contrast);
    const lr = 0.2126;
    const lg = 0.7152;
    const lb = 0.0722;
    final inverse = 1 - saturation;
    final r = lr * inverse;
    final g = lg * inverse;
    final b = lb * inverse;
    return ColorFilter.matrix([
      contrast * (r + saturation), contrast * g, contrast * b, 0, shift, //
      contrast * r, contrast * (g + saturation), contrast * b, 0, shift, //
      contrast * r, contrast * g, contrast * (b + saturation), 0, shift, //
      0, 0, 0, 1, 0, //
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: _lightFilter(lightBoost),
      child: Image.asset(asset, fit: BoxFit.cover, excludeFromSemantics: true),
    );
  }
}

class _CollectionCaption extends StatelessWidget {
  const _CollectionCaption(this.collection, {required this.scale});

  final LibraryCollection collection;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        collection.name,
        textAlign: TextAlign.center,
        softWrap: false,
        style: AppTypography.headline.copyWith(
          color: AppColors.white,
          fontSize: AppFontSizes.s9 * scale,
          height: 1.15,
          letterSpacing: 1.3 * scale,
        ),
      ),
    );
  }
}
