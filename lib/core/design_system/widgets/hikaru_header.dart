import 'package:flutter/material.dart';

class HikaruHeader extends StatelessWidget {
  const HikaruHeader({super.key});

  static const double _designWidth = 390;

  /// Header height in design pixels, before scaling to the screen width.
  static const double height = 68;
  static const String _kanjiAsset = 'assets/images/harmony_kanji.png';

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _designWidth;

    return SizedBox(
      height: height * scale,
      child: Center(
        child: Image.asset(
          _kanjiAsset,
          width: 42 * scale,
          height: 39 * scale,
          semanticLabel: 'Hikaru',
        ),
      ),
    );
  }
}
