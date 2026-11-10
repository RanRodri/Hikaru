import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/biometric_login_controller.dart';
import '../data/biometric_login.dart';

/// Name of the sensor the member sees: Face ID, Touch ID or Fingerprint.
String biometricLabel(AppLocalizations l10n, BiometricKind kind) {
  switch (kind) {
    case BiometricKind.face:
      return l10n.biometricFaceId;
    case BiometricKind.touch:
      return l10n.biometricTouchId;
    case BiometricKind.fingerprint:
      return l10n.biometricFingerprint;
    case BiometricKind.none:
      return '';
  }
}

/// The "Enable Face ID / fingerprint" step that follows any successful
/// password sign-in: after login and also after sign-up and email
/// confirmation, so a new member is asked on their very first session.
extension BiometricOfferFlow on ConsumerState {
  Future<void> offerBiometric(String username, String password) async {
    final controller = ref.read(biometricLoginControllerProvider.notifier);
    final kind = await controller.promptKind(username);
    await controller.keepPassword(username: username, password: password);
    if (!mounted || kind == null) return;
    final l10n = AppLocalizations.of(context);
    final method = biometricLabel(l10n, kind);
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.scrim70,
      builder: (context) => BiometricOfferDialog(kind: kind, method: method),
    );
    if (!mounted) return;
    if (accepted == true) {
      await controller.enable(
        username: username,
        password: password,
        reason: l10n.biometricEnableReason(method),
      );
      return;
    }
    await controller.decline(username);
  }
}

class BiometricOfferDialog extends StatelessWidget {
  const BiometricOfferDialog({
    super.key,
    required this.kind,
    required this.method,
  });

  static const String _faceAsset = 'assets/images/face_id.svg';

  final BiometricKind kind;
  final String method;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final face = kind == BiometricKind.face;
    return Dialog(
      backgroundColor: AppColors.darkIndigoBlue,
      surfaceTintColor: AppColors.darkIndigoBlue,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.r28),
        side: BorderSide(
          color: AppColors.champagneGold.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s32,
          AppSpacing.s24,
          AppSpacing.s12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.champagneGold, width: 1),
              ),
              child: face
                  ? SvgPicture.asset(
                      _faceAsset,
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        AppColors.champagneGold,
                        BlendMode.srcIn,
                      ),
                    )
                  : const Icon(
                      Icons.fingerprint,
                      size: 36,
                      color: AppColors.champagneGold,
                    ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              l10n.biometricOfferTitle(method),
              textAlign: TextAlign.center,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s22,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.s10),
            Text(
              l10n.biometricOfferBody(method),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            HikaruPillButton(
              label: l10n.biometricOfferAccept(method).toUpperCase(),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.champagneGold,
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                l10n.biometricOfferDecline,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: AppFontSizes.s11,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
