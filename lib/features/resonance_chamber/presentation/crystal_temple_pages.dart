import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_outline_button.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import 'crystal_scene_photo.dart';

/// Tutorial clip for [crystal]. The file is not in the repo yet.
String crystalTutorialAsset(Crystal crystal) =>
    'assets/videos/crystals/${crystal.name}_tutorial.mp4';

class CrystalTempleEntry extends StatelessWidget {
  const CrystalTempleEntry({
    super.key,
    required this.crystal,
    required this.insets,
    required this.onBack,
    required this.onLibrary,
    required this.onLearn,
    required this.onEnterFrequency,
  });

  final Crystal crystal;
  final EdgeInsets insets;
  final VoidCallback onBack;
  final VoidCallback onLibrary;
  final VoidCallback onLearn;
  final VoidCallback onEnterFrequency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s24,
        insets.top + AppSpacing.s8,
        AppSpacing.s24,
        insets.bottom + AppSpacing.s16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _GoldTextButton(label: l10n.commonBack, onPressed: onBack),
              const Spacer(),
              Semantics(
                button: true,
                label: l10n.crystalLibrarySemantics,
                child: IconButton(
                  onPressed: onLibrary,
                  icon: const Icon(
                    Icons.info_outline,
                    color: AppColors.champagneGold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            crystal.localizedName(l10n),
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s28,
              height: 1.1,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            crystal.localizedTemple(l10n),
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s12,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Expanded(child: CrystalScenePhoto(crystal: crystal)),
          Text(
            crystal.hertzLabel,
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s28,
              fontWeight: FontWeight.w300,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            l10n.crystalAwakenLine,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.fog,
              fontSize: AppFontSizes.s14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          HikaruPillButton(label: l10n.crystalLearnRitual, onPressed: onLearn),
          const SizedBox(height: AppSpacing.s12),
          HikaruOutlineButton(
            label: l10n.crystalEnterFrequency,
            onPressed: onEnterFrequency,
          ),
        ],
      ),
    );
  }
}

class CrystalTutorialPage extends StatefulWidget {
  const CrystalTutorialPage({
    super.key,
    required this.crystal,
    required this.insets,
    required this.onBack,
    required this.onFinished,
  });

  final Crystal crystal;
  final EdgeInsets insets;
  final VoidCallback onBack;
  final VoidCallback onFinished;

  @override
  State<CrystalTutorialPage> createState() => _CrystalTutorialPageState();
}

class _CrystalTutorialPageState extends State<CrystalTutorialPage> {
  bool _paused = false;
  bool _ready = false;
  bool _videoExists = false;

  String get _asset => crystalTutorialAsset(widget.crystal);

  @override
  void initState() {
    super.initState();
    _lookForVideo();
  }

  Future<void> _lookForVideo() async {
    try {
      await rootBundle.load(_asset);
      if (!mounted) return;
      setState(() => _videoExists = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _videoExists = false;
        _ready = true;
      });
    }
  }

  void _repeat() {
    setState(() {
      _paused = false;
      _ready = !_videoExists;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s24,
        widget.insets.top + AppSpacing.s8,
        AppSpacing.s24,
        widget.insets.bottom + AppSpacing.s16,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _GoldTextButton(
              label: l10n.commonBack,
              onPressed: widget.onBack,
            ),
          ),
          Text(
            widget.crystal.localizedName(l10n),
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s18,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.indigoBlue,
                borderRadius: BorderRadius.circular(AppSpacing.s16),
                border: Border.all(
                  color: AppColors.champagneGold.withValues(alpha: 0.45),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Text(
                    _asset,
                    textAlign: TextAlign.center,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.fog,
                      fontSize: AppFontSizes.s12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundControl(
                label: _paused
                    ? l10n.crystalTutorialPlay
                    : l10n.crystalTutorialPause,
                icon: _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                onPressed: () => setState(() => _paused = !_paused),
              ),
              const SizedBox(width: AppSpacing.s16),
              _RoundControl(
                label: l10n.crystalTutorialRepeat,
                icon: Icons.replay_rounded,
                onPressed: _repeat,
              ),
              const SizedBox(width: AppSpacing.s16),
              _RoundControl(
                label: l10n.crystalTutorialContinue,
                icon: Icons.check_rounded,
                onPressed: () => setState(() => _ready = true),
              ),
            ],
          ),
          if (_ready) ...[
            const SizedBox(height: AppSpacing.s20),
            Text(
              l10n.crystalTutorialReady,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            HikaruPillButton(
              label: l10n.crystalContinueResonance,
              onPressed: widget.onFinished,
            ),
          ],
        ],
      ),
    );
  }
}

class CrystalCoherenceClose extends StatelessWidget {
  const CrystalCoherenceClose({
    super.key,
    required this.crystal,
    required this.insets,
    required this.onComplete,
    required this.onExplore,
  });

  final Crystal crystal;
  final EdgeInsets insets;
  final VoidCallback onComplete;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s24,
        insets.top + AppSpacing.s24,
        AppSpacing.s24,
        insets.bottom + AppSpacing.s16,
      ),
      child: Column(
        children: [
          Text(
            crystal.localizedName(l10n),
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s22,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            crystal.localizedTemple(l10n),
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s12,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Expanded(child: CrystalScenePhoto(crystal: crystal)),
          Text(
            l10n.crystalReturnCoherence,
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s22,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.crystalCarryHarmony,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.fog,
              fontSize: AppFontSizes.s14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          HikaruPillButton(
            label: l10n.crystalCompleteRitual,
            onPressed: onComplete,
          ),
          const SizedBox(height: AppSpacing.s12),
          HikaruOutlineButton(
            label: l10n.crystalExploreTemple,
            onPressed: onExplore,
          ),
        ],
      ),
    );
  }
}

class _GoldTextButton extends StatelessWidget {
  const _GoldTextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.subheadline.copyWith(
          color: AppColors.champagneGold,
          fontSize: AppFontSizes.s11,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.champagneGold),
          ),
          child: Icon(icon, color: AppColors.champagneGold),
        ),
      ),
    );
  }
}
