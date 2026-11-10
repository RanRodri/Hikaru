import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_dividers.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';

const List<Shadow> _textShadow = [
  Shadow(color: AppColors.scrim75, offset: Offset(0, 1), blurRadius: 8),
];

/// Crystal names sit over the photo: a darker, wider shadow keeps them
/// readable on her face and on the bright sky.
const List<Shadow> _nameShadow = [
  Shadow(color: AppColors.scrim75, offset: Offset(0, 1), blurRadius: 10),
  Shadow(color: AppColors.scrim75, blurRadius: 18),
];

/// The whole crystal arrangement sits this much lower than the original
/// layout, so White Quartz leaves room for its name above it.
const double _crystalShift = 28;

const Map<Crystal, Offset> _templeCenters = {
  Crystal.whiteQuartz: Offset(194.6, 243 + _crystalShift),
  Crystal.jade: Offset(79.2, 368.5 + _crystalShift),
  Crystal.obsidian: Offset(309.2, 368.5 + _crystalShift),
  Crystal.redJasper: Offset(194.6, 496 + _crystalShift),
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
  static const Offset _orbitCenter = Offset(194.6, 369 + _crystalShift);
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
            center: const Offset(194.6, 387.5 + _crystalShift),
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
              fontSize: AppFontSizes.s13 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2 * scale,
              shadows: _nameShadow,
            ),
            labelAbove: crystal == Crystal.whiteQuartz,
            isDimmed: selected != null && crystal != selected,
            onPressed: () => _handleTempleTap(context, ref, crystal, selected),
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

  /// The current crystal opens its temple. Any other one asks first whether
  /// to switch, so a stray tap never changes the crystal.
  Future<void> _handleTempleTap(
    BuildContext context,
    WidgetRef ref,
    Crystal crystal,
    Crystal? selected,
  ) async {
    if (selected == null || crystal == selected) {
      context.push(AppRoutes.crystalResonanceFor(crystal.name));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim70,
      builder: (context) => _ChangeCrystalDialog(from: selected, to: crystal),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(selectedCrystalProvider.notifier).select(crystal);
    // The 30-day cycle in progress continues with the new crystal.
    await ref
        .read(ritualCycleControllerProvider.notifier)
        .changeCrystal(crystal);
  }
}

/// "Change your crystal?" with the current and the new one.
class _ChangeCrystalDialog extends StatelessWidget {
  const _ChangeCrystalDialog({required this.from, required this.to});

  final Crystal from;
  final Crystal to;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.darkIndigoBlue,
      surfaceTintColor: AppColors.darkIndigoBlue,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.r28),
        side: BorderSide(
          color: AppColors.champagneGold.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s28,
          AppSpacing.s24,
          AppSpacing.s12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.champagneGold),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.champagneGold.withValues(alpha: 0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(to.imageAsset, excludeFromSemantics: true),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              l10n.templesChangeTitle,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s22,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.s10),
            Text(
              l10n.templesChangeBody(
                from.localizedName(l10n),
                to.localizedName(l10n),
              ),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            HikaruPillButton(
              label: l10n.templesChangeConfirm,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.champagneGold,
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                l10n.templesChangeCancel(from.localizedName(l10n)),
                style: AppTypography.body.copyWith(
                  color: AppColors.fog,
                  fontSize: AppFontSizes.s13,
                ),
              ),
            ),
          ],
        ),
      ),
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
    required this.isDimmed,
    required this.nameStyle,
    required this.onPressed,
    this.labelAbove = false,
  });

  static const double _labelWidth = 150;

  /// Room reserved above the circle when the name goes on top: the name
  /// and, when chosen, the "SELECTED" line.
  static const double _labelAboveRoom = 40;

  /// Gray and faint: what a temple that is not the current crystal looks
  /// like. Keeping its colors readable enough to recognize the crystal.
  static const ColorFilter _desaturate = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
  static const double _labelGap = AppSpacing.s2;

  final Crystal crystal;
  final Offset center;
  final double scale;
  final double size;
  final bool isRecommended;
  final bool isSelected;

  /// Another crystal is the current one: this temple looks disabled until
  /// the member confirms switching to it.
  final bool isDimmed;
  final TextStyle nameStyle;
  final VoidCallback onPressed;

  /// The name goes above the circle instead of below. White Quartz uses it
  /// so its name does not land on her face.
  final bool labelAbove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final templeSize = size * scale;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final semanticsExtra = [
      if (isRecommended) l10n.templesSemanticsRecommended,
      if (isSelected) l10n.templesSemanticsSelected,
    ].join(', ');

    final selectedNote = isSelected && !isRecommended
        ? Text(
            l10n.templesSelected,
            textAlign: TextAlign.center,
            style: AppTypography.footnote.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s8 * scale,
              letterSpacing: 1.4 * scale,
              shadows: _textShadow,
            ),
          )
        : null;
    final name = Text(
      crystal.localizedName(l10n),
      textAlign: TextAlign.center,
      style: nameStyle,
    );
    // Above the circle "SELECTED" goes first, so the name stays next to it.
    final labels = [
      if (labelAbove && selectedNote != null) ...[
        selectedNote,
        SizedBox(height: AppSpacing.s2 * scale),
      ],
      name,
      if (!labelAbove && selectedNote != null) ...[
        SizedBox(height: AppSpacing.s2 * scale),
        selectedNote,
      ],
    ];
    final circleTop = center.dy - size / 2;
    return Positioned(
      left: (center.dx - _labelWidth / 2) * scale,
      top: (labelAbove ? circleTop - _labelAboveRoom : circleTop) * scale,
      height: labelAbove ? (_labelAboveRoom + size) * scale : null,
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
          child: AnimatedOpacity(
            opacity: isDimmed ? 0.45 : 1,
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 350),
            child: ColorFiltered(
              colorFilter: isDimmed
                  ? _desaturate
                  : const ColorFilter.mode(
                      AppColors.transparent,
                      BlendMode.dst,
                    ),
              child: Column(
                mainAxisAlignment: labelAbove
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (labelAbove) ...[
                    ...labels,
                    SizedBox(height: AppSpacing.s4 * scale),
                  ],
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
                                      width:
                                          (isRecommended ? 1.6 : 1.1) * scale,
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
                  if (!labelAbove) ...[
                    SizedBox(height: _labelGap * scale),
                    ...labels,
                  ],
                ],
              ),
            ),
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
