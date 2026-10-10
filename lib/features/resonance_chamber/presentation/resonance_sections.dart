import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';

final Color resonanceChamberColor = Color.alphaBlend(
  AppColors.indigoBlue.withValues(alpha: 0.7),
  AppColors.darkIndigoBlue,
);

final TextStyle _chamberText = AppTypography.headline.copyWith(
  color: AppColors.white,
  letterSpacing: 0,
);

class ChamberTitle extends StatelessWidget {
  const ChamberTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        'THE RESONANCE CHAMBER',
        maxLines: 1,
        style: AppTypography.headline.copyWith(
          color: AppColors.white,
          fontSize: 14.5,
          letterSpacing: 3.77,
        ),
      ),
    );
  }
}

class ChamberScrollView extends StatelessWidget {
  const ChamberScrollView({
    super.key,
    required this.padding,
    required this.children,
  });

  static const double _fadeFraction = 0.06;

  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.white.withValues(alpha: 0),
          AppColors.white,
          AppColors.white,
          AppColors.white.withValues(alpha: 0),
        ],
        stops: const [0, _fadeFraction, 1 - _fadeFraction, 1],
      ).createShader(bounds),
      child: SingleChildScrollView(
        padding: padding,
        child: Column(children: children),
      ),
    );
  }
}

final TextStyle _goldLabel = _chamberText.copyWith(
  color: AppColors.champagneGold,
  fontSize: 9,
  height: 1.4,
);

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.label});

  static const double _gap = 12;
  static const double _minRuleWidth = 16;

  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          const Expanded(child: _GoldRule.horizontal()),
          const SizedBox(width: _gap),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth - 2 * (_gap + _minRuleWidth),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: _chamberText.copyWith(fontSize: 10, letterSpacing: 2.7),
              ),
            ),
          ),
          const SizedBox(width: _gap),
          const Expanded(child: _GoldRule.horizontal()),
        ],
      ),
    );
  }
}

class _GoldRule extends StatelessWidget {
  const _GoldRule.horizontal()
    : width = double.infinity,
      height = 0.6,
      opacity = 1;

  const _GoldRule.vertical({required this.height, this.opacity = 0.7})
    : width = 0.6;

  const _GoldRule.stepSeparator() : width = 71, height = 0.5, opacity = 0.6;

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

class AlignmentTriad extends StatelessWidget {
  const AlignmentTriad({super.key});

  static const double _dividerHeight = 160;

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _FrequencyColumn()),
        SizedBox(width: 6),
        _GoldRule.vertical(height: _dividerHeight),
        SizedBox(width: 6),
        Expanded(child: _CymaticColumn()),
        SizedBox(width: 6),
        _GoldRule.vertical(height: _dividerHeight),
        SizedBox(width: 6),
        Expanded(child: _RitualColumn()),
      ],
    );
  }
}

class _TriadColumn extends StatelessWidget {
  const _TriadColumn({
    required this.medallionAsset,
    required this.label,
    required this.children,
  });

  static const double _medallionSize = 35;
  static const double _gap = 7;

  final String medallionAsset;
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          medallionAsset,
          width: _medallionSize,
          height: _medallionSize,
        ),
        const SizedBox(height: _gap),
        Text(label, textAlign: TextAlign.center, style: _goldLabel),
        for (final child in children) ...[const SizedBox(height: _gap), child],
      ],
    );
  }
}

class _FrequencyColumn extends StatelessWidget {
  const _FrequencyColumn();

  @override
  Widget build(BuildContext context) {
    return _TriadColumn(
      medallionAsset: 'assets/images/resonance_medallion_frequency.svg',
      label: 'YOUR FREQUENCY',
      children: [
        Text('528 Hz', style: _chamberText.copyWith(fontSize: 22)),
        SvgPicture.asset(
          'assets/images/resonance_waveform.svg',
          width: 89,
          height: 41,
        ),
        Text(
          'Composed by\nMaestro Jorge Alfano',
          textAlign: TextAlign.center,
          style: _chamberText.copyWith(fontSize: 9.5, height: 1.4),
        ),
      ],
    );
  }
}

class _CymaticColumn extends StatelessWidget {
  const _CymaticColumn();

