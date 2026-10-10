import 'package:flutter/material.dart';

import '../tokens/app_gradients.dart';

/// Brand tokens that [ThemeData] cannot express natively.
///
/// Read with `Theme.of(context).extension<HikaruTokens>()!`.
@immutable
class HikaruTokens extends ThemeExtension<HikaruTokens> {
  const HikaruTokens({
    required this.gradientIndigo,
    required this.gradientChampagne,
  });

  static const HikaruTokens standard = HikaruTokens(
    gradientIndigo: AppGradients.gradientIndigo,
    gradientChampagne: AppGradients.gradientChampagne,
  );

  final LinearGradient gradientIndigo;
  final LinearGradient gradientChampagne;

  @override
  HikaruTokens copyWith({
    LinearGradient? gradientIndigo,
    LinearGradient? gradientChampagne,
  }) {
    return HikaruTokens(
      gradientIndigo: gradientIndigo ?? this.gradientIndigo,
      gradientChampagne: gradientChampagne ?? this.gradientChampagne,
    );
  }

  @override
  HikaruTokens lerp(HikaruTokens? other, double t) {
    if (other == null) return this;

    return HikaruTokens(
      gradientIndigo: LinearGradient.lerp(
        gradientIndigo,
        other.gradientIndigo,
        t,
      )!,
      gradientChampagne: LinearGradient.lerp(
        gradientChampagne,
        other.gradientChampagne,
        t,
      )!,
    );
  }
}
