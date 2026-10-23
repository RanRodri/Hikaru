import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_face_id_button.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../application/biometric_login_controller.dart';
import '../data/auth_gateway.dart';
import '../data/biometric_login.dart';
import 'auth_background.dart';
import 'auth_field.dart';

String _biometricLabel(AppLocalizations l10n, BiometricKind kind) {
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _busy = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

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

  Future<void> _offerBiometric(String username, String password) async {
    final controller = ref.read(biometricLoginControllerProvider.notifier);
    final kind = await controller.promptKind(username);
    await controller.keepPassword(username: username, password: password);
    if (!mounted || kind == null) return;
    final l10n = AppLocalizations.of(context);
    final method = _biometricLabel(l10n, kind);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkIndigoBlue,
        title: Text(
          l10n.biometricOfferTitle(method),
          style: AppTypography.headline.copyWith(color: AppColors.white),
        ),
        content: Text(
          l10n.biometricOfferBody(method),
          style: AppTypography.body.copyWith(color: AppColors.fog, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.biometricOfferDecline),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.biometricOfferAccept(method)),
          ),
        ],
      ),
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

  Future<void> _handleBiometricSignIn() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _formError = null;
    });
    try {
      final signedIn = await ref
          .read(biometricLoginControllerProvider.notifier)
          .signIn(reason: l10n.biometricSignInReason);
      if (!mounted || !signedIn) return;
      context.go(AppRoutes.listeningRoom);
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _handleRememberMe() {
    setState(() => _rememberMe = !_rememberMe);
  }

  Future<void> _handleSignIn() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final identity = _emailController.text.trim();
    final password = _passwordController.text;
    final identityValid = identityLooksValid(identity);

    setState(() {
      _formError = null;
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
      await _offerBiometric(identity, password);
      if (!mounted) return;
      context.go(AppRoutes.listeningRoom);
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      if (error.message == 'confirmation-required') {
        context.push(
          AppRoutes.confirmSignUp,
          extra: PendingConfirmation(username: identity, password: password),
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
    final offer = ref.watch(biometricLoginControllerProvider).value;
    final sensorKind = offer != null && offer.showButton ? offer.kind : null;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: AuthBackground(
        overlay: AuthBackground.loginOverlay,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s40,
                  AppSpacing.s0,
                  AppSpacing.s40,
                  bottomPadding > AppSpacing.s16
                      ? bottomPadding
                      : AppSpacing.s16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.16),
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
                      Row(
                        children: [
                          _RememberMe(
                            checked: _rememberMe,
                            onPressed: _handleRememberMe,
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          // Longer in Spanish: shrink the link instead of
                          // overflowing next to "Remember me".
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.resetPassword),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.champagneGold,
                                  minimumSize: const Size(44, 44),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s4,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      AuthPillButton(
                        label: l10n.loginSignIn,
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.darkIndigoBlue,
                        glow: true,
                        onPressed: _handleSignIn,
                      ),
                      if (_formError != null) ...[
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          _formError!,
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: AppColors.fog,
                            fontSize: AppFontSizes.s12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (sensorKind != null) ...[
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          l10n.loginOr,
                          style: AppTypography.body.copyWith(
                            color: AppColors.fog.withValues(alpha: 0.5),
                            fontSize: AppFontSizes.s14,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        HikaruFaceIdButton(
                          label: _biometricLabel(l10n, sensorKind),
                          fingerprint: sensorKind != BiometricKind.face,
                          onPressed: _handleBiometricSignIn,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.loginNoAccount,
                            style: AppTypography.body.copyWith(
                              color: AppColors.fog.withValues(alpha: 0.55),
                              fontSize: AppFontSizes.s12,
                              letterSpacing: 0,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.champagneGold,
                              minimumSize: const Size(44, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.loginCreateOne,
                              style: AppTypography.bodyAccent.copyWith(
                                color: AppColors.champagneGold,
                                fontSize: AppFontSizes.s12,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RememberMe extends StatelessWidget {
  const _RememberMe({required this.checked, required this.onPressed});

  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).loginRememberMe;
    return Semantics(
      checked: checked,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.r5),
                  color: checked
                      ? AppColors.champagneGold
                      : AppColors.darkIndigoBlue.withValues(alpha: 0.5),
                  border: Border.all(
                    color: AppColors.champagneGold,
                    width: 1.5,
                  ),
                ),
                child: checked
                    ? const Icon(
                        Icons.check,
                        size: 15,
                        color: AppColors.darkIndigoBlue,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.s10),
              Text(
                label,
                style: AppTypography.bodyAccent.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s13,
                  letterSpacing: 0,
                  shadows: authTextShadow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
