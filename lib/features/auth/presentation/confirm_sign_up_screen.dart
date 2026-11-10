import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_back_button.dart';
import '../../../core/router/app_routes.dart';
import '../../splash/presentation/splash_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../application/new_member_profile.dart';
import '../data/auth_gateway.dart';
import 'auth_background.dart';
import 'auth_field.dart';
import 'auth_page.dart';
import 'biometric_offer.dart';

class ConfirmSignUpScreen extends ConsumerStatefulWidget {
  const ConfirmSignUpScreen({super.key, required this.pending});

  /// Wait before a new code can be requested. Emails can take a minute to
  /// arrive, and asking again sooner only stacks codes in the inbox.
  static const Duration resendCooldown = Duration(seconds: 60);

  final PendingConfirmation pending;

  @override
  ConsumerState<ConfirmSignUpScreen> createState() =>
      _ConfirmSignUpScreenState();
}

class _ConfirmSignUpScreenState extends ConsumerState<ConfirmSignUpScreen> {
  final TextEditingController _codeController = TextEditingController();

  Timer? _cooldownTimer;
  int _secondsLeft = 0;
  bool _busy = false;
  bool _resending = false;
  String? _codeError;
  String? _formError;
  String? _notice;

  @override
  void initState() {
    super.initState();
    // Right after sign-up a code is already on its way. From an old account
    // nothing was sent now, so resending is allowed immediately.
    if (widget.pending.codeJustSent) {
      _secondsLeft = ConfirmSignUpScreen.resendCooldown.inSeconds;
      _startCooldownTimer();
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft -= 1;
        if (_secondsLeft <= 0) {
          _secondsLeft = 0;
          timer.cancel();
        }
      });
    });
  }

  void _restartCooldown() {
    setState(() => _secondsLeft = ConfirmSignUpScreen.resendCooldown.inSeconds);
    _startCooldownTimer();
  }

  static String _clock(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  Future<void> _handleResend() async {
    if (_busy || _resending || _secondsLeft > 0) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _resending = true;
      _formError = null;
      _notice = null;
    });
    try {
      await ref
          .read(authGatewayProvider)
          .resendSignUpCode(username: widget.pending.username);
      if (!mounted) return;
      setState(() => _notice = l10n.confirmSignUpResent);
      _restartCooldown();
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      final tooMany = error.message == AuthRequestException.tooManyAttempts;
      setState(
        () => _formError = tooMany ? l10n.confirmSignUpTooMany : error.message,
      );
      if (tooMany) _restartCooldown();
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _handleConfirm() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    setState(() {
      _formError = null;
      _notice = null;
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
      await useUsernameAsDisplayName(ref, widget.pending.username);
      if (!mounted) return;
      await offerBiometric(widget.pending.username, widget.pending.password);
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
    final waiting = _secondsLeft > 0;

    return AuthPage(
      overlay: AuthBackground.loginOverlay,
      content: [
        const SizedBox(height: AppSpacing.s24),
        Align(
          alignment: Alignment.centerLeft,
          child: HikaruBackButton(
            onPressed: _busy
                ? null
                : () {
                    if (context.canPop()) {
                      context.pop();
                      return;
                    }
                    context.go(AppRoutes.login);
                  },
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
        if (_notice != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              _notice!,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.champagneGold,
                fontSize: AppFontSizes.s12,
                height: 1.4,
                shadows: authTextShadow,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
        ],
        if (_formError != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              _formError!,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s12,
                height: 1.4,
              ),
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
        const SizedBox(height: AppSpacing.s4),
        TextButton(
          onPressed: (_busy || _resending || waiting) ? null : _handleResend,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.champagneGold,
            disabledForegroundColor: AppColors.fog.withValues(alpha: 0.6),
            minimumSize: const Size(44, 44),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            waiting
                ? l10n.confirmSignUpResendIn(_clock(_secondsLeft))
                : l10n.confirmSignUpResend,
            style: AppTypography.bodyAccent.copyWith(
              fontSize: AppFontSizes.s13,
              letterSpacing: 0,
              shadows: authTextShadow,
            ),
          ),
        ),
      ],
    );
  }
}
