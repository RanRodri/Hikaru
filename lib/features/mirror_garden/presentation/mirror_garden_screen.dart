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
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
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

  /// With the skip action under it, CONTINUE sits as high as the main
  /// button on the Listening Garden and Ritual Ready screens.
  static const double _bottomGap = AppSpacing.s30;
  static const double _minInsetGap = AppSpacing.s16;
  static const double _horizontalPadding = AppSpacing.s32;

  @override
  ConsumerState<MirrorGardenScreen> createState() => _MirrorGardenScreenState();
}

class _MirrorGardenScreenState extends ConsumerState<MirrorGardenScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _preview;

  @override
  void initState() {
    super.initState();
    _preview = widget.initialPreview;
  }

  void _openResonanceChamber() => context.push(AppRoutes.resonanceChamber);

  /// CONTINUE keeps this photo as day 1 of the cycle. Skip leaves no photo.
  /// Either way the crystal recommendation stays as the quiz left it.
  Future<void> _handleContinue() async {
    final bytes = _preview;
    if (bytes != null && bytes.isNotEmpty) {
      await ref.read(reflectionPhotoControllerProvider.notifier).capture(bytes);
    }
    if (!mounted) return;
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
                HikaruPillButton(
                  label: l10n.commonContinue,
                  onPressed: _handleContinue,
                ),
                const SizedBox(height: AppSpacing.s8),
                _TextAction(
                  label: l10n.mirrorGardenSkip,
                  onPressed: _openResonanceChamber,
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

  static const double _topHeight = 220;
  static const double _bottomHeight = 284;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _topHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.indigoBlue.withValues(alpha: 0.6),
                    AppColors.indigoBlue.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
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
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.mirrorGardenHint,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s11,
              height: 1.7,
              letterSpacing: 0.55,
              shadows: _bodyGlow,
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
