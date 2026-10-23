import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_gateway.dart';
import 'auth_background.dart';
import 'auth_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  bool _busy = false;
  String? _usernameError;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _birthdayError;
  String? _formError;

  @override
  void dispose() {
    _usernameController.dispose();
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

    final l10n = AppLocalizations.of(context);
    setState(() {
      _birthdayController.text = DateFormat(
        l10n.registerBirthdayFormat,
      ).format(picked);
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

  String? _cognitoBirthdate(String displayed, String pattern) {
    try {
      final date = DateFormat(pattern).parseStrict(displayed);
      return DateFormat('yyyy-MM-dd').format(date);
    } on FormatException {
      return null;
    }
  }

  Future<void> _handleContinue() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final username = _usernameController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final birthday = _birthdayController.text.trim();
    final emailLooksValid = identityLooksValid(email) && email.contains('@');
    final usernameValid = usernameIsAllowed(username);
    final passwordValid = passwordMeetsPolicy(password);
    final birthdate = _cognitoBirthdate(birthday, l10n.registerBirthdayFormat);

    setState(() {
      _formError = null;
      _usernameError = username.isEmpty
          ? l10n.registerErrorUsernameRequired
          : usernameValid
          ? null
          : l10n.registerErrorUsernameInvalid;
      _nameError = name.isEmpty ? l10n.registerErrorNameRequired : null;
      _emailError = email.isEmpty
          ? l10n.authErrorEmailRequired
          : emailLooksValid
          ? null
          : l10n.authErrorEmailInvalid;
      _passwordError = password.isEmpty
          ? l10n.authErrorPasswordRequired
          : passwordValid
          ? null
          : l10n.authErrorPasswordPolicy;
      _birthdayError = birthday.isEmpty || birthdate == null
          ? l10n.registerErrorBirthdayRequired
          : null;
    });

    if (!usernameValid ||
        name.isEmpty ||
        !emailLooksValid ||
        !passwordValid ||
        birthdate == null) {
      return;
    }

    setState(() => _busy = true);
    try {
      final outcome = await ref
          .read(authGatewayProvider)
          .signUp(
            username: username,
            password: password,
            email: email,
            name: name,
            birthdate: birthdate,
          );
      if (!mounted) return;
      if (outcome == AuthSignUpOutcome.signedIn) {
        context.go(AppRoutes.listeningRoom);
        return;
      }
      context.push(
        AppRoutes.confirmSignUp,
        extra: PendingConfirmation(username: username, password: password),
      );
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
                  l10n.registerTitle,
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
                  l10n.registerSubtitle,
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
                  controller: _usernameController,
                  label: l10n.registerUsernameLabel,
                  hint: l10n.registerUsernameHint,
                  icon: 'U',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                  errorText: _usernameError,
                  onChanged: (_) {
                    if (_usernameError == null) return;
                    setState(() => _usernameError = null);
                  },
                ),
                const SizedBox(height: AppSpacing.s10),
                AuthField(
                  controller: _nameController,
                  label: l10n.registerFullNameLabel,
                  hint: l10n.registerFullNameHint,
                  icon: 'A',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  errorText: _nameError,
                  onChanged: _handleNameChanged,
                ),
                const SizedBox(height: AppSpacing.s10),
                AuthField(
                  controller: _emailController,
                  label: l10n.authEmailLabel,
                  hint: l10n.authEmailHintExample,
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
                  label: l10n.authPasswordLabel,
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
                  label: l10n.registerBirthdayLabel,
                  hint: l10n.registerBirthdayHint,
                  icon: '☆',
                  readOnly: true,
                  onTap: _handleBirthday,
                  errorText: _birthdayError,
                  onChanged: (_) {},
                ),
                const SizedBox(height: AppSpacing.s22),
                AuthPillButton(
                  label: l10n.registerContinue,
                  backgroundColor: AppColors.champagneGold,
                  foregroundColor: AppColors.darkIndigoBlue,
                  glow: true,
                  onPressed: _handleContinue,
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
                const SizedBox(height: AppSpacing.s16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.registerHaveAccount,
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
                        l10n.registerLogIn,
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
