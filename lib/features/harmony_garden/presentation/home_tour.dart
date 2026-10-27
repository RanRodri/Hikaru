import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../data/home_tour_store.dart';

/// Points on Home the first-visit tour can highlight.
class HomeTourAnchors {
  final title = GlobalKey(debugLabel: 'home-tour-title');
  final merkaba = GlobalKey(debugLabel: 'home-tour-merkaba');
  final face = GlobalKey(debugLabel: 'home-tour-face');
  final body = GlobalKey(debugLabel: 'home-tour-body');
  final crystal = GlobalKey(debugLabel: 'home-tour-crystal');
  final library = GlobalKey(debugLabel: 'home-tour-library');
  final sanctuary = GlobalKey(debugLabel: 'home-tour-sanctuary');
  final bar = GlobalKey(debugLabel: 'home-tour-bar');
}

final homeTourAnchorsProvider = Provider<HomeTourAnchors>(
  (ref) => HomeTourAnchors(),
);

enum _HomeTourStep { garden, order, begin, bar }

/// Four-step veil shown the first time Home opens.
class HomeTour extends ConsumerStatefulWidget {
  const HomeTour({super.key});

  @override
  ConsumerState<HomeTour> createState() => _HomeTourState();
}

class _HomeTourState extends ConsumerState<HomeTour> {
  bool? _seen;
  _HomeTourStep _step = _HomeTourStep.garden;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final seen = await ref.read(homeTourStoreProvider).seen();
    if (!mounted) return;
    setState(() => _seen = seen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _finish() async {
    setState(() => _seen = true);
    await ref.read(homeTourStoreProvider).markSeen();
  }

  void _handleNext() {
    final next = _HomeTourStep.values.indexOf(_step) + 1;
    if (next >= _HomeTourStep.values.length) {
      _finish();
      return;
    }
    setState(() => _step = _HomeTourStep.values[next]);
  }

  @override
  Widget build(BuildContext context) {
    if (_seen != false) {
      return const IgnorePointer(child: SizedBox.shrink());
    }

    final l10n = AppLocalizations.of(context);
    final copy = _copy(l10n, _step);
    final last = _step == _HomeTourStep.bar;
    final anchors = ref.watch(homeTourAnchorsProvider);
    final spots = _spotsFor(context, anchors, _step);
    final index = _HomeTourStep.values.indexOf(_step);

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: CustomPaint(painter: _TourScrimPainter(spots: spots)),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppSpacing.s8,
            right: AppSpacing.s8,
            child: _TourTextButton(label: l10n.homeTourSkip, onPressed: _finish),
          ),
          Positioned(
            left: AppSpacing.s20,
            right: AppSpacing.s20,
            bottom:
                HikaruNavigationBar.height +
                MediaQuery.paddingOf(context).bottom +
                AppSpacing.s16,
            child: _TourCard(
              title: copy.title,
              body: copy.body,
              step: index,
              count: _HomeTourStep.values.length,
              advanceLabel: last ? l10n.homeTourDone : l10n.homeTourNext,
              onAdvance: _handleNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _TourCopy {
  const _TourCopy(this.title, this.body);

  final String title;
  final String body;
}

_TourCopy _copy(AppLocalizations l10n, _HomeTourStep step) {
  return switch (step) {
    _HomeTourStep.garden => _TourCopy(
      l10n.homeTourGardenTitle,
      l10n.homeTourGardenBody,
    ),
    _HomeTourStep.order => _TourCopy(
      l10n.homeTourOrderTitle,
      l10n.homeTourOrderBody,
    ),
    _HomeTourStep.begin => _TourCopy(
      l10n.homeTourBeginTitle,
      l10n.homeTourBeginBody,
    ),
    _HomeTourStep.bar => _TourCopy(l10n.homeTourBarTitle, l10n.homeTourBarBody),
  };
}

List<RRect> _spotsFor(
  BuildContext context,
  HomeTourAnchors anchors,
  _HomeTourStep step,
) {
  final overlay = context.findRenderObject();
  if (overlay is! RenderBox || !overlay.hasSize) return const [];
  Rect? rectOf(GlobalKey key) => _rectOf(key, overlay);
  final ritual = [
    rectOf(anchors.merkaba),
    rectOf(anchors.face),
    rectOf(anchors.body),
    rectOf(anchors.crystal),
    rectOf(anchors.library),
  ].nonNulls.toList();

  return switch (step) {
    _HomeTourStep.garden => [if (_orbit(ritual) case final orbit?) orbit],
    _HomeTourStep.order =>
      [
        rectOf(anchors.merkaba),
        rectOf(anchors.face),
        rectOf(anchors.body),
        rectOf(anchors.crystal),
      ].nonNulls.map(_disc).toList(),
    _HomeTourStep.begin => [
      if (rectOf(anchors.sanctuary) case final spot?) _disc(spot),
    ],
    _HomeTourStep.bar => [
      if (rectOf(anchors.bar) case final bar?) _stadium(bar),
    ],
  };
}

Rect? _rectOf(GlobalKey key, RenderBox ancestor) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize || !box.attached) return null;
  final topLeft = ancestor.globalToLocal(box.localToGlobal(Offset.zero));
  return topLeft & box.size;
}

/// One calm circle around the whole orbit, not a box around every widget.
RRect? _orbit(List<Rect> rects) {
  if (rects.isEmpty) return null;
  var center = Offset.zero;
  for (final rect in rects) {
    center += rect.center;
  }
  center = center / rects.length.toDouble();
  var radius = 0.0;
  for (final rect in rects) {
    final reach =
        (rect.center - center).distance + math.max(rect.width, rect.height) / 2;
    if (reach > radius) radius = reach;
  }
  radius += 16;
  return RRect.fromRectAndRadius(
    Rect.fromCircle(center: center, radius: radius),
    Radius.circular(radius),
  );
}

RRect _disc(Rect rect) {
  final radius = math.max(rect.width, rect.height) / 2 + 12;
  return RRect.fromRectAndRadius(
    Rect.fromCircle(center: rect.center, radius: radius),
    Radius.circular(radius),
  );
}

RRect _stadium(Rect rect) {
  final padded = rect.inflate(6);
  return RRect.fromRectAndRadius(
    padded,
    Radius.circular(padded.height / 2),
  );
}

class _TourScrimPainter extends CustomPainter {
  const _TourScrimPainter({required this.spots});

  final List<RRect> spots;

  @override
  void paint(Canvas canvas, Size size) {
    final veil = Path()..addRect(Offset.zero & size);
    for (final spot in spots) {
      veil.addRRect(spot);
    }
    veil.fillType = PathFillType.evenOdd;
    canvas.drawPath(veil, Paint()..color = const Color(0xA6080A14));
    for (final spot in spots) {
      canvas.drawRRect(
        spot,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = AppColors.goldGlow.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawRRect(
        spot,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.champagneGold.withValues(alpha: 0.92),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TourScrimPainter oldDelegate) =>
      oldDelegate.spots != spots;
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.title,
    required this.body,
    required this.step,
    required this.count,
    required this.advanceLabel,
    required this.onAdvance,
  });

  final String title;
  final String body;
  final int step;
  final int count;
  final String advanceLabel;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF210121C),
        borderRadius: BorderRadius.circular(AppRadii.r28),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.28),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.scrim80,
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s20,
          AppSpacing.s24,
          AppSpacing.s16,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey(step),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${step + 1}  /  $count',
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: AppFontSizes.s11,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                title,
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s22,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                body,
                style: AppTypography.body.copyWith(
                  color: AppColors.fog.withValues(alpha: 0.88),
                  fontSize: AppFontSizes.s14,
                  height: 1.45,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              Row(
                children: [
                  _TourDots(step: step, count: count),
                  const Spacer(),
                  _TourAdvanceButton(label: advanceLabel, onPressed: onAdvance),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourDots extends StatelessWidget {
  const _TourDots({required this.step, required this.count});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < count; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.s4),
          Container(
            width: index == step ? AppSpacing.s12 : AppSpacing.s5,
            height: AppSpacing.s5,
            decoration: BoxDecoration(
              color: index == step
                  ? AppColors.champagneGold
                  : AppColors.champagneGold.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
          ),
        ],
      ],
    );
  }
}

class _TourTextButton extends StatelessWidget {
  const _TourTextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.champagneGold60,
          minimumSize: const Size(AppSpacing.s40, AppSpacing.s36),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
        ),
        child: Text(
          label,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold60,
            fontSize: AppFontSizes.s11,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TourAdvanceButton extends StatelessWidget {
  const _TourAdvanceButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.champagneGold,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Text(
              label,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.darkIndigoBlue,
                fontSize: AppFontSizes.s11,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
