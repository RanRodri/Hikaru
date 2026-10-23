import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_dividers.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';

const List<Shadow> _textShadow = [
  Shadow(color: AppColors.scrim75, offset: Offset(0, 1), blurRadius: 8),
];

const Map<Crystal, Offset> _templeCenters = {
  Crystal.whiteQuartz: Offset(194.6, 243),
  Crystal.jade: Offset(79.2, 368.5),
  Crystal.obsidian: Offset(309.2, 368.5),
  Crystal.redJasper: Offset(194.6, 496),
};

class FourTemplesScreen extends StatelessWidget {
  const FourTemplesScreen({super.key});

  static const double _contentHeight = 774;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final insets = MediaQuery.paddingOf(context);
    final availableHeight =
        size.height - HikaruNavigationBar.height - insets.bottom;

    return HikaruShell(
      active: HikaruDestination.home,
      builder: (context, widthScale) {
        final scale = math.min(widthScale, availableHeight / _contentHeight);
        final contentWidth = HikaruShell.designWidth * scale;

        return Positioned(
          top: 0,
          left: (size.width - contentWidth) / 2,
          width: contentWidth,
          height: _contentHeight * scale,
          child: _TemplesContent(scale: scale),
        );
      },
    );
  }
}

class _TemplesContent extends ConsumerWidget {
  const _TemplesContent({required this.scale});

  static const double _templeSize = 128;
  static const double _symbolSize = 50;
  static const Offset _orbitCenter = Offset(194.6, 369);
  static const Size _orbitRadii = Size(115, 126.5);

  final double scale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Quiz recommendation stays fixed; selecting another crystal for sound
    // only updates selectedCrystal and must not move this label.
    final recommended = ref
        .watch(journeyRecommendationControllerProvider)
        .value
        ?.crystal;
    final selected = ref.watch(selectedCrystalProvider).value;
    final headingStyle = AppTypography.headline.copyWith(
      color: AppColors.white,
      shadows: _textShadow,
    );
    final italicStyle = AppTypography.footnote.copyWith(
      color: AppColors.fog,
      fontStyle: FontStyle.italic,
      shadows: _textShadow,
    );

    return Stack(
      children: [
        const Positioned.fill(child: _TemplesScrim()),
        _place(
          Rect.fromCenter(
            center: _orbitCenter,
            width: _orbitRadii.width * 2,
            height: _orbitRadii.height * 2,
          ),
          const IgnorePointer(child: CustomPaint(painter: _OrbitPainter())),
        ),
        _place(
          Rect.fromCenter(
            center: const Offset(194.6, 387.5),
            width: _symbolSize,
            height: _symbolSize,
          ),
          const Image(
            image: AssetImage('assets/images/temple_center_symbol.png'),
            excludeFromSemantics: true,
          ),
        ),
        _place(
          const Rect.fromLTWH(20, 84, 350, 26),
          Text(
            l10n.templesTitle,
            textAlign: TextAlign.center,
            style: headingStyle.copyWith(
              fontSize: AppFontSizes.s21 * scale,
              height: 1.2,
              letterSpacing: 4.2 * scale,
            ),
          ),
        ),
        _place(
          const Rect.fromLTWH(20, 114, 350, 18),
          Text(
            l10n.templesSubtitle,
            textAlign: TextAlign.center,
            style: italicStyle.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s12 * scale,
              letterSpacing: 0.6 * scale,
            ),
          ),
        ),
        _place(
          const Rect.fromLTWH(148, 138, 94, 12),
          const HikaruAssetDivider(
            asset: 'assets/images/temples_star_divider.svg',
          ),
        ),
        for (final MapEntry(key: crystal, value: center)
            in _templeCenters.entries)
          _TempleOption(
            crystal: crystal,
            center: center,
            scale: scale,
            size: _templeSize,
            isRecommended: crystal == recommended,
            isSelected: crystal == selected,
            nameStyle: AppTypography.subheadline.copyWith(
              color: crystal == recommended || crystal == selected
                  ? AppColors.champagneGold
                  : AppColors.white,
              fontSize: AppFontSizes.s9 * scale,
              letterSpacing: 1.8 * scale,
              shadows: _textShadow,
            ),
            templeStyle: italicStyle.copyWith(
              fontSize: AppFontSizes.s9_5 * scale,
            ),
            onPressed: () =>
                context.push(AppRoutes.crystalResonanceFor(crystal.name)),
          ),
        _place(
          const Rect.fromLTWH(20, 702, 350, 14),
          Text(
            l10n.templesChoose,
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s9 * scale,
              letterSpacing: 2.7 * scale,
              shadows: _textShadow,
            ),
          ),
        ),
        _place(
          const Rect.fromLTWH(148, 722, 94, 12),
          const HikaruAssetDivider(
            asset: 'assets/images/temples_star_divider.svg',
          ),
        ),
      ],
    );
  }

  Widget _place(Rect rect, Widget child) {
    return Positioned(
      left: rect.left * scale,
      top: rect.top * scale,
      width: rect.width * scale,
      height: rect.height * scale,
      child: child,
    );
  }
}

