import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/app_colors.dart';

/// Standard "back" control: a gold arrow pointing left inside a thin gold
/// ring, sized as a full touch target. Place it at the top left of a screen.
/// The dark veil behind the arrow keeps it visible over any photo.
class HikaruBackButton extends StatelessWidget {
  const HikaruBackButton({super.key, required this.onPressed});

  /// Null disables the button (for example while a request is running).
  final VoidCallback? onPressed;

  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).commonBack;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.5),
        shape: CircleBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: enabled ? 1 : 0.4),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.champagneGold.withValues(
                alpha: enabled ? 1 : 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
