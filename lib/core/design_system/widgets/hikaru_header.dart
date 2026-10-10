import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_radii.dart';

class HikaruHeader extends StatelessWidget {
  const HikaruHeader({
    super.key,
    required this.onMenuPressed,
    required this.onProfilePressed,
  });

  static const double _designWidth = 390;
  static const double _height = 68;
  static const String _controlsAsset =
      'assets/images/harmony_header_controls.svg';
  static const String _kanjiAsset = 'assets/images/harmony_kanji.png';

  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _designWidth;
    final height = _height * scale;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          SvgPicture.asset(
            _controlsAsset,
            width: double.infinity,
            height: height,
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
          Center(
            child: Image.asset(
              _kanjiAsset,
              width: 42 * scale,
              height: 39 * scale,
              semanticLabel: 'Hikaru',
            ),
          ),
          Positioned(
            left: 6 * scale,
            top: 34 * scale,
            width: 48 * scale,
            height: 34 * scale,
            child: _HeaderButton(label: 'Open menu', onPressed: onMenuPressed),
          ),
          Positioned(
            right: 6 * scale,
            top: 34 * scale,
            width: 48 * scale,
            height: 34 * scale,
            child: _HeaderButton(
              label: 'Open profile',
              onPressed: onProfilePressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.r8),
      ),
    );
  }
}
