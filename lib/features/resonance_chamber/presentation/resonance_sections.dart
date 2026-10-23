import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_dividers.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../domain/cymatic_audio.dart';
import 'cymatic_audio_loader.dart';
import 'cymatic_signature.dart';

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
        AppLocalizations.of(context).resonanceChamberTitle,
        maxLines: 1,
        style: AppTypography.headline.copyWith(
          color: AppColors.white,
          fontSize: AppFontSizes.s14_5,
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
  fontSize: AppFontSizes.s9,
  height: 1.4,
);

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.label});

  static const double _gap = AppSpacing.s12;
  static const double _minRuleWidth = AppSpacing.s16;

  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: HikaruGoldRule(
              width: double.infinity,
              height: AppSpacing.s0_6,
            ),
          ),
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
                style: _chamberText.copyWith(
                  fontSize: AppFontSizes.s10,
                  letterSpacing: 2.7,
                ),
              ),
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: HikaruGoldRule(
              width: double.infinity,
              height: AppSpacing.s0_6,
            ),
          ),
        ],
      ),
    );
  }
}

class AlignmentTriad extends StatelessWidget {
  const AlignmentTriad({super.key});

  @override
  Widget build(BuildContext context) {
    const divider = HikaruGoldRule(
      width: AppSpacing.s0_6,
      height: double.infinity,
      opacity: 0.7,
    );

    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _FrequencyColumn()),
          SizedBox(width: AppSpacing.s6),
          divider,
          SizedBox(width: AppSpacing.s6),
          Expanded(child: _CymaticColumn()),
          SizedBox(width: AppSpacing.s6),
          divider,
          SizedBox(width: AppSpacing.s6),
          Expanded(child: _RitualColumn()),
        ],
      ),
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
  static const double _gap = AppSpacing.s7;

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

class _FrequencyColumn extends ConsumerWidget {
  const _FrequencyColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value ?? Crystal.jade;
    final l10n = AppLocalizations.of(context);

