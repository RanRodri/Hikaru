import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import 'library_screen.dart';

const String _guideArt = 'assets/images/merkaba_guide';

/// Merkaba entry in the library, laid out as one guide instead of chapters.
class LibraryMerkabaGuide extends StatelessWidget {
  const LibraryMerkabaGuide({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final copy = _MerkabaGuideCopy.of(context);
    final l10n = AppLocalizations.of(context);

    return HikaruScrollPage(
      active: HikaruDestination.library,
      backgroundAsset: libraryBackgroundAsset,
      dimBackground: true,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _BackPill(label: l10n.commonBack, onPressed: onBack),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(copy.eyebrow, textAlign: TextAlign.center, style: _kickerStyle),
        const SizedBox(height: AppSpacing.s6),
        Text(
          copy.title,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s28,
            fontWeight: FontWeight.w500,
            height: 1.05,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(copy.tagline, textAlign: TextAlign.center, style: _kickerStyle),
        const SizedBox(height: AppSpacing.s12),
        const _SceneHero(),
        const SizedBox(height: AppSpacing.s12),
        _Panel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.whatTitle, style: _section),
                    const SizedBox(height: AppSpacing.s8),
                    Text(copy.whatBody, style: _compact),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.benefitsTitle, style: _section),
                    const SizedBox(height: AppSpacing.s8),
                    for (final benefit in copy.benefits) ...[
                      _BenefitRow(icon: benefit.icon, label: benefit.label),
                      const SizedBox(height: AppSpacing.s8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        _Panel(
          child: Column(
            children: [
              Text(copy.elementsTitle, textAlign: TextAlign.center, style: _section),
              const SizedBox(height: AppSpacing.s10),
              _ElementStrip(elements: copy.elements),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        _Panel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.howTitle, style: _section),
                    const SizedBox(height: AppSpacing.s8),
                    Text(copy.howBody, style: _compact),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                flex: 4,
                child: _FieldCompass(
                  spirit: copy.spirit,
                  mind: copy.mind,
                  energy: copy.energy,
                  body: copy.bodyLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.practiceTitle, style: _section),
                    const SizedBox(height: AppSpacing.s8),
                    for (final (index, step) in copy.practice.indexed) ...[
                      _PracticeStep(number: index + 1, label: step),
                      if (index != copy.practice.length - 1)
                        const SizedBox(height: AppSpacing.s6),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        _Panel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text(copy.mudrasTitle, textAlign: TextAlign.center, style: _section),
                    const SizedBox(height: AppSpacing.s8),
                    _MudraRow(mudras: copy.mudras),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      copy.breathTitle,
                      textAlign: TextAlign.center,
                      style: _section,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    _BreathRing(phases: copy.breath),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        _ActivationCard(
          title: copy.guidedTitle,
          minutes: copy.guidedMinutes,
          body: copy.guidedBody,
          semanticsLabel: copy.guidedSemantics,
          onPressed: () => context.push(AppRoutes.merkaba),
        ),
      ],
    );
  }
}

final TextStyle _section = AppTypography.subheadline.copyWith(
  color: AppColors.champagneGold,
  fontSize: AppFontSizes.s11,
  letterSpacing: 1.4,
  height: 1.3,
);

final TextStyle _body = AppTypography.body.copyWith(
  color: AppColors.fog,
  fontSize: AppFontSizes.s13,
  height: 1.5,
  letterSpacing: 0,
);

final TextStyle _compact = AppTypography.body.copyWith(
  color: AppColors.fog,
  fontSize: AppFontSizes.s10,
  height: 1.35,
  letterSpacing: 0,
);

final TextStyle _kickerStyle = AppTypography.subheadline.copyWith(
  color: AppColors.champagneGold.withValues(alpha: 0.8),
  fontSize: AppFontSizes.s10,
  letterSpacing: 1.8,
);

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC0A0B17),
        borderRadius: BorderRadius.circular(AppRadii.r16),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: child,
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  const _BackPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: const Color(0xCC0A0B17),
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.55),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Text(label, style: _section),
          ),
        ),
      ),
    );
  }
}

class _SceneHero extends StatelessWidget {
  const _SceneHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.r16),
      child: Image.asset(
        '$_guideArt/scene.jpg',
        height: 168,
        width: double.infinity,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.8),
            ),
          ),
          child: Icon(icon, color: AppColors.champagneGold, size: 13),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(child: Text(label, style: _compact)),
      ],
    );
  }
}

class _ElementStrip extends StatelessWidget {
  const _ElementStrip({required this.elements});

  final List<_ElementCopy> elements;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final element in elements)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _ElementCard(element: element),
            ),
          ),
      ],
    );
  }
}

