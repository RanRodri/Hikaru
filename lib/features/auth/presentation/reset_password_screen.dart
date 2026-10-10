import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import 'auth_background.dart';
import 'auth_field.dart';

const List<Shadow> _resetShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    offset: Offset(0, 2),
    blurRadius: 8,
  ),
];

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

  void _handleReset() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final emailLooksValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    setState(() {
      _emailError = email.isEmpty
          ? 'Enter your email'
          : emailLooksValid
          ? null
          : 'Enter a valid email';
      _passwordError = password.isEmpty ? 'Enter new password' : null;
      _confirmError = confirm.isEmpty
          ? 'Confirm your password'
          : confirm == password
          ? null
          : 'Passwords do not match';
    });
  }

  @override
  Widget build(BuildContext context) {
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
              40,
              0,
              40,
              bottomPadding > 16 ? bottomPadding : 16,
            ),
            child: Column(
              children: [
                SizedBox(height: headerSpace),
                Text(
                  'Reset Your\nPassword',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: 34,
                    height: 1.1,
                    shadows: _resetShadow,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "We'll help you regain access\nto your sanctuary.",
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.5,
                    letterSpacing: 0.3,
                    shadows: _resetShadow,
                  ),
                ),
                const SizedBox(height: 36),
                AuthField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: '@',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                  onChanged: _handleEmailChanged,
                ),
                const SizedBox(height: 12),
                AuthField(
                  controller: _passwordController,
                  label: 'New Password',
                  hint: 'Enter new password',
                  icon: '•••',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _passwordError,
                  onChanged: _handlePasswordChanged,
                ),
                const SizedBox(height: 12),
                AuthField(
                  controller: _confirmController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  icon: '•••',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _confirmError,
                  onChanged: _handleConfirmChanged,
                  onSubmitted: (_) => _handleReset(),
                ),
                const SizedBox(height: 28),
                AuthPillButton(
                  label: 'RESET PASSWORD',
                  backgroundColor: AppColors.champagneGold,
                  foregroundColor: AppColors.darkIndigoBlue,
                  onPressed: _handleReset,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: AppTypography.body.copyWith(
                        color: AppColors.fog.withValues(alpha: 0.55),
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
                    TextButton(
                      onPressed: _handleSignIn,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.champagneGold,
                        minimumSize: const Size(44, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign in',
                        style: AppTypography.bodyAccent.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: 12,
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
