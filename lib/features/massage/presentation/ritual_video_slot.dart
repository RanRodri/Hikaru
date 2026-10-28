import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// Full-screen ritual video, matching the Figma slot behind the sheet.
///
/// [posterAsset] is the still that fills this area. The files are not in the
/// repo yet; dropping one at that path replaces the empty frame.
class RitualVideoSlot extends StatefulWidget {
  const RitualVideoSlot({super.key, required this.posterAsset, this.videoUrl});

  final String posterAsset;
  final String? videoUrl;

  /// Share of the screen the open sheet leaves for the picture in Figma.
  static const double visibleShare = 0.38;

  @override
  State<RitualVideoSlot> createState() => _RitualVideoSlotState();
}

class _RitualVideoSlotState extends State<RitualVideoSlot> {
  bool _posterReady = false;

  @override
  void initState() {
    super.initState();
    _loadPoster();
  }

  @override
  void didUpdateWidget(RitualVideoSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posterAsset != widget.posterAsset) {
      _posterReady = false;
      _loadPoster();
    }
  }

  Future<void> _loadPoster() async {
    final asset = widget.posterAsset;
    try {
      await rootBundle.load(asset);
      if (!mounted || asset != widget.posterAsset) return;
      setState(() => _posterReady = true);
    } catch (_) {
      if (!mounted || asset != widget.posterAsset) return;
      setState(() => _posterReady = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).ritualVideoSemantics,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.1),
            radius: 0.9,
            colors: [
              AppColors.indigoBlue80.withValues(alpha: 0.55),
              AppColors.indigoBlue,
              AppColors.darkIndigoBlue,
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: _posterReady
            ? Image.asset(
                widget.posterAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                excludeFromSemantics: true,
              )
            : const _PosterPlaceholder(),
      ),
    );
  }
}

/// Large empty frame in the band the open sheet leaves visible.
class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final band = constraints.maxHeight * RitualVideoSlot.visibleShare;
        final mark = math.min(constraints.maxWidth * 0.42, band * 0.62);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            height: band,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _PosterMark(side: mark),
                const SizedBox(height: AppSpacing.s10),
                const _PosterLabel(),
                const SizedBox(height: AppSpacing.s16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PosterMark extends StatelessWidget {
  const _PosterMark({required this.side});

  final double side;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.champagneGold80.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
    );
  }
}

class _PosterLabel extends StatelessWidget {
  const _PosterLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).ritualVideoPlaceholder,
      style: AppTypography.footnote.copyWith(
        color: AppColors.fog.withValues(alpha: 0.55),
        fontSize: AppFontSizes.s9,
        letterSpacing: 2.4,
      ),
    );
  }
}