class _ElementCard extends StatelessWidget {
  const _ElementCard({required this.element});

  final _ElementCopy element;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            element.asset,
            height: 52,
            width: 52,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          element.name,
          textAlign: TextAlign.center,
          style: _section.copyWith(fontSize: AppFontSizes.s9, letterSpacing: 0.6),
        ),
        Text(
          element.role,
          textAlign: TextAlign.center,
          style: _kickerStyle.copyWith(fontSize: AppFontSizes.s8, letterSpacing: 0.4),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(element.body, textAlign: TextAlign.center, style: _compact),
      ],
    );
  }
}

class _FieldCompass extends StatelessWidget {
  const _FieldCompass({
    required this.spirit,
    required this.mind,
    required this.energy,
    required this.body,
  });

  final String spirit;
  final String mind;
  final String energy;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          spirit,
          textAlign: TextAlign.center,
          style: _section.copyWith(fontSize: AppFontSizes.s8, letterSpacing: 0.6),
        ),
        const SizedBox(height: AppSpacing.s4),
        Row(
          children: [
            Expanded(
              child: Text(
                mind,
                textAlign: TextAlign.center,
                style: _section.copyWith(fontSize: AppFontSizes.s8, letterSpacing: 0.4),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              flex: 3,
              child: Image.asset(
                '$_guideArt/field.jpg',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Text(
                energy,
                textAlign: TextAlign.center,
                style: _section.copyWith(fontSize: AppFontSizes.s8, letterSpacing: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          body,
          textAlign: TextAlign.center,
          style: _section.copyWith(fontSize: AppFontSizes.s8, letterSpacing: 0.6),
        ),
      ],
    );
  }
}

class _PracticeStep extends StatelessWidget {
  const _PracticeStep({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.champagneGold),
          ),
          child: Text(
            '$number',
            style: _section.copyWith(fontSize: AppFontSizes.s8, letterSpacing: 0),
          ),
        ),
        const SizedBox(width: AppSpacing.s6),
        Expanded(child: Text(label, style: _compact)),
      ],
    );
  }
}

class _MudraRow extends StatelessWidget {
  const _MudraRow({required this.mudras});

  final List<_MudraCopy> mudras;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final mudra in mudras)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(alpha: 0.85),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Image.asset(
                            mudra.asset,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    mudra.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _section.copyWith(
                      fontSize: AppFontSizes.s8,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    mudra.meaning,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: _body.copyWith(fontSize: AppFontSizes.s9, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BreathRing extends StatelessWidget {
  const _BreathRing({required this.phases});

  final List<_BreathCopy> phases;

  @override
  Widget build(BuildContext context) {
    final inhale = phases[0];
    final hold = phases[1];
    final exhale = phases[2];

    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CustomPaint(
            size: Size(86, 86),
            painter: _BreathRingPainter(),
          ),
          Align(alignment: const Alignment(0, -1), child: _BreathMark(phase: inhale)),
          Align(alignment: const Alignment(1.05, 0.05), child: _BreathMark(phase: hold)),
          Align(alignment: const Alignment(0, 1), child: _BreathMark(phase: exhale)),
        ],
      ),
    );
  }
}

class _BreathMark extends StatelessWidget {
  const _BreathMark({required this.phase});

  final _BreathCopy phase;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(phase.label, textAlign: TextAlign.center, style: _kickerStyle),
        Text(
          phase.count,
          textAlign: TextAlign.center,
          style: _section.copyWith(fontSize: AppFontSizes.s16, letterSpacing: 0),
        ),
      ],
    );
  }
}

class _BreathRingPainter extends CustomPainter {
  const _BreathRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 3;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.champagneGold.withValues(alpha: 0.9);
    canvas.drawCircle(center, radius, ring);

