import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';

const List<Shadow> _textShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    offset: Offset(0, 1),
    blurRadius: 8,
  ),
];

const List<Shadow> _softTextShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.5),
    offset: Offset(0, 1),
    blurRadius: 8,
  ),
];

class RitualScreen extends StatelessWidget {
  const RitualScreen({super.key});

  static const String _backgroundAsset = 'assets/images/ritual_background.png';

  static const double _horizontalPadding = 28;
  static const double _pathsHeight = 130;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final topPadding = padding.top + 24;
    final bottomPadding = padding.bottom + 8;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage(_backgroundAsset),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _horizontalPadding,
                      topPadding,
                      _horizontalPadding,
                      bottomPadding,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 26),
                        Text(
                          'Your Sanctuary Is\nAlmost Ready',
                          textAlign: TextAlign.center,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.white,
                            fontSize: 25,
                            height: 1.3,
                            letterSpacing: 3.5,
                            shadows: _textShadow,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A sacred tool will elevate your ritual\nand guide you to visible transformation.',
                          textAlign: TextAlign.center,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.fog,
                            fontSize: 12.5,
                            height: 1.45,
                            shadows: _textShadow,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _StarDivider(lineWidth: 64),
                        const SizedBox(height: 10),
                        Text(
                          'CHOOSE YOUR PATH',
                          textAlign: TextAlign.center,
                          style: AppTypography.title.copyWith(
                            color: AppColors.white,
                            fontSize: 13,
                            letterSpacing: 3.3,
                            shadows: _softTextShadow,
                          ),
                        ),
                        const Expanded(child: SizedBox(height: 32)),
                        Column(
                          children: [
                            _FrostedPaths(
                              child: SizedBox(
                                height: _pathsHeight,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _RitualPath(
                                        title: "I DON'T HAVE\nMY HIKARU YET",
                                        actionLabel: 'DISCOVER HIKARU',
                                        onPressed: () {},
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _RitualPath(
                                        title: 'I ALREADY HAVE\nMY HIKARU',
                                        actionLabel: 'BEGIN MY RITUAL',
                                        onPressed: () =>
                                            context.push(AppRoutes.login),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const _StarDivider(lineWidth: 110),
                            const SizedBox(height: 6),
                            Text(
                              'EVERY RITUAL BEGINS WITH INTENTION.\nYOU DESERVE THIS MOMENT.',
                              textAlign: TextAlign.center,
                              style: AppTypography.headline.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontSize: 9,
                                height: 1.7,
                                letterSpacing: 2.2,
                                shadows: _textShadow,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark, blurred veil behind both paths. The mask fades the blur so it
/// dissolves into the photo instead of forming a hard panel.
class _FrostedPaths extends StatelessWidget {
  const _FrostedPaths({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _FadedBlur()),
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: child,
        ),
      ],
    );
  }
}

class _FadedBlur extends StatelessWidget {
  const _FadedBlur();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0, 0.08, 0.92, 1],
        ).createShader(bounds);
      },
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00FFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: [0, 0.18, 0.82, 1],
          ).createShader(bounds);
        },
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: ColoredBox(
              color: AppColors.darkIndigoBlue.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldLine extends StatelessWidget {
  const _GoldLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1,
      color: AppColors.champagneGold.withValues(alpha: 0.5),
    );
  }
}

class _StarDivider extends StatelessWidget {
  const _StarDivider({required this.lineWidth});

  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GoldLine(width: lineWidth),
        const SizedBox(width: 6),
        Text(
          '✦',
          style: AppTypography.body.copyWith(
            color: AppColors.champagneGold,
            fontSize: 8,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 6),
        _GoldLine(width: lineWidth),
      ],
    );
  }
}

class _RitualPath extends StatelessWidget {
  const _RitualPath({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: 12.5,
            height: 1.35,
            letterSpacing: 2,
            shadows: _textShadow,
          ),
        ),
        const SizedBox(height: 28),
        _PathButton(label: actionLabel, onPressed: onPressed),
      ],
    );
  }
}

class _PathButton extends StatelessWidget {
  const _PathButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.headline.copyWith(
      color: AppColors.fog,
      fontSize: 9,
      letterSpacing: 1.6,
    );

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.35),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.champagneGold),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 36,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1, style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
