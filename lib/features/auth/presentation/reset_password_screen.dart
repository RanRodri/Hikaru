import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../application/biometric_login_controller.dart';
import '../data/auth_gateway.dart';
import 'auth_background.dart';
import 'auth_field.dart';

const List<Shadow> _resetShadow = [
  Shadow(color: AppColors.scrim80, offset: Offset(0, 2), blurRadius: 8),
];

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _busy = false;
  bool _codeSent = false;
  String? _identityError;
  String? _codeError;
  String? _passwordError;
  String? _confirmError;
  String? _formError;

  @override
  void dispose() {
    _identityController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleIdentityChanged(String value) {
    if (_identityError == null && _formError == null) return;
    setState(() {
      _identityError = null;
      _formError = null;
    });
  }

  void _handleCodeChanged(String value) {
    if (_codeError == null) return;
    setState(() => _codeError = null);
  }

  void _handlePasswordChanged(String value) {
    if (_passwordError == null) return;
    setState(() => _passwordError = null);
  }

  void _handleConfirmChanged(String value) {
    if (_confirmError == null) return;
    setState(() => _confirmError = null);
  }

  void _handleSignIn() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.login);
  }

  Future<void> _handleSendCode() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final identity = _identityController.text.trim();
    setState(() {
      _formError = null;
      _identityError = identity.isEmpty
          ? l10n.authErrorIdentityRequired
          : identityLooksValid(identity)
          ? null
          : l10n.authErrorEmailInvalid;
    });
    if (_identityError != null) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(authGatewayProvider)
          .requestPasswordReset(username: identity);
      if (!mounted) return;
      setState(() => _codeSent = true);
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleReset() async {
    if (_busy) return;
    if (!_codeSent) {
      await _handleSendCode();
      return;
    }
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    setState(() {
      _formError = null;
      _codeError = code.isEmpty ? l10n.resetErrorCode : null;
      _passwordError = password.isEmpty
          ? l10n.resetErrorNewPasswordRequired
          : passwordMeetsPolicy(password)
          ? null
          : l10n.authErrorPasswordPolicy;
      _confirmError = confirm.isEmpty
          ? l10n.resetErrorConfirmRequired
          : confirm == password
          ? null
          : l10n.resetErrorMismatch;
    });
    if (_codeError != null || _passwordError != null || _confirmError != null) {
      return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(authGatewayProvider)
          .confirmPasswordReset(
            username: _identityController.text.trim(),
            newPassword: password,
            confirmationCode: code,
          );
      if (!mounted) return;
      await ref.read(biometricLoginControllerProvider.notifier).clear();
      if (!mounted) return;
      _handleSignIn();
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final headerSpace = (200 - topInset).clamp(96.0, 200.0);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: AuthBackground(
        overlay: AuthBackground.resetOverlay,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s40,
              AppSpacing.s0,
              AppSpacing.s40,
              bottomPadding > AppSpacing.s16 ? bottomPadding : AppSpacing.s16,
            ),
            child: Column(
              children: [
                SizedBox(height: headerSpace),
                Text(
                  l10n.resetTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s34,
                    height: 1.1,
                    shadows: _resetShadow,
                  ),
                ),
                const SizedBox(height: AppSpacing.s14),
                Text(
                  _codeSent ? l10n.resetCodeSent : l10n.resetSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog.withValues(alpha: 0.85),
                    fontSize: AppFontSizes.s12,
                    height: 1.5,
                    letterSpacing: 0.3,
                    shadows: _resetShadow,
                  ),
                ),
                const SizedBox(height: AppSpacing.s36),
                AuthField(
                  controller: _identityController,
                  label: l10n.authIdentityLabel,
                  hint: l10n.authIdentityHint,
                  icon: '@',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  errorText: _identityError,
                  onChanged: _handleIdentityChanged,
                ),
                if (_codeSent) ...[
                  const SizedBox(height: AppSpacing.s12),
                  AuthField(
                    controller: _codeController,
                    label: l10n.resetCodeLabel,
                    hint: l10n.resetCodeHint,
                    icon: '#',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    errorText: _codeError,
                    onChanged: _handleCodeChanged,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AuthField(
                    controller: _passwordController,
                    label: l10n.resetNewPasswordLabel,
                    hint: l10n.resetNewPasswordHint,
                    icon: '•••',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    errorText: _passwordError,
                    onChanged: _handlePasswordChanged,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AuthField(
                    controller: _confirmController,
                    label: l10n.resetConfirmLabel,
                    hint: l10n.resetConfirmHint,
                    icon: '•••',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    errorText: _confirmError,
                    onChanged: _handleConfirmChanged,
                    onSubmitted: (_) => _handleReset(),
                  ),
                ],
                const SizedBox(height: AppSpacing.s28),
                AuthPillButton(
                  label: _codeSent ? l10n.resetButton : l10n.resetSendCode,
                  backgroundColor: AppColors.champagneGold,
                  foregroundColor: AppColors.darkIndigoBlue,
                  onPressed: _handleReset,
                ),
                if (_codeSent) ...[
                  const SizedBox(height: AppSpacing.s8),
                  TextButton(
                    onPressed: _handleSendCode,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.champagneGold,
                      minimumSize: const Size(44, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.resetResend,
                      style: AppTypography.bodyAccent.copyWith(
                        color: AppColors.champagneGold,
                        fontSize: AppFontSizes.s12,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
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
                const SizedBox(height: AppSpacing.s24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.resetRemember,
                      style: AppTypography.body.copyWith(
                        color: AppColors.fog.withValues(alpha: 0.55),
                        fontSize: AppFontSizes.s12,
                        letterSpacing: 0,
                      ),
                    ),
                    TextButton(
                      onPressed: _handleSignIn,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.champagneGold,
                        minimumSize: const Size(44, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.resetSignIn,
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
        ),
      ),
    );
  }
}
