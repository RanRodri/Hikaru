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
    final hole = _holeFor(context, anchors, _step);

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: CustomPaint(painter: _TourScrimPainter(hole: hole)),
            ),
          ),
          Positioned(
            left: AppSpacing.s20,
            right: AppSpacing.s20,
            bottom:
                HikaruNavigationBar.height +
                MediaQuery.paddingOf(context).bottom +
                AppSpacing.s12,
            child: _TourCard(
              title: copy.title,
              body: copy.body,
              step: _HomeTourStep.values.indexOf(_step),
              count: _HomeTourStep.values.length,
              skipLabel: l10n.homeTourSkip,
              advanceLabel: last ? l10n.homeTourDone : l10n.homeTourNext,
              onSkip: _finish,
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

Rect? _holeFor(
  BuildContext context,
  HomeTourAnchors anchors,
  _HomeTourStep step,
) {
  final overlay = context.findRenderObject();
  if (overlay is! RenderBox || !overlay.hasSize) return null;
  final keys = switch (step) {
    _HomeTourStep.garden => [
      anchors.merkaba,
      anchors.face,
      anchors.body,
      anchors.crystal,
      anchors.library,
      anchors.title,
    ],
    _HomeTourStep.order => [
      anchors.merkaba,
      anchors.face,
      anchors.body,
      anchors.crystal,
    ],
    _HomeTourStep.begin => [anchors.sanctuary],
    _HomeTourStep.bar => [anchors.bar],
  };
  return _union(keys.map((key) => _rectOf(key, overlay)));
}

Rect? _rectOf(GlobalKey key, RenderBox ancestor) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize || !box.attached) return null;
  final topLeft = ancestor.globalToLocal(box.localToGlobal(Offset.zero));
  return topLeft & box.size;
}

Rect? _union(Iterable<Rect?> rects) {
  Rect? hole;
  for (final rect in rects) {
    if (rect == null) continue;
    hole = hole == null ? rect : hole.expandToInclude(rect);
  }
  return hole;
}

class _TourScrimPainter extends CustomPainter {
  const _TourScrimPainter({required this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final veil = Path()..addRect(Offset.zero & size);
    final spot = hole;
    if (spot != null) {
      veil.addRRect(_spotShape(spot));
    }
    veil.fillType = PathFillType.evenOdd;
    canvas.drawPath(
      veil,
      Paint()..color = AppColors.darkIndigoBlue.withValues(alpha: 0.72),
    );
    if (spot == null) return;
    final shape = _spotShape(spot);
    canvas.drawRRect(
      shape,
      Paint()
        ..color = AppColors.goldGlow.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.champagneGold,
    );
  }

  RRect _spotShape(Rect spot) {
    final padded = spot.inflate(AppSpacing.s8);
    final round =
        math.min(padded.width, padded.height) /
            math.max(padded.width, padded.height) >
        0.8;
    final radius = round ? math.min(padded.width, padded.height) / 2 : 22.0;
    return RRect.fromRectAndRadius(padded, Radius.circular(radius));
  }

  @override
  bool shouldRepaint(covariant _TourScrimPainter oldDelegate) =>
      oldDelegate.hole != hole;
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.title,
    required this.body,
    required this.step,
    required this.count,
    required this.skipLabel,
    required this.advanceLabel,
    required this.onSkip,
    required this.onAdvance,
  });

  final String title;
  final String body;
  final int step;
  final int count;
  final String skipLabel;
  final String advanceLabel;
  final VoidCallback onSkip;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadii.r16),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.7),
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.mirrorGold, blurRadius: 18),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s14,
          AppSpacing.s16,
          AppSpacing.s12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold,
                fontSize: AppFontSizes.s11,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              body,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s13,
                height: 1.45,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                _TourTextButton(label: skipLabel, onPressed: onSkip),
                const Spacer(),
                _TourDots(step: step, count: count),
                const SizedBox(width: AppSpacing.s12),
                _TourAdvanceButton(label: advanceLabel, onPressed: onAdvance),
              ],
            ),
          ],
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
