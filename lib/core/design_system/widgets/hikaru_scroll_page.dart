import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'hikaru_header.dart';
import 'hikaru_navigation_bar.dart';
import 'hikaru_shell.dart';

class HikaruScrollPage extends StatelessWidget {
  const HikaruScrollPage({
    super.key,
    required this.active,
    required this.children,
    this.backgroundAsset = HikaruShell.gardenBackground,
    this.dimBackground = false,
  });

  static const double _horizontalPadding = 22;

  final HikaruDestination active;
  final List<Widget> children;
  final String backgroundAsset;
  final bool dimBackground;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return HikaruShell(
      active: active,
      backgroundAsset: backgroundAsset,
      dimBackground: dimBackground,
      builder: (context, scale) => Positioned.fill(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            _horizontalPadding,
            insets.top + HikaruHeader.height * scale + AppSpacing.s8,
            _horizontalPadding,
            HikaruNavigationBar.height + insets.bottom + AppSpacing.s20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
