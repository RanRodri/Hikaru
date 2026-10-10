import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
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
                  40,
                  0,
                  40,
                  bottomPadding > 16 ? bottomPadding : 16,
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
                          fontSize: 34,
                          height: 1.2,
                          shadows: authTextShadow,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'YOUR JOURNEY TO RADIANT SKIN',
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.fog.withValues(alpha: 0.85),
                          letterSpacing: 2,
                          shadows: authTextShadow,
                        ),
                      ),
                      const SizedBox(height: 40),
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
                      const SizedBox(height: 14),
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
                                horizontal: 4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot password?',
                              style: AppTypography.bodyAccent.copyWith(
                                color: AppColors.champagneGold,
                                fontSize: 13,
                                letterSpacing: 0,
                                shadows: authTextShadow,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AuthPillButton(
                        label: 'SIGN IN',
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.darkIndigoBlue,
                        glow: true,
                        onPressed: _handleSignIn,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'or',
                        style: AppTypography.body.copyWith(
                          color: AppColors.fog.withValues(alpha: 0.5),
                          fontSize: 14,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _FaceIdButton(onPressed: () {}),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have a sanctuary? ",
                            style: AppTypography.body.copyWith(
                              color: AppColors.fog.withValues(alpha: 0.55),
                              fontSize: 12,
                              letterSpacing: 0,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.champagneGold,
                              minimumSize: const Size(44, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Create one',
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FaceIdButton extends StatelessWidget {
  const _FaceIdButton({required this.onPressed});

  static const String _iconAsset = 'assets/images/face_id.svg';
  static const double _circleSize = 52;
  static const double _iconSize = 26;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sign in with Face ID',
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _circleSize,
                height: _circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkIndigoBlue.withValues(alpha: 0.4),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.7),
                    width: 0.75,
                  ),
                ),
                child: SvgPicture.asset(
                  _iconAsset,
                  width: _iconSize,
                  height: _iconSize,
                  colorFilter: const ColorFilter.mode(
                    AppColors.champagneGold,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Face ID',
                style: AppTypography.bodyAccent.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: 11,
                  letterSpacing: 1.1,
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
        borderRadius: BorderRadius.circular(8),
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
                  borderRadius: BorderRadius.circular(5),
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
              const SizedBox(width: 10),
              Text(
                'Remember me',
                style: AppTypography.bodyAccent.copyWith(
                  color: AppColors.white,
                  fontSize: 13,
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
