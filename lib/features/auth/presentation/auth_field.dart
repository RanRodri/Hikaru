import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';

const List<Shadow> authTextShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    offset: Offset(0, 1),
    blurRadius: 8,
  ),
];

class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.errorText,
    this.onSubmitted,
    this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String icon;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() => setState(() {});

  void _handleToggleVisibility() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final focused = _focusNode.hasFocus;
    final borderColor = hasError
        ? AppColors.error
        : focused
        ? AppColors.champagneGold
        : AppColors.champagneGold.withValues(alpha: 0.7);
    final iconStyle = _iconStyle(widget.icon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: borderColor,
              width: focused || hasError ? 1.5 : 0.75,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color:
                          (hasError ? AppColors.error : AppColors.champagneGold)
                              .withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: ColoredBox(
                color: AppColors.darkIndigoBlue.withValues(alpha: 0.4),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 12, 0),
                  child: Row(
                    children: [
                      _FieldIcon(icon: widget.icon, style: iconStyle),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          readOnly: widget.readOnly,
                          keyboardType: widget.keyboardType,
                          textInputAction: widget.textInputAction,
                          autofillHints: widget.autofillHints,
                          obscureText: widget.obscureText && _obscured,
                          cursorColor: AppColors.champagneGold,
                          style: AppTypography.body.copyWith(
                            color: AppColors.white,
                            fontSize: 15,
                            letterSpacing: 0,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            labelText: widget.label,
                            hintText: widget.hint,
                            labelStyle: AppTypography.bodyAccent.copyWith(
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              letterSpacing: 0,
                            ),
                            floatingLabelStyle: AppTypography.bodyAccent
                                .copyWith(
                                  color: AppColors.champagneGold,
                                  fontSize: 12,
                                  letterSpacing: 0,
                                ),
                            hintStyle: AppTypography.body.copyWith(
                              color: AppColors.fog.withValues(alpha: 0.72),
                              fontSize: 14,
                              letterSpacing: 0,
                            ),
                          ),
                          onChanged: widget.onChanged,
                          onSubmitted: widget.onSubmitted,
                          onTap: widget.onTap,
                        ),
                      ),
                      if (widget.obscureText)
                        IconButton(
                          onPressed: _handleToggleVisibility,
                          tooltip: _obscured
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.champagneGold,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 6),
            child: Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText!,
                style: AppTypography.bodyAccent.copyWith(
                  color: AppColors.error,
                  fontSize: 12,
                  letterSpacing: 0,
                  shadows: authTextShadow,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AuthPillButton extends StatelessWidget {
  const AuthPillButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.glow = false,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: glow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTypography.subheadline.copyWith(
            color: foregroundColor,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

typedef _IconStyle = ({double size, FontWeight weight, double letterSpacing});

_IconStyle _iconStyle(String icon) {
  if (icon == '•••') {
    return (size: 12, weight: FontWeight.w700, letterSpacing: -1.2);
  }
  if (icon == '@' || icon == '☆') {
    return (size: 16, weight: FontWeight.w300, letterSpacing: 0);
  }
  return (size: 16, weight: FontWeight.w700, letterSpacing: 0);
}

class _FieldIcon extends StatelessWidget {
  const _FieldIcon({required this.icon, required this.style});

  final String icon;
  final _IconStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.champagneGold, width: 0.75),
      ),
      child: Text(
        icon,
        style: AppTypography.body.copyWith(
          color: AppColors.champagneGold,
          fontSize: style.size,
          fontWeight: style.weight,
          letterSpacing: style.letterSpacing,
          height: 1,
        ),
      ),
    );
  }
}
