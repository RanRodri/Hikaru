import 'package:flutter/material.dart';

import 'hikaru_navigation_bar.dart';
import 'hikaru_shell.dart';

class HikaruScrollPage extends StatelessWidget {
  const HikaruScrollPage({
    super.key,
    required this.active,
    required this.children,
    this.dimBackground = false,
  });

  static const double _headerHeight = 68;
  static const double _horizontalPadding = 22;

  final HikaruDestination active;
  final List<Widget> children;
  final bool dimBackground;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return HikaruShell(
      active: active,
      dimBackground: dimBackground,
      builder: (context, scale) => Positioned.fill(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            _horizontalPadding,
            insets.top + _headerHeight * scale + 8,
            _horizontalPadding,
            HikaruNavigationBar.height + insets.bottom + 20,
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
