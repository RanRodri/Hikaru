import 'package:flutter/material.dart';

/// Top band of the logged-in screens.
///
/// The kanji that used to sit here was removed, and the band shrank to a
/// small breathing space so the content of Home, the scroll pages and the
/// Library topic moves up into it.
class HikaruHeader extends StatelessWidget {
  const HikaruHeader({super.key});

  static const double _designWidth = 390;

  /// Header height in design pixels, before scaling to the screen width.
  static const double height = 16;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _designWidth;
    return SizedBox(height: height * scale);
  }
}
