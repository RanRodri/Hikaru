import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import 'auth_background.dart';
import 'auth_field.dart';

/// Shared layout of the sign in, register, reset password and confirm code
/// screens.
///
/// [content] holds the title and the fields at the top. [footer] holds the
/// primary button and the links around it, and sits at the bottom of the
/// screen like the main button of the other screens. When the content is
/// taller than the screen (a small phone, or the keyboard is open) the whole
/// page scrolls and the footer follows the content.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.overlay,
    required this.content,
    required this.footer,
  });

  /// Side padding of the title and the fields.
  static const double contentPadding = AppSpacing.s40;

  /// Side padding of the footer, as in the other screens' bottom button.
  static const double footerPadding = AppSpacing.s32;

  /// Space below the footer, on top of the system bar.
  static const double footerBottom = AppSpacing.s28;

  /// Least space kept between the content and the footer.
  static const double footerGap = AppSpacing.s16;

  final LinearGradient overlay;
  final List<Widget> content;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: AuthBackground(
        overlay: overlay,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: contentPadding,
                        ),
                        child: Column(children: content),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          footerPadding,
                          footerGap,
                          footerPadding,
                          footerBottom,
                        ),
                        child: Column(children: footer),
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

/// "Don't have an account? Create one": a question in plain text followed by
/// a gold, underlined action. Used below the primary button of each auth
/// screen.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.s4,
      children: [
        Text(
          prompt.trimRight(),
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.white.withValues(alpha: 0.92),
            fontSize: AppFontSizes.s14,
            letterSpacing: 0.2,
            shadows: authTextShadow,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.champagneGold,
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: AppTypography.bodyAccent.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s14,
              letterSpacing: 0.2,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.champagneGold,
              shadows: authTextShadow,
            ),
          ),
        ),
      ],
    );
  }
}
