import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../splash/presentation/splash_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_gateway.dart';
import 'auth_background.dart';
import 'auth_field.dart';
import 'auth_page.dart';

class ConfirmSignUpScreen extends ConsumerStatefulWidget {
  const ConfirmSignUpScreen({super.key, required this.pending});

  final PendingConfirmation pending;

  @override
  ConsumerState<ConfirmSignUpScreen> createState() =>
      _ConfirmSignUpScreenState();
}

class _ConfirmSignUpScreenState extends ConsumerState<ConfirmSignUpScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _busy = false;
  String? _codeError;
  String? _formError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    setState(() {
      _formError = null;
      _codeError = code.isEmpty ? l10n.confirmSignUpErrorCode : null;
    });
    if (code.isEmpty) return;

    setState(() => _busy = true);
    try {
      final auth = ref.read(authGatewayProvider);
      await auth.confirmSignUp(
        username: widget.pending.username,
        confirmationCode: code,
      );
      await auth.signIn(
        username: widget.pending.username,
        password: widget.pending.password,
      );
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthPage(
      overlay: AuthBackground.loginOverlay,
      content: [
        const SizedBox(height: AppSpacing.s24),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _busy
                ? null
                : () {
                    if (context.canPop()) {
                      context.pop();
                      return;
                    }
                    context.go(AppRoutes.login);
                  },
            child: Text(
              l10n.commonBack,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold,
                fontSize: AppFontSizes.s11,
                letterSpacing: 1.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s40),
        Text(
          l10n.confirmSignUpTitle,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s34,
            height: 1.15,
            shadows: authTextShadow,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        Text(
          l10n.confirmSignUpSubtitle,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.fog.withValues(alpha: 0.85),
            fontSize: AppFontSizes.s12,
            height: 1.5,
            shadows: authTextShadow,
          ),
        ),
        const SizedBox(height: AppSpacing.s28),
        AuthField(
          controller: _codeController,
          label: l10n.confirmSignUpCodeLabel,
          hint: l10n.confirmSignUpCodeHint,
          icon: '#',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          errorText: _codeError,
          onChanged: (_) {
            if (_codeError == null) return;
            setState(() => _codeError = null);
          },
          onSubmitted: (_) => _handleConfirm(),
        ),
      ],
      footer: [
        if (_formError != null) ...[
          Text(
            _formError!,
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
          label: l10n.confirmSignUpAction,
          backgroundColor: AppColors.champagneGold,
          foregroundColor: AppColors.darkIndigoBlue,
          glow: true,
          busy: _busy,
          onPressed: _handleConfirm,
        ),
      ],
    );
  }
}
