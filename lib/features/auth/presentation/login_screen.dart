import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_face_id_button.dart';
import '../../../core/router/app_routes.dart';
import '../../splash/presentation/splash_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../application/biometric_login_controller.dart';
import '../data/auth_gateway.dart';
import '../data/biometric_login.dart';
import 'auth_background.dart';
import 'biometric_offer.dart';
import 'auth_field.dart';
import 'auth_page.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.sessionExpired = false});

  /// Arrived here because Cognito ended the session: tells the member why
  /// and that nothing done meanwhile was lost.
  final bool sessionExpired;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _busy = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  /// Shown until the first sign-in attempt.
  late bool _expiredNotice = widget.sessionExpired;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailChanged(String value) {
    if (_emailError == null) return;
    setState(() => _emailError = null);
  }

  void _handlePasswordChanged(String value) {
    if (_passwordError == null) return;
    setState(() => _passwordError = null);
  }

  Future<void> _handleBiometricSignIn() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _formError = null;
      _expiredNotice = false;
    });
    try {
      final signedIn = await ref
          .read(biometricLoginControllerProvider.notifier)
          .signIn(reason: l10n.biometricSignInReason);
      if (!mounted || !signedIn) return;
      final route = await routeForOpenSession(ref);
      if (!mounted) return;
      context.go(route);
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleSignIn() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final identity = _emailController.text.trim();
    final password = _passwordController.text;
    final identityValid = identityLooksValid(identity);

    setState(() {
      _formError = null;
      _expiredNotice = false;
      _emailError = identity.isEmpty
          ? l10n.authErrorIdentityRequired
          : identityValid
          ? null
          : l10n.authErrorEmailInvalid;
      _passwordError = password.isEmpty ? l10n.authErrorPasswordRequired : null;
    });

    if (!identityValid || password.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authGatewayProvider)
          .signIn(username: identity, password: password);
      if (!mounted) return;
      await offerBiometric(identity, password);
      if (!mounted) return;
      final route = await routeForOpenSession(ref);
      if (!mounted) return;
      context.go(route);
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      if (error.message == 'confirmation-required') {
        context.push(
          AppRoutes.confirmSignUp,
          extra: PendingConfirmation(
            username: identity,
            password: password,
            codeJustSent: false,
          ),
        );
        return;
      }
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notice =
        _formError ?? (_expiredNotice ? l10n.loginSessionExpired : null);
    final offer = ref.watch(biometricLoginControllerProvider).value;
    final sensorKind = offer != null && offer.showButton ? offer.kind : null;
    final topGap = MediaQuery.sizeOf(context).height * 0.16;

    return AuthPage(
      overlay: AuthBackground.loginOverlay,
      content: [
        SizedBox(height: topGap),
        Text(
          l10n.loginTitle,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s34,
            height: 1.2,
            shadows: authTextShadow,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        Text(
          l10n.loginSubtitle,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.fog.withValues(alpha: 0.85),
            letterSpacing: 2,
            shadows: authTextShadow,
          ),
        ),
        const SizedBox(height: AppSpacing.s40),
        AuthField(
          controller: _emailController,
          label: l10n.authIdentityLabel,
          hint: l10n.authIdentityHint,
          icon: '@',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: _emailError,
          onChanged: _handleEmailChanged,
        ),
        const SizedBox(height: AppSpacing.s12),
        AuthField(
          controller: _passwordController,
          label: l10n.authPasswordLabel,
          hint: l10n.authPasswordHint,
          icon: '•••',
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          errorText: _passwordError,
          onChanged: _handlePasswordChanged,
          onSubmitted: (_) => _handleSignIn(),
        ),
        const SizedBox(height: AppSpacing.s14),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _busy
                ? null
                : () => context.push(AppRoutes.resetPassword),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.champagneGold,
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.loginForgotPassword,
                maxLines: 1,
                style: AppTypography.bodyAccent.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: AppFontSizes.s13,
                  letterSpacing: 0,
                  shadows: authTextShadow,
                ),
              ),
            ),
          ),
        ),
        AuthLabeledDivider(label: l10n.loginOr),
        const SizedBox(height: AppSpacing.s16),
        AuthOutlineButton(
          label: l10n.loginCreateAccount,
          onPressed: _busy ? null : () => context.push(AppRoutes.register),
        ),
      ],
      footer: [
        if (notice != null) ...[
          Text(
            notice,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.fog,
              fontSize: AppFontSizes.s12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
        ],
        AuthPillButton(
          label: l10n.loginSignIn,
          backgroundColor: AppColors.champagneGold,
          foregroundColor: AppColors.darkIndigoBlue,
          glow: true,
          busy: _busy,
          onPressed: _handleSignIn,
        ),
        if (sensorKind != null) ...[
          const SizedBox(height: AppSpacing.s12),
          Text(
            l10n.loginOr,
            style: AppTypography.body.copyWith(
              color: AppColors.fog.withValues(alpha: 0.7),
              fontSize: AppFontSizes.s14,
              letterSpacing: 0,
              shadows: authTextShadow,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          HikaruFaceIdButton(
            label: biometricLabel(l10n, sensorKind),
            fingerprint: sensorKind != BiometricKind.face,
            busy: _busy,
            onPressed: _handleBiometricSignIn,
          ),
        ],
      ],
    );
  }
}
