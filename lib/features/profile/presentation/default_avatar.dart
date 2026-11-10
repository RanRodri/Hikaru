import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';

/// Neutral stand-in until the member adds a photo: a gold person outline on
/// dark indigo, so no one is shown a face that isn't theirs.
class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({super.key, this.semanticLabel});

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, box) {
          final side = box.biggest.shortestSide;
          return ColoredBox(
            color: AppColors.darkIndigoBlue,
            child: Center(
              child: Icon(
                Icons.person_outline,
                size: side.isFinite ? side * 0.58 : 36,
                color: AppColors.champagneGold,
              ),
            ),
          );
        },
      ),
    );
  }
}
