import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_face_id_button.dart';
import '../../../core/router/app_routes.dart';
import 'auth_background.dart';
import 'auth_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

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

  void _handleRememberMe() {
    setState(() => _rememberMe = !_rememberMe);
  }

  void _handleSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailLooksValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    final isValid = email.isNotEmpty && emailLooksValid && password.isNotEmpty;

    setState(() {
      _emailError = email.isEmpty
          ? 'Enter your email'
          : emailLooksValid
          ? null
          : 'Enter a valid email';
      _passwordError = password.isEmpty ? 'Enter your password' : null;
    });

    if (!isValid) return;
    context.go(AppRoutes.listeningRoom);
  }

  @override
  Widget build(BuildContext context) {
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
                        'Welcome Home',
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
                        'YOUR JOURNEY TO RADIANT SKIN',
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
                        label: 'Email',
                        hint: 'Enter your email',
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
                        label: 'Password',
                        hint: 'Enter your password',
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
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.resetPassword),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.champagneGold,
                              minimumSize: const Size(44, 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot password?',
                              style: AppTypography.bodyAccent.copyWith(
                                color: AppColors.champagneGold,
                                fontSize: AppFontSizes.s13,
                                letterSpacing: 0,
                                shadows: authTextShadow,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      AuthPillButton(
                        label: 'SIGN IN',
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.darkIndigoBlue,
                        glow: true,
                        onPressed: _handleSignIn,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'or',
                        style: AppTypography.body.copyWith(
                          color: AppColors.fog.withValues(alpha: 0.5),
                          fontSize: AppFontSizes.s14,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),
                      HikaruFaceIdButton(onPressed: () {}),
                      const SizedBox(height: AppSpacing.s8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have a sanctuary? ",
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
                              'Create one',
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
    return Semantics(
      checked: checked,
      label: 'Remember me',
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
                'Remember me',
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
