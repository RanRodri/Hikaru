import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';
import 'crystal_scene_photo.dart';
import 'cymatic_signature.dart';

/// One image: the crystal's photo with its own cymatic plate glowing behind
/// it like an aura.
///
/// The plate is the same [CymaticSignature] used in the projection. Only how
/// it is composited changes: its dark disc is turned transparent, so just the
/// lines of light remain, and the center is masked so the crystal stays in
/// front. It breathes gently, and stays still with reduce motion.
///
/// With [interactive], a gold and indigo light pulses softly around the
/// crystal and touching it makes the light and the waves swell for a moment.
class CrystalCymaticPortrait extends StatefulWidget {
  const CrystalCymaticPortrait({
    super.key,
    required this.crystal,
    this.interactive = false,
    this.touchSemanticLabel,
  });

  final Crystal crystal;
  final bool interactive;

  /// Spoken by screen readers for the touchable crystal.
  final String? touchSemanticLabel;

  /// Plate diameter as a share of the photo's shortest side.
  static const double _plateShare = 0.98;

  /// Strength of the aura over the photo.
  static const double _auraAlpha = 0.85;

  /// Keeps the bright lines and drops the plate's dark, translucent disc:
  /// alpha follows brightness (colors in 0–255, unpremultiplied).
  static const ColorFilter _lightOnly = ColorFilter.matrix([
    1.1, 0, 0, 0, 0, //
    0, 1.1, 0, 0, 0, //
    0, 0, 1.1, 0, 0, //
    0.96, 1.89, 0.35, 0, -40,
  ]);

  /// Transparent over the crystal, full on the rings, soft at the rim.
  static final Gradient _aura = RadialGradient(
    radius: 0.5,
    colors: [
      AppColors.white.withValues(alpha: 0),
      AppColors.white.withValues(alpha: 0),
      AppColors.white.withValues(alpha: _auraAlpha),
      AppColors.white.withValues(alpha: _auraAlpha),
      AppColors.white.withValues(alpha: 0),
    ],
    stops: const [0, 0.44, 0.62, 0.88, 1],
  );

  @override
  State<CrystalCymaticPortrait> createState() => _CrystalCymaticPortraitState();
}

class _CrystalCymaticPortraitState extends State<CrystalCymaticPortrait>
    with TickerProviderStateMixin {
  /// Slow breathing of the halo, the invitation to touch.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  /// The swell after a touch: rises fast, settles slowly.
  late final AnimationController _touch = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  bool _animate = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate = !MediaQuery.disableAnimationsOf(context);
    _syncBreath();
  }

  @override
  void didUpdateWidget(CrystalCymaticPortrait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interactive != widget.interactive) _syncBreath();
  }

  void _syncBreath() {
    if (widget.interactive && _animate) {
      if (!_breath.isAnimating) _breath.repeat(reverse: true);
    } else {
      _breath.stop();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _touch.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!_animate) return;
    _touch.forward(from: 0);
  }

  /// 0 → 1 → 0 over the touch animation, with a quick rise.
  double get _swell {
    final t = _touch.value;
    if (t == 0) return 0;
    return t < 0.25
        ? Curves.easeOut.transform(t / 0.25)
        : 1 - Curves.easeInOut.transform((t - 0.25) / 0.75);
  }

  @override
  Widget build(BuildContext context) {
    final plate = LayoutBuilder(
      builder: (context, box) {
        final side =
            math.min(box.maxWidth, box.maxHeight) *
            CrystalCymaticPortrait._plateShare;
        final cymatic = RepaintBoundary(
          child: CymaticSignature(crystal: widget.crystal, playing: _animate),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            CrystalScenePhoto(crystal: widget.crystal),
            if (widget.interactive)
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_breath, _touch]),
                  builder: (context, _) =>
                      _Halo(side: side, breath: _breath.value, swell: _swell),
                ),
              ),
            IgnorePointer(
              child: ExcludeSemantics(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _touch,
                    // The waves widen and brighten with the touch.
                    builder: (context, child) => Transform.scale(
                      scale: 1 + 0.08 * _swell,
                      child: Opacity(
                        opacity: (0.82 + 0.18 * _swell).clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                    child: SizedBox.square(
                      dimension: side,
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback:
                            CrystalCymaticPortrait._aura.createShader,
                        child: ColorFiltered(
                          colorFilter: CrystalCymaticPortrait._lightOnly,
                          child: cymatic,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!widget.interactive) return plate;
    return Semantics(
      button: true,
      label: widget.touchSemanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: plate,
      ),
    );
  }
}

/// A ring of gold light fading to indigo around the crystal. The center stays
/// clear so the crystal itself is never washed out.
class _Halo extends StatelessWidget {
  const _Halo({required this.side, required this.breath, required this.swell});

  final double side;
  final double breath;
  final double swell;

  @override
  Widget build(BuildContext context) {
    final strength = (0.32 + 0.14 * breath + 0.5 * swell).clamp(0.0, 1.0);
    final size = side * (0.78 + 0.05 * breath + 0.16 * swell);
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.goldGlow.withValues(alpha: 0),
              AppColors.goldGlow.withValues(alpha: strength * 0.55),
              AppColors.champagneGold.withValues(alpha: strength * 0.6),
              AppColors.cymaticIndigoLight.withValues(alpha: strength * 0.4),
              AppColors.indigoBlue.withValues(alpha: 0),
            ],
            stops: const [0, 0.34, 0.48, 0.7, 1],
          ),
        ),
      ),
    );
  }
}