    return _TriadColumn(
      medallionAsset: 'assets/images/resonance_medallion_frequency.svg',
      label: l10n.resonanceYourFrequency,
      children: [
        Column(
          children: [
            Text(
              crystal.hertzLabel,
              textAlign: TextAlign.center,
              style: _chamberText.copyWith(fontSize: AppFontSizes.s22),
            ),
            const SizedBox(height: AppSpacing.s3),
            Text(
              crystal.localizedFrequencyTagline(l10n),
              textAlign: TextAlign.center,
              style: _chamberText.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s9,
                height: 1.4,
              ),
            ),
          ],
        ),
        _FrequencyWaveform(crystal: crystal),
        Text(
          l10n.crystalCompositionCredit,
          textAlign: TextAlign.center,
          style: _chamberText.copyWith(
            fontSize: AppFontSizes.s9_5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// The loudness of the crystal's composition from start to end, drawn as
/// a gold wave. Falls back to the generic wave until the envelope loads.
class _FrequencyWaveform extends StatelessWidget {
  const _FrequencyWaveform({required this.crystal});

  static const Size _size = Size(89, 41);
  static const int _peaks = 22;

  final Crystal crystal;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CymaticEnvelope?>(
      future: loadCymaticEnvelope(crystal.audioAsset),
      builder: (context, snapshot) {
        final profile = snapshot.data?.loudnessProfile(_peaks) ?? const [];
        if (profile.isEmpty) {
          return SvgPicture.asset(
            'assets/images/resonance_waveform.svg',
            width: _size.width,
            height: _size.height,
          );
        }
        return CustomPaint(
          size: _size,
          painter: _WaveformPainter(profile: profile),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.profile});

  static const double _strokeWidth = 0.75;
  static const double _quietestPeak = 0.15;

  final List<double> profile;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.height / 2;
    final reach = middle - _strokeWidth;
    final step = size.width / (profile.length + 1);
    final points = [
      Offset(0, middle),
      for (var index = 0; index < profile.length; index++)
        Offset(
          step * (index + 1),
          middle -
              (index.isEven ? 1 : -1) *
                  reach *
                  (_quietestPeak + (1 - _quietestPeak) * profile[index]),
        ),
      Offset(size.width, middle),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final handleX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        handleX,
        previous.dy,
        handleX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.champagneGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      !listEquals(oldDelegate.profile, profile);
}

class _CymaticColumn extends ConsumerWidget {
  const _CymaticColumn();

  static const double _signatureSize = 86;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value ?? Crystal.jade;

    return _TriadColumn(
      medallionAsset: 'assets/images/resonance_medallion_cymatic.svg',
      label: AppLocalizations.of(context).resonanceYourCymaticSignature,
      children: [
        SizedBox(
          width: _signatureSize,
          height: _signatureSize,
          child: CymaticSignature(
            crystal: crystal,
            playing: false,
            fillBackground: false,
            semanticLabel: AppLocalizations.of(
              context,
            ).resonanceCymaticSignatureSemantics,
          ),
        ),
      ],
    );
  }
}

class _RitualColumn extends StatelessWidget {
  const _RitualColumn();

  /// The same order for every crystal: regulate, massage, then integrate.
  static List<({String name, String subtitle})> _steps(AppLocalizations l10n) =>
      [
        (
          name: l10n.resonanceStepRegulationName,
          subtitle: l10n.resonanceStepRegulationSubtitle,
        ),
        (
          name: l10n.resonanceStepGuaShaName,
          subtitle: l10n.resonanceStepGuaShaSubtitle,
        ),
        (
          name: l10n.resonanceStepIntegrationName,
          subtitle: l10n.resonanceStepIntegrationSubtitle,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = _steps(l10n);

    return _TriadColumn(
      medallionAsset: 'assets/images/resonance_medallion_ritual.svg',
      label: l10n.resonanceYourRitual,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < steps.length; index++) ...[
                if (index > 0) ...[
                  const SizedBox(height: AppSpacing.s9),
                  HikaruGoldRule(
                    width: AppSpacing.s71,
                    height: AppSpacing.s0_5,
                    opacity: 0.6,
                  ),
                  const SizedBox(height: AppSpacing.s9),
                ],
                _RitualStep(
                  number: index + 1,
                  name: steps[index].name,
                  subtitle: steps[index].subtitle,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RitualStep extends StatelessWidget {
  const _RitualStep({
    required this.number,
    required this.name,
    required this.subtitle,
  });

  static const double _badgeSize = 20;

  final int number;
  final String name;
  final String subtitle;

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
            style: _chamberText.copyWith(fontSize: AppFontSizes.s12, height: 1),
          ),
        ),
        const SizedBox(width: AppSpacing.s6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$name\n'),
                TextSpan(
                  text: subtitle,
                  style: const TextStyle(color: AppColors.fog),
                ),
              ],
            ),
            style: _chamberText.copyWith(
              fontSize: AppFontSizes.s9_5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class CrystalBenefits extends ConsumerWidget {
  const CrystalBenefits({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value ?? Crystal.jade;
    final benefits = crystal.benefits;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        for (var index = 0; index < benefits.length; index++) ...[
          if (index > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s9),
              child: HikaruGoldRule(
                width: double.infinity,
                height: AppSpacing.s0_5,
                opacity: 0.4,
              ),
            ),
          _BenefitRow(
            number: index + 1,
            icon: benefits[index].icon,
            title: crystal.localizedBenefitTitle(l10n, index),
            detail: crystal.localizedBenefitDetail(l10n, index),
          ),
        ],
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.number,
    required this.icon,
    required this.title,
    required this.detail,
  });

  final int number;
  final BenefitIcon icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$number. $title. $detail',
      excludeSemantics: true,
      child: Row(
        children: [
          _BenefitBadge(icon: icon),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. ${title.toUpperCase()}',
                  style: _goldLabel.copyWith(letterSpacing: 1),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  detail,
                  style: _chamberText.copyWith(
                    fontSize: AppFontSizes.s10_5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitBadge extends StatelessWidget {
  const _BenefitBadge({required this.icon});

  static const double _medallionSize = 31;
  static const double _iconSize = 16.43;
  static const String _glowMedallion =
      'assets/images/resonance_medallion_glow.svg';
  static const Map<BenefitIcon, String> _iconAssets = {
    BenefitIcon.mind: 'assets/images/resonance_icon_brain.svg',
    BenefitIcon.heart: 'assets/images/resonance_icon_heart.svg',
    BenefitIcon.flow: 'assets/images/resonance_icon_network.svg',
    BenefitIcon.glow: 'assets/images/resonance_icon_glow.svg',
    BenefitIcon.rhythm: 'assets/images/resonance_icon_calendar.svg',
  };

  final BenefitIcon icon;

  @override
  Widget build(BuildContext context) {
    final iconAsset = _iconAssets[icon];
    if (iconAsset == null) {
      return SvgPicture.asset(
        _glowMedallion,
        width: _medallionSize,
        height: _medallionSize,
      );
    }

    return Container(
      width: _medallionSize,
      height: _medallionSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.champagneGold, width: 0.75),
      ),
      child: SvgPicture.asset(iconAsset, width: _iconSize, height: _iconSize),
    );
  }
}
