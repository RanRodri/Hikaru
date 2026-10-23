import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_journal.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/media/remote_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../mirror_garden/presentation/face_camera_screen.dart';
import '../application/member_profile_controller.dart';
import '../data/member_profile_repository.dart';

class ProfileAccountScreen extends ConsumerStatefulWidget {
  const ProfileAccountScreen({super.key});

  @override
  ConsumerState<ProfileAccountScreen> createState() =>
      _ProfileAccountScreenState();
}

class _ProfileAccountScreenState extends ConsumerState<ProfileAccountScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _name = TextEditingController();
  Uint8List? _photo;
  var _ready = false;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _load(MemberProfile profile) {
    if (_ready) return;
    _name.text = profile.name;
    _photo = profile.photo;
    _ready = true;
  }

  Future<void> _takePhoto() async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const FaceCameraScreen()),
    );
    if (!mounted || bytes == null) return;
    setState(() => _photo = bytes);
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
      setState(() => _photo = bytes);
    } catch (_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).mirrorPhotoError)),
      );
    }
  }

  Future<void> _handleSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    await ref
        .read(memberProfileControllerProvider.notifier)
        .save(name: _name.text, photo: _photo);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(memberProfileControllerProvider).value;
    if (profile != null) _load(profile);
    final insets = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RemoteImage(
            fileName: RemoteImages.sunsetGarden,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkIndigoBlue.withValues(alpha: 0.25),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s8,
                AppSpacing.s24,
                insets.bottom + AppSpacing.s24,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.champagneGold,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.profileAccountClose,
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.champagneGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                Text(
                  l10n.profileAccountTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s16,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  l10n.profileAccountSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog,
                    fontSize: AppFontSizes.s12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
                Center(child: _AccountPhoto(bytes: _photo)),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QuietAction(
                      label: l10n.mirrorTakePhoto,
                      onPressed: _takePhoto,
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    _QuietAction(
                      label: l10n.mirrorGardenUpload,
                      onPressed: _pickFromGallery,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s28),
                Text(
                  l10n.profileAccountName,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.champagneGold,
                    fontSize: AppFontSizes.s9,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s16,
                  ),
                  cursorColor: AppColors.champagneGold,
                  decoration: InputDecoration(
                    hintText: l10n.profileAccountNameHint,
                    hintStyle: AppTypography.headline.copyWith(
                      color: AppColors.fog.withValues(alpha: 0.7),
                      fontSize: AppFontSizes.s16,
                    ),
                    filled: true,
                    fillColor: AppJournal.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppJournal.radius),
                      borderSide: BorderSide(color: AppJournal.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppJournal.radius),
                      borderSide: const BorderSide(
                        color: AppColors.champagneGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
                HikaruPillButton(
                  label: l10n.profileAccountSave,
                  onPressed: _saving ? () {} : _handleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPhoto extends StatelessWidget {
  const _AccountPhoto({required this.bytes});

  static const double _size = 148;

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final photo = bytes;
    return Semantics(
      image: true,
      label: AppLocalizations.of(context).profileAccountPhotoSemantics,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.champagneGold, width: 1.2),
        ),
        child: ClipOval(
          child: photo == null
              ? Image.asset(
                  'assets/images/profile_portrait.png',
                  fit: BoxFit.cover,
                )
              : Image.memory(photo, fit: BoxFit.cover, gaplessPlayback: true),
        ),
      ),
    );
  }
}

class _QuietAction extends StatelessWidget {
  const _QuietAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.champagneGold,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppTypography.subheadline.copyWith(
          color: AppColors.champagneGold,
          fontSize: AppFontSizes.s10,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