class _TempleOption extends StatelessWidget {
  const _TempleOption({
    required this.crystal,
    required this.center,
    required this.scale,
    required this.size,
    required this.isRecommended,
    required this.isSelected,
    required this.nameStyle,
    required this.templeStyle,
    required this.onPressed,
  });

  static const double _labelWidth = 150;
  static const double _labelGap = AppSpacing.s2;

  final Crystal crystal;
  final Offset center;
  final double scale;
  final double size;
  final bool isRecommended;
  final bool isSelected;
  final TextStyle nameStyle;
  final TextStyle templeStyle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final templeSize = size * scale;
    final semanticsExtra = [
      if (isRecommended) l10n.templesSemanticsRecommended,
      if (isSelected) l10n.templesSemanticsSelected,
    ].join(', ');

    return Positioned(
      left: (center.dx - _labelWidth / 2) * scale,
      top: (center.dy - size / 2) * scale,
      width: _labelWidth * scale,
      child: Semantics(
        button: true,
        label: [
          crystal.localizedName(l10n),
          crystal.localizedTemple(l10n),
          if (semanticsExtra.isNotEmpty) semanticsExtra,
        ].join(', '),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              SizedBox(
                width: templeSize,
                height: templeSize,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isRecommended
                            ? [
                                BoxShadow(
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.75,
                                  ),
                                  blurRadius: 18 * scale,
                                ),
                              ]
                            : isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12 * scale,
                                ),
                              ]
                            : null,
                      ),
                      child: Container(
                        width: templeSize,
                        height: templeSize,
                        foregroundDecoration: isRecommended || isSelected
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.champagneGold,
                                  width: (isRecommended ? 1.6 : 1.1) * scale,
                                ),
                              )
                            : null,
                        child: Image.asset(
                          crystal.imageAsset,
                          width: templeSize,
                          height: templeSize,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    if (isRecommended)
                      Padding(
                        padding: EdgeInsets.only(top: 10 * scale),
                        child: _RecommendedBadge(
                          label: l10n.templesRecommended,
                          scale: scale,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: _labelGap * scale),
              Text(
                crystal.localizedName(l10n),
                textAlign: TextAlign.center,
                style: nameStyle,
              ),
              if (isSelected && !isRecommended) ...[
                SizedBox(height: AppSpacing.s2 * scale),
                Text(
                  l10n.templesSelected,
                  textAlign: TextAlign.center,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.champagneGold,
                    fontSize: AppFontSizes.s8 * scale,
                    letterSpacing: 1.4 * scale,
                    shadows: _textShadow,
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.s3 * scale),
              Text(
                crystal.localizedTemple(l10n),
                textAlign: TextAlign.center,
                style: templeStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.85),
          width: 0.6 * scale,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8 * scale,
          vertical: 3.5 * scale,
        ),
        child: Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s7_5 * scale,
            height: 1,
            letterSpacing: 1.15 * scale,
          ),
        ),
      ),
    );
  }
}

class _TemplesScrim extends StatelessWidget {
  const _TemplesScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.05),
            radius: 0.85,
            colors: [
              AppColors.darkIndigoBlue.withValues(alpha: 0.82),
              AppColors.darkIndigoBlue.withValues(alpha: 0.6),
              AppColors.darkIndigoBlue.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawOval(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}
