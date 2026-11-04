import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../data/crystal_tutorial_progress.dart';
import '../data/crystal_tutorial_video_source.dart';

/// Full-screen, portrait, vertical tutorial for one crystal's roller ritual.
///
/// With a signed video it plays, marks the tutorial watched on completion,
/// and fades into a short "ready" screen. Without a video (no key yet, no
/// session, or a resolve failure) it shows a quiet placeholder with the same
/// layout, and never marks the tutorial as watched.
class CrystalTutorialPlayer extends ConsumerStatefulWidget {
  const CrystalTutorialPlayer({
    super.key,
    required this.crystal,
    required this.onContinueToResonance,
    required this.onClose,
  });

  final Crystal crystal;
  final VoidCallback onContinueToResonance;
  final VoidCallback onClose;

  @override
  ConsumerState<CrystalTutorialPlayer> createState() =>
      _CrystalTutorialPlayerState();
}

enum _TutorialStage { loading, placeholder, playing, ready }

class _CrystalTutorialPlayerState
    extends ConsumerState<CrystalTutorialPlayer> {
  static const Duration _readyAutoAdvance = Duration(seconds: 4);

  final CrystalTutorialProgress _progress = CrystalTutorialProgress(
    SharedPreferencesAsync(),
  );
  VideoPlayerController? _controller;
  _TutorialStage _stage = _TutorialStage.loading;
  Timer? _readyTimer;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_resolve());
  }

  Future<void> _resolve() async {
    final request = ++_request;
    final uri = await ref
        .read(crystalTutorialVideoSourceProvider)
        .resolve(widget.crystal);
    if (!mounted || request != _request) return;
    if (uri == null) {
      setState(() => _stage = _TutorialStage.placeholder);
      return;
    }
    final controller = VideoPlayerController.networkUrl(uri);
    try {
      await controller.initialize();
      if (!mounted || request != _request) {
        await controller.dispose();
        return;
      }
      controller.addListener(_handleTick);
      setState(() {
        _controller = controller;
        _stage = _TutorialStage.playing;
      });
      await controller.play();
    } catch (_) {
      await controller.dispose();
      if (!mounted || request != _request) return;
      setState(() => _stage = _TutorialStage.placeholder);
    }
  }

  void _handleTick() {
    final controller = _controller;
    if (controller == null || !mounted) return;
    final value = controller.value;
    if (!value.isInitialized || value.duration == Duration.zero) return;
    if (value.position >= value.duration && _stage == _TutorialStage.playing) {
      unawaited(_finishVideo());
    }
  }

  Future<void> _finishVideo() async {
    await _progress.markWatched(widget.crystal);
    if (!mounted) return;
    setState(() => _stage = _TutorialStage.ready);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _readyTimer?.cancel();
    _readyTimer = Timer(reduceMotion ? Duration.zero : _readyAutoAdvance, () {
      if (mounted) widget.onContinueToResonance();
    });
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _replay() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.seekTo(Duration.zero);
    await controller.play();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _request++;
    _readyTimer?.cancel();
    _controller?.removeListener(_handleTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The crystal screen owns the back button, so there is no PopScope here.
    return ColoredBox(
      color: AppColors.darkIndigoBlue,
      child: SafeArea(
        child: switch (_stage) {
          _TutorialStage.loading => const _TutorialLoading(),
          _TutorialStage.placeholder => _TutorialPlaceholder(
            crystal: widget.crystal,
            onContinue: _continue,
            onClose: widget.onClose,
          ),
          _TutorialStage.playing => _TutorialVideo(
            controller: _controller!,
            onTogglePlayback: _togglePlayback,
            onReplay: _replay,
            onClose: widget.onClose,
          ),
          _TutorialStage.ready => _TutorialReady(onContinue: _continue),
        },
      ),
    );
  }

  /// Moves on to the headphones step. Cancels the automatic advance so the
  /// step is never asked for twice.
  void _continue() {
    _readyTimer?.cancel();
    widget.onContinueToResonance();
  }
}

class _TutorialLoading extends StatelessWidget {
  const _TutorialLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: AppColors.champagneGold,
        ),
      ),
    );
  }
}