    final dot = Paint()..color = AppColors.champagneGold;
    for (final turn in [0.0, 0.33, 0.66]) {
      final angle = -1.5708 + turn * 6.2832;
      canvas.drawCircle(
        Offset(center.dx + radius * _cos(angle), center.dy + radius * _sin(angle)),
        3,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double _cos(double radians) => math.cos(radians);

double _sin(double radians) => math.sin(radians);

class _ActivationCard extends StatelessWidget {
  const _ActivationCard({
    required this.title,
    required this.minutes,
    required this.body,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final String title;
  final String minutes;
  final String body;
  final String semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: const Color(0xCC0A0B17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r16),
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  child: Image.asset(
                    '$_guideArt/activation.jpg',
                    width: 112,
                    height: 72,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: _section),
                      const SizedBox(height: AppSpacing.s4),
                      Text(minutes, style: _kickerStyle),
                      const SizedBox(height: AppSpacing.s4),
                      Text(body, style: _body),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitCopy {
  const _BenefitCopy(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ElementCopy {
  const _ElementCopy(this.asset, this.name, this.role, this.body);

  final String asset;
  final String name;
  final String role;
  final String body;
}

class _MudraCopy {
  const _MudraCopy(this.asset, this.name, this.meaning);

  final String asset;
  final String name;
  final String meaning;
}

class _BreathCopy {
  const _BreathCopy(this.count, this.label);

  final String count;
  final String label;
}

class _MerkabaGuideCopy {
  const _MerkabaGuideCopy({
    required this.eyebrow,
    required this.title,
    required this.tagline,
    required this.whatTitle,
    required this.whatBody,
    required this.benefitsTitle,
    required this.benefits,
    required this.elementsTitle,
    required this.elements,
    required this.howTitle,
    required this.howBody,
    required this.spirit,
    required this.mind,
    required this.energy,
    required this.bodyLabel,
    required this.practiceTitle,
    required this.practice,
    required this.mudrasTitle,
    required this.mudras,
    required this.breathTitle,
    required this.breath,
    required this.guidedTitle,
    required this.guidedMinutes,
    required this.guidedBody,
    required this.guidedSemantics,
  });

  final String eyebrow;
  final String title;
  final String tagline;
  final String whatTitle;
  final String whatBody;
  final String benefitsTitle;
  final List<_BenefitCopy> benefits;
  final String elementsTitle;
  final List<_ElementCopy> elements;
  final String howTitle;
  final String howBody;
  final String spirit;
  final String mind;
  final String energy;
  final String bodyLabel;
  final String practiceTitle;
  final List<String> practice;
  final String mudrasTitle;
  final List<_MudraCopy> mudras;
  final String breathTitle;
  final List<_BreathCopy> breath;
  final String guidedTitle;
  final String guidedMinutes;
  final String guidedBody;
  final String guidedSemantics;

  static _MerkabaGuideCopy of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'es' ? _es : _en;
  }
}

const _MerkabaGuideCopy _en = _MerkabaGuideCopy(
  eyebrow: 'HIKARU SANCTUARY',
  title: 'THE MERKABA',
  tagline: 'ACTIVATION  ·  BALANCE  ·  COHERENCE',
  whatTitle: 'WHAT IS THE MERKABA?',
  whatBody:
      'The Merkaba is a sacred geometric field of light that represents the union of body, mind and spirit. It is a multidimensional vehicle of consciousness that helps us return to balance, clarity and inner harmony.',
  benefitsTitle: 'BENEFITS',
  benefits: [
    _BenefitCopy(Icons.spa_outlined, 'Calms the nervous system'),
    _BenefitCopy(Icons.hub_outlined, 'Brings coherence to body and mind'),
    _BenefitCopy(Icons.bolt_outlined, 'Increases energy and vitality'),
    _BenefitCopy(Icons.favorite_border, 'Supports emotional balance'),
    _BenefitCopy(Icons.auto_awesome_outlined, 'Expands intuition and inner guidance'),
  ],
  elementsTitle: 'THE FOUR ELEMENTS',
  elements: [
    _ElementCopy('$_guideArt/fire.jpg', 'FIRE', 'TRANSFORMATION', 'Activates will, clarity and direction.'),
    _ElementCopy('$_guideArt/water.jpg', 'WATER', 'EMOTION', 'Brings flow, healing and receptivity.'),
    _ElementCopy('$_guideArt/air.jpg', 'AIR', 'MENTAL CLARITY', 'Enhances focus, communication and insight.'),
    _ElementCopy('$_guideArt/earth.jpg', 'EARTH', 'GROUNDING', 'Provides stability, nourishment and embodiment.'),
  ],
  howTitle: 'HOW IT WORKS',
  howBody:
      'The Merkaba is created by the counter-rotating fields of two tetrahedrons. This geometric field harmonizes the flow of energy within and around you, connecting you to higher states of awareness.',
  spirit: 'SPIRIT',
  mind: 'MIND',
  energy: 'ENERGY',
  bodyLabel: 'BODY',
  practiceTitle: 'PRACTICE',
  practice: [
    'Find a quiet space',
    'Sit comfortably',
    'Breathe 4 - 4 - 6',
    'Visualize the Merkaba surrounding you',
    'Set your intention',
  ],
  mudrasTitle: 'THE FIVE MUDRAS',
  mudras: [
    _MudraCopy('$_guideArt/gyan.jpg', 'GYAN', 'Wisdom'),
    _MudraCopy('$_guideArt/apana.jpg', 'APANA', 'Release'),
    _MudraCopy('$_guideArt/prana.jpg', 'PRANA', 'Vitality'),
    _MudraCopy('$_guideArt/dhyana.jpg', 'DHYANA', 'Meditation'),
    _MudraCopy('$_guideArt/anjali.jpg', 'ANJALI', 'Connection'),
  ],
  breathTitle: 'BREATHING 4 - 4 - 6',
  breath: [
    _BreathCopy('4', 'INHALE'),
    _BreathCopy('4', 'HOLD'),
    _BreathCopy('6', 'EXHALE'),
  ],
  guidedTitle: 'GUIDED MERKABA ACTIVATION',
  guidedMinutes: '5 MINUTES',
  guidedBody: 'Breath, mudras and visualization to activate your Merkaba.',
  guidedSemantics: 'Start the guided Merkaba activation',
);

const _MerkabaGuideCopy _es = _MerkabaGuideCopy(
  eyebrow: 'SANTUARIO HIKARU',
  title: 'LA MERKABA',
  tagline: 'ACTIVACIÓN  ·  EQUILIBRIO  ·  COHERENCIA',
  whatTitle: '¿QUÉ ES LA MERKABA?',
  whatBody:
      'La Merkaba es un campo geométrico de luz que representa la unión del cuerpo, la mente y el espíritu. Es un vehículo de conciencia que ayuda a volver al equilibrio, la claridad y la armonía interior.',
  benefitsTitle: 'BENEFICIOS',
  benefits: [
    _BenefitCopy(Icons.spa_outlined, 'Calma el sistema nervioso'),
    _BenefitCopy(Icons.hub_outlined, 'Trae coherencia al cuerpo y a la mente'),
    _BenefitCopy(Icons.bolt_outlined, 'Aumenta la energía y la vitalidad'),
    _BenefitCopy(Icons.favorite_border, 'Acompaña el equilibrio emocional'),
    _BenefitCopy(Icons.auto_awesome_outlined, 'Amplía la intuición y la guía interior'),
  ],
  elementsTitle: 'LOS CUATRO ELEMENTOS',
  elements: [
    _ElementCopy('$_guideArt/fire.jpg', 'FUEGO', 'TRANSFORMACIÓN', 'Activa la voluntad, la claridad y la dirección.'),
    _ElementCopy('$_guideArt/water.jpg', 'AGUA', 'EMOCIÓN', 'Trae flujo, sanación y receptividad.'),
    _ElementCopy('$_guideArt/air.jpg', 'AIRE', 'CLARIDAD MENTAL', 'Mejora el enfoque, la comunicación y la percepción.'),
    _ElementCopy('$_guideArt/earth.jpg', 'TIERRA', 'ENRAIZAMIENTO', 'Da estabilidad, nutrición y presencia en el cuerpo.'),
  ],
  howTitle: 'CÓMO FUNCIONA',
  howBody:
      'La Merkaba se crea con los campos de dos tetraedros que giran en sentidos opuestos. Ese campo geométrico armoniza la energía dentro y alrededor de ti, y te conecta con estados más altos de conciencia.',
  spirit: 'ESPÍRITU',
  mind: 'MENTE',
  energy: 'ENERGÍA',
  bodyLabel: 'CUERPO',
  practiceTitle: 'PRÁCTICA',
  practice: [
    'Busca un lugar en silencio',
    'Siéntate con comodidad',
    'Respira 4 - 4 - 6',
    'Visualiza la Merkaba a tu alrededor',
    'Define tu intención',
  ],
  mudrasTitle: 'LOS CINCO MUDRAS',
  mudras: [
    _MudraCopy('$_guideArt/gyan.jpg', 'GYAN', 'Sabiduría'),
    _MudraCopy('$_guideArt/apana.jpg', 'APANA', 'Liberación'),
    _MudraCopy('$_guideArt/prana.jpg', 'PRANA', 'Vitalidad'),
    _MudraCopy('$_guideArt/dhyana.jpg', 'DHYANA', 'Meditación'),
    _MudraCopy('$_guideArt/anjali.jpg', 'ANJALI', 'Conexión'),
  ],
  breathTitle: 'RESPIRACIÓN 4 - 4 - 6',
  breath: [
    _BreathCopy('4', 'INHALA'),
    _BreathCopy('4', 'SOSTÉN'),
    _BreathCopy('6', 'EXHALA'),
  ],
  guidedTitle: 'ACTIVACIÓN GUIADA DE LA MERKABA',
  guidedMinutes: '5 MINUTOS',
  guidedBody: 'Respiración, mudras y visualización para activar tu Merkaba.',
  guidedSemantics: 'Iniciar la activación guiada de la Merkaba',
);
