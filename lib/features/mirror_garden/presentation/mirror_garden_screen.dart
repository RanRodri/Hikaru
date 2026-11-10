import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/media/remote_image.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/application/reflection_photo_controller.dart';
import 'face_camera_screen.dart';
import 'photo_mirror.dart';

const List<Shadow> _titleShadow = [
  Shadow(color: AppColors.ink80, offset: Offset(0, 2), blurRadius: 8),
];

const List<Shadow> _bodyGlow = [
  Shadow(color: AppColors.ivoryGlow, blurRadius: 12),
];

class MirrorGardenScreen extends ConsumerStatefulWidget {
  const MirrorGardenScreen({super.key, this.initialPreview});

  /// First reflection already chosen, used by tests.
  final Uint8List? initialPreview;

  static const String _backgroundAsset = 'assets/images/mirror_garden.png';
  static const double _headerTop = 72;

  /// The button pair sits as high as the main button on the Listening Room
  /// and Ritual Ready screens.
  static const double _bottomGap = 50;
  static const double _minInsetGap = AppSpacing.s16;
  static const double _horizontalPadding = AppSpacing.s32;

  @override
  ConsumerState<MirrorGardenScreen> createState() => _MirrorGardenScreenState();
}

class _MirrorGardenScreenState extends ConsumerState<MirrorGardenScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _preview;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _preview = widget.initialPreview;
  }

  void _openResonanceChamber() => context.push(AppRoutes.resonanceChamber);

  /// CONTINUE keeps this photo as day 1 of the cycle. Skip leaves no photo.
  /// Either way the crystal recommendation stays as the quiz left it.
  Future<void> _handleContinue() async {
    if (_saving) return;
    final bytes = _preview;
    if (bytes == null || bytes.isEmpty) {
      _openResonanceChamber();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(reflectionPhotoControllerProvider.notifier).capture(bytes);
      if (!mounted) return;
      _openResonanceChamber();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _handleSkip() {
    if (_saving) return;
    _openResonanceChamber();
  }

  Future<void> _takePhoto() async {
    final bytes = await Navigator.of(context, rootNavigator: true)
        .push<Uint8List>(
          MaterialPageRoute(builder: (_) => const FaceCameraScreen()),
        );
    if (!mounted || bytes == null) return;
    setState(() => _preview = bytes);
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _preview = bytes);
    } catch (_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).mirrorPhotoError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final topSpace = math.max(
      MirrorGardenScreen._headerTop,
      insets.top + MirrorGardenScreen._minInsetGap,
    );
    final bottomSpace = math.max(
      MirrorGardenScreen._bottomGap,
      insets.bottom + MirrorGardenScreen._minInsetGap,
    );

    return Scaffold(
      backgroundColor: AppColors.indigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              AppColors.indigoBlue.withValues(alpha: 0.12),
              BlendMode.color,
            ),
            child: const RemoteImage(
              fileName: MirrorGardenScreen._backgroundAsset,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          const _Vignettes(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              MirrorGardenScreen._horizontalPadding,
              topSpace,
              MirrorGardenScreen._horizontalPadding,
              bottomSpace,
            ),
            child: Column(
              children: [
                Opacity(
                  opacity: 0.85,
                  child: Text(
                    l10n.mirrorGardenEyebrow,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.champagneGold,
                      fontSize: AppFontSizes.s10,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
                Text(
                  l10n.mirrorGardenTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s30,
                    height: 1.15,
                    shadows: _titleShadow,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  l10n.mirrorGardenHint,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s13,
                    height: 1.5,
                    letterSpacing: 0.2,
                    shadows: _bodyGlow,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _PhotoChoice(
                        preview: _preview,
                        onTakePhoto: _takePhoto,
                        onUpload: _pickFromGallery,
                      ),
                    ),
                  ),
                ),
                // Two clear choices on one line. Once a photo is chosen the
                // left one becomes CONTINUE; tapping the preview retakes it.
                Row(
                  children: [
                    Expanded(
                      child: _ActionPill(
                        label: _preview == null
                            ? l10n.mirrorTakePhoto
                            : l10n.commonContinue,
                        filled: true,
                        busy: _saving,
                        onPressed: _preview == null
                            ? _takePhoto
                            : _handleContinue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: _ActionPill(
                        label: l10n.mirrorGardenSkip,
                        filled: false,
                        busy: false,
                        onPressed: _saving ? null : _handleSkip,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Vignettes extends StatelessWidget {
  const _Vignettes();

  static const double _bottomHeight = 284;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: _bottomHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.indigoBlue.withValues(alpha: 0),
                    AppColors.indigoBlue.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The mirror with its upload option and the optional note right under it.
class _PhotoChoice extends StatelessWidget {
  const _PhotoChoice({
    required this.preview,
    required this.onTakePhoto,
    required this.onUpload,
  });

  static const double _hintWidth = 270;

  final Uint8List? preview;
  final VoidCallback onTakePhoto;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photo = preview;
    return SizedBox(
      width: _hintWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (photo == null)
            PhotoMirror(onPressed: onTakePhoto)
          else
            _CircularPreview(bytes: photo, onPressed: onTakePhoto),
          const SizedBox(height: AppSpacing.s8),
          _TextAction(label: l10n.mirrorGardenUpload, onPressed: onUpload),
          Text(
            l10n.mirrorGardenOptional,
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s16,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularPreview extends StatelessWidget {
  const _CircularPreview({required this.bytes, required this.onPressed});

  static const double _size = 180;

  final Uint8List bytes;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.mirrorPhotoPreviewSemantics,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.champagneGold, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.mirrorGold, blurRadius: 12),
            ],
          ),
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}

/// One half of the bottom pair: gold filled (main) or gold outline. The label
/// scales down instead of wrapping, since Spanish is longer than English.
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.filled,
    required this.busy,
    required this.onPressed,
  });

  static const double _height = AppSpacing.s52;

  final String label;
  final bool filled;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = filled
        ? AppColors.darkIndigoBlue
        : AppColors.champagneGold;
    final text = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        style: AppTypography.pillLabel.copyWith(color: foreground),
      ),
    );
    const padding = EdgeInsets.symmetric(horizontal: AppSpacing.s8);

    if (!filled) {
      return SizedBox(
        height: _height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding,
            backgroundColor: AppColors.darkIndigoBlue.withValues(alpha: 0.45),
            side: const BorderSide(color: AppColors.champagneGold, width: 1.2),
            shape: const StadiumBorder(),
          ),
          child: text,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_height / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: _height,
        child: FilledButton(
          onPressed: busy ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: padding,
            backgroundColor: AppColors.champagneGold,
            disabledBackgroundColor: AppColors.champagneGold,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.darkIndigoBlue,
                  ),
                )
              : text,
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.champagneGold,
          minimumSize: const Size.fromHeight(AppSpacing.s40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.r8),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s11,
            letterSpacing: 1.65,
          ),
        ),
      ),
    );
  }
}