/// Shared chrome for both the real player and the placeholder: a close
/// button in the top-left corner.
class _TutorialCloseButton extends StatelessWidget {
  const _TutorialCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).tutorialClose;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: AppSpacing.s24,
        child: Container(
          width: AppSpacing.s36,
          height: AppSpacing.s36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkIndigoBlue.withValues(alpha: 0.45),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.6),
            ),
          ),
          child: const Icon(
            Icons.close_rounded,
            color: AppColors.champagneGold,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _TutorialVideo extends StatelessWidget {
  const _TutorialVideo({
    required this.controller,
    required this.onTogglePlayback,
    required this.onReplay,
    required this.onClose,
  });

  final VideoPlayerController controller;
  final VoidCallback onTogglePlayback;
  final VoidCallback onReplay;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio == 0
                ? 9 / 16
                : controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        Positioned(
          left: AppSpacing.s16,
          top: AppSpacing.s16,
          child: _TutorialCloseButton(onPressed: onClose),
        ),
        Positioned(
          left: AppSpacing.s16,
          right: AppSpacing.s16,
          bottom: AppSpacing.s20,
          child: _TutorialControls(
            controller: controller,
            onTogglePlayback: onTogglePlayback,
            onReplay: onReplay,
          ),
        ),
      ],
    );
  }
}

class _TutorialControls extends StatelessWidget {
  const _TutorialControls({
    required this.controller,
    required this.onTogglePlayback,
    required this.onReplay,
  });

  final VideoPlayerController controller;
  final VoidCallback onTogglePlayback;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final value = controller.value;
        final duration = value.duration;
        final progress = duration == Duration.zero
            ? 0.0
            : (value.position.inMilliseconds / duration.inMilliseconds)
                  .clamp(0.0, 1.0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.s2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: AppColors.champagneGold.withValues(
                  alpha: 0.2,
                ),
                color: AppColors.champagneGold,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TutorialIconButton(
                  icon: Icons.replay_rounded,
                  label: l10n.tutorialReplay,
                  onPressed: onReplay,
                ),
                const SizedBox(width: AppSpacing.s24),
                _TutorialIconButton(
                  icon: value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: value.isPlaying
                      ? l10n.tutorialPause
                      : l10n.tutorialResume,
                  onPressed: onTogglePlayback,
                  size: AppSpacing.s52,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TutorialIconButton extends StatelessWidget {
  const _TutorialIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = AppSpacing.s44,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.champagneGold.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.85),
              width: 0.8,
            ),
          ),
          child: Icon(icon, color: AppColors.champagneGold, size: size * 0.5),
        ),
      ),
    );
  }
}

/// Same layout as the real player, with disabled controls and a quiet note
/// that the video has not arrived yet.
class _TutorialPlaceholder extends StatelessWidget {
  const _TutorialPlaceholder({
    required this.crystal,
    required this.onContinue,
    required this.onClose,
  });

  final Crystal crystal;
  final VoidCallback onContinue;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
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
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.s64,
                height: AppSpacing.s64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.champagneGold80.withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.champagneGold,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.s14),
              Text(
                crystal.localizedName(l10n),
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                l10n.crystalTutorialPendingNote,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.fog.withValues(alpha: 0.55),
                  fontSize: AppFontSizes.s9,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.s16,
          top: AppSpacing.s16,
          child: _TutorialCloseButton(onPressed: onClose),
        ),
        Positioned(
          left: AppSpacing.s24,
          right: AppSpacing.s24,
          bottom: AppSpacing.s24,
          child: Opacity(
            opacity: 0.5,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.s2),
                child: const LinearProgressIndicator(
                  value: 0,
                  minHeight: 2,
                  backgroundColor: AppColors.champagneGold20,
                  color: AppColors.champagneGold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.s24,
          right: AppSpacing.s24,
          bottom: AppSpacing.s52,
          child: HikaruPillButton(
            label: l10n.crystalContinueToResonance,
            onPressed: onContinue,
            buttonHeight: AppSpacing.s52,
          ),
        ),
      ],
    );
  }
}

class _TutorialReady extends StatelessWidget {
  const _TutorialReady({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.crystalTutorialReadyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s18,
                  height: 1.4,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              if (!reduceMotion)
                const SizedBox(
                  width: AppSpacing.s20,
                  height: AppSpacing.s20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.champagneGold,
                  ),
                ),
              const SizedBox(height: AppSpacing.s24),
              HikaruPillButton(
                label: l10n.crystalContinueToResonance,
                onPressed: onContinue,
                buttonHeight: AppSpacing.s52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
