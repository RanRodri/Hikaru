import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import 'auth_background.dart';
import 'auth_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _birthdayError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _handleNameChanged(String value) {
    if (_nameError == null) return;
    setState(() => _nameError = null);
  }

  void _handleEmailChanged(String value) {
    if (_emailError == null) return;
    setState(() => _emailError = null);
  }

  void _handlePasswordChanged(String value) {
    if (_passwordError == null) return;
    setState(() => _passwordError = null);
  }

  Future<void> _handleBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.champagneGold,
              onPrimary: AppColors.darkIndigoBlue,
              surface: AppColors.darkIndigoBlue,
              onSurface: AppColors.white,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null || !mounted) return;

    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    setState(() {
      _birthdayController.text = '$month / $day / ${picked.year}';
      _birthdayError = null;
    });
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.login);
  }

  void _handleContinue() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final birthday = _birthdayController.text.trim();
    final emailLooksValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    setState(() {
      _nameError = name.isEmpty ? 'Enter your full name' : null;
      _emailError = email.isEmpty
          ? 'Enter your email'
          : emailLooksValid
          ? null
          : 'Enter a valid email';
      _passwordError = password.isEmpty ? 'Enter your password' : null;
      _birthdayError = birthday.isEmpty ? 'Select your birthday' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: AuthBackground(
        overlay: AuthBackground.loginOverlay,
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
                const SizedBox(height: AppSpacing.s100),
                Text(
                  'Create Your\nSanctuary',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s34,
                    height: 1.15,
                    shadows: authTextShadow,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Lets begin with essentials to\npersonalize your experience.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog.withValues(alpha: 0.85),
                    fontSize: AppFontSizes.s12,
                    height: 1.5,
                    letterSpacing: 0.3,
                    shadows: authTextShadow,
                  ),
                ),
                const SizedBox(height: AppSpacing.s18),
                AuthField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Your full name',
                  icon: 'A',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  errorText: _nameError,
                  onChanged: _handleNameChanged,
                ),
                const SizedBox(height: AppSpacing.s10),
                AuthField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@domain.com',
                  icon: '@',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                  onChanged: _handleEmailChanged,
                ),
                const SizedBox(height: AppSpacing.s10),
                AuthField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  icon: '•••',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _passwordError,
                  onChanged: _handlePasswordChanged,
                ),
                const SizedBox(height: AppSpacing.s10),
                AuthField(
                  controller: _birthdayController,
                  label: 'Birthday',
                  hint: 'MM / DD / YYYY',
                  icon: '☆',
                  readOnly: true,
                  onTap: _handleBirthday,
                  errorText: _birthdayError,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.s22),
                AuthPillButton(
                  label: 'CONTINUE',
                  backgroundColor: AppColors.champagneGold,
                  foregroundColor: AppColors.darkIndigoBlue,
                  glow: true,
                  onPressed: _handleContinue,
                ),
                const SizedBox(height: AppSpacing.s16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.body.copyWith(
                        color: AppColors.fog.withValues(alpha: 0.55),
                        fontSize: AppFontSizes.s12,
                        letterSpacing: 0,
                      ),
                    ),
                    TextButton(
                      onPressed: _handleBack,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.champagneGold,
                        minimumSize: const Size(44, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Log in',
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