  @override
  Widget build(BuildContext context) {
    return _TriadColumn(
      medallionAsset: 'assets/images/resonance_medallion_cymatic.svg',
      label: 'YOUR CYMATIC\nSIGNATURE',
      children: [
        SvgPicture.asset(
          'assets/images/resonance_cymatic_signature.svg',
          width: 86,
          height: 86,
          semanticsLabel: 'Your cymatic signature',
        ),
      ],
    );
  }
}

class _RitualColumn extends StatelessWidget {
  const _RitualColumn();

  static const List<String> _steps = [
    'Regulation\nMerkaba',
    'Gua Sha\nPhysical Massage',
    'Frequency &\nCymatics Integration',
  ];

  @override
  Widget build(BuildContext context) {
    return _TriadColumn(
      medallionAsset: 'assets/images/resonance_medallion_ritual.svg',
      label: 'YOUR RITUAL',
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < _steps.length; index++) ...[
                if (index > 0) ...[
                  const SizedBox(height: 9),
                  const _GoldRule.stepSeparator(),
                  const SizedBox(height: 9),
                ],
                _RitualStep(number: index + 1, label: _steps[index]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RitualStep extends StatelessWidget {
  const _RitualStep({required this.number, required this.label});

  static const double _badgeSize = 20;

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _badgeSize,
          height: _badgeSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.champagneGold, width: 0.6),
          ),
          child: Text(
            '$number',
            style: _chamberText.copyWith(fontSize: 12, height: 1),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: _chamberText.copyWith(fontSize: 9.5, height: 1.45),
          ),
        ),
      ],
    );
  }
}

typedef _Benefit = ({
  String? icon,
  String? medallion,
  String title,
  String detail,
});

class CrystalBenefits extends StatelessWidget {
  const CrystalBenefits({super.key});

  static const List<_Benefit> _benefits = [
    (
      icon: 'assets/images/resonance_icon_brain.svg',
      medallion: null,
      title: '1. NERVOUS SYSTEM\nREGULATION',
      detail: '& Stress\nReduction',
    ),
    (
      icon: 'assets/images/resonance_icon_heart.svg',
      medallion: null,
      title: '2. MIND-HEART\nCOHERENCE',
      detail: '& Emotional\nBalance',
    ),
    (
      icon: 'assets/images/resonance_icon_network.svg',
      medallion: null,
      title: '3. CELLULAR\nVITALITY',
      detail: '& Renewal\nSupport',
    ),
    (
      icon: null,
      medallion: 'assets/images/resonance_medallion_glow.svg',
      title: '4. NATURAL GLOW',
      detail: '& Skin Firmness\nEnhancement',
    ),
    (
      icon: 'assets/images/resonance_icon_calendar.svg',
      medallion: null,
      title: '5. DAILY HABIT\nRHYTHM',
      detail: 'That Deepens\nOver Time',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < _benefits.length; index++) ...[
          if (index > 0)
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: _GoldRule.vertical(height: 70, opacity: 0.6),
            ),
          Expanded(child: _BenefitColumn(benefit: _benefits[index])),
        ],
      ],
    );
  }
}

class _BenefitColumn extends StatelessWidget {
  const _BenefitColumn({required this.benefit});

  static const double _medallionSize = 31;
  static const double _iconSize = 16.43;
  static const double _titleHeight = 24;

  final _Benefit benefit;

  @override
  Widget build(BuildContext context) {
    final medallion = benefit.medallion;
    final icon = benefit.icon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          if (medallion != null)
            SvgPicture.asset(
              medallion,
              width: _medallionSize,
              height: _medallionSize,
            )
          else
            Container(
              width: _medallionSize,
              height: _medallionSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.champagneGold, width: 0.75),
              ),
              child: SvgPicture.asset(
                icon!,
                width: _iconSize,
                height: _iconSize,
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            height: _titleHeight,
            child: Text(
              benefit.title,
              textAlign: TextAlign.center,
              style: _chamberText.copyWith(fontSize: 7.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            benefit.detail,
            textAlign: TextAlign.center,
            style: _chamberText.copyWith(fontSize: 9, height: 1.4),
          ),
        ],
      ),
    );
  }
}
