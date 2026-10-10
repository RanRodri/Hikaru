import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/widgets/radial_glow_background.dart';
import 'splash_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashDestinationProvider, (_, destination) {
      final route = destination.value;
      if (route == null) return;

      context.go(route);
    });

    return const Scaffold(
      body: RadialGlowBackground(child: Center(child: _GlowLogo())),
    );
  }
}

class _GlowLogo extends StatefulWidget {
  const _GlowLogo();

  @override
  State<_GlowLogo> createState() => _GlowLogoState();
}

class _GlowLogoState extends State<_GlowLogo>
    with SingleTickerProviderStateMixin {
  static const AssetImage _logo = AssetImage('assets/images/official_logo.png');
  static const double _logoSize = 280;
  static const Color _highlight = AppColors.splashHighlight;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const Image(
        image: _logo,
        width: _logoSize,
        height: _logoSize,
        fit: BoxFit.contain,
        semanticLabel: 'Hikaru Lift',
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final turn = _controller.value * math.pi * 2;
        final glow = 0.28 + 0.22 * math.sin(turn);

        return SizedBox(
          width: _logoSize,
          height: _logoSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: glow,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: const ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      AppColors.champagneGold,
                      BlendMode.srcIn,
                    ),
                    child: Image(
                      image: _logo,
                      width: _logoSize,
                      height: _logoSize,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              const Image(
                image: _logo,
                width: _logoSize,
                height: _logoSize,
                fit: BoxFit.contain,
                semanticLabel: 'Hikaru Lift',
              ),
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                  final dx = math.cos(turn);
                  final dy = math.sin(turn);
                  return LinearGradient(
                    begin: Alignment(-dx, -dy),
                    end: Alignment(dx, dy),
                    colors: const [
                      AppColors.transparentWhite,
                      _highlight,
                      AppColors.transparentWhite,
                    ],
                    stops: const [0.36, 0.5, 0.64],
                  ).createShader(bounds);
                },
                child: const ColorFiltered(
                  colorFilter: ColorFilter.mode(_highlight, BlendMode.srcIn),
                  child: Image(
                    image: _logo,
                    width: _logoSize,
                    height: _logoSize,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
