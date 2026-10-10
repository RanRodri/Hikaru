import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../../../core/router/app_routes.dart';
import '../domain/library_article.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HikaruScrollPage(
      active: HikaruDestination.library,
      dimBackground: true,
      children: [
        const HikaruPageIntro(
          title: 'LIBRARY',
          subtitle: 'Sacred knowledge for your journey',
        ),
        const SizedBox(height: AppSpacing.s14),
        _CollectionsConstellation(
          onOpen: (id) => context.push(AppRoutes.libraryTopicFor(id)),
        ),
      ],
    );
  }
}

class _LibraryCollection {
  const _LibraryCollection({
    required this.id,
    required this.name,
    required this.detail,
    required this.imageAsset,
    required this.bounds,
    required this.photoHeight,
    this.isHighlighted = false,
  });

  final String id;
  final String name;
  final String detail;
  final String imageAsset;
  final Rect bounds;
  final double photoHeight;
  final bool isHighlighted;
}

const List<_LibraryCollection> _collections = [
  _LibraryCollection(
    id: libraryMerkabaId,
    name: 'MERKABA',
    detail: 'Geometry & Energy',
    imageAsset: 'assets/images/library_merkaba.png',
    bounds: Rect.fromLTWH(120, 5, 110, 110),
    photoHeight: 79,
    isHighlighted: true,
  ),
  _LibraryCollection(
    id: 'jade',
    name: 'JADE',
    detail: 'Balance\n& Harmony',
    imageAsset: 'assets/images/library_jade.png',
    bounds: Rect.fromLTWH(6, 71, 104, 104),
    photoHeight: 70,
  ),
  _LibraryCollection(
    id: 'whiteQuartz',
    name: 'WHITE QUARTZ',
    detail: 'Clarity\n& Renewal',
    imageAsset: 'assets/images/library_white_quartz.png',
    bounds: Rect.fromLTWH(238, 71, 104, 104),
    photoHeight: 70,
  ),
  _LibraryCollection(
    id: 'redJasper',
    name: 'RED JASPER',
    detail: 'Vitality\n& Grounding',
    imageAsset: 'assets/images/library_red_jasper.png',
    bounds: Rect.fromLTWH(6, 200, 104, 104),
    photoHeight: 66,
  ),
  _LibraryCollection(
    id: 'obsidian',
    name: 'OBSIDIAN',
    detail: 'Protection\n& Transformation',
    imageAsset: 'assets/images/library_obsidian.png',
    bounds: Rect.fromLTWH(238, 200, 104, 104),
    photoHeight: 66,
  ),
  _LibraryCollection(
    id: libraryRitualsId,
    name: 'HIKARU RITUALS',
    detail: 'Face & Body',
    imageAsset: 'assets/images/library_rituals.png',
    bounds: Rect.fromLTWH(120, 245, 106, 106),
    photoHeight: 74,
  ),
];

class _CollectionsConstellation extends StatelessWidget {
  const _CollectionsConstellation({required this.onOpen});

  final ValueChanged<String> onOpen;

  static const Size _designSize = Size(346, 356);
  static const Offset _center = Offset(173, 185);
  static const double _orbitRadius = 125;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _designSize.width;

        Widget place(Rect rect, Widget child) => Positioned(
          left: rect.left * scale,
          top: rect.top * scale,
          width: rect.width * scale,
          height: rect.height * scale,
          child: child,
        );

        return SizedBox(
          height: _designSize.height * scale,
          child: Stack(
            children: [
              place(
                Rect.fromCircle(center: _center, radius: _orbitRadius),
                const IgnorePointer(
                  child: CustomPaint(painter: _OrbitPainter()),
                ),
              ),
              place(
                Rect.fromCircle(center: _center, radius: 49),
                const IgnorePointer(child: _LightCenter()),
              ),
              for (final collection in _collections)
                place(
                  collection.bounds,
                  _CollectionCircle(
                    collection: collection,
                    scale: scale,
                    onPressed: () => onOpen(collection.id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LightCenter extends StatelessWidget {
  const _LightCenter();

  static const List<double> _ringSizes = [18, 32, 46, 62, 98];
  static const List<Alignment> _orbitLights = [
    Alignment(-0.71, -0.71),
    Alignment(0.71, -0.71),
    Alignment(-0.71, 0.71),
    Alignment(0.71, 0.71),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / 98;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 94 * scale,
              height: 94 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.fog.withValues(alpha: 0.5),
                    AppColors.champagneGold.withValues(alpha: 0.3),
                    AppColors.champagneGold.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.25, 1],
                ),
              ),
            ),
            for (final (index, ringSize) in _ringSizes.indexed)
              SvgPicture.asset(
                'assets/images/library_energy_ring_${index + 1}.svg',
                width: ringSize * scale,
                height: ringSize * scale,
                excludeFromSemantics: true,
              ),
            Container(
              width: 98 * scale,
              height: 0.5,
              color: AppColors.champagneGold80.withValues(alpha: 0.7),
            ),
            Container(
              width: 0.5,
              height: 98 * scale,
              color: AppColors.champagneGold80.withValues(alpha: 0.7),
            ),
            for (final alignment in _orbitLights)
              Align(
                alignment: alignment,
                child: _GlowDot(size: 2 * scale, glow: 5 * scale),
              ),
            _GlowDot(size: 8 * scale, glow: 14 * scale),
          ],
        );
      },
    );
  }
}

class _GlowDot extends StatelessWidget {
  const _GlowDot({required this.size, required this.glow});

  final double size;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.fog,
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold,
            blurRadius: glow,
            spreadRadius: size / 2,
          ),
        ],
      ),
    );
  }
}

class _CollectionCircle extends StatelessWidget {
  const _CollectionCircle({
    required this.collection,
    required this.scale,
    required this.onPressed,
  });

  final _LibraryCollection collection;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final glowBlur = collection.isHighlighted ? 5.0 : 2.0;

    return Semantics(
      button: true,
      label: '${collection.name}, ${collection.detail.replaceAll('\n', ' ')}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.black,
            border: Border.all(color: AppColors.champagneGold80),
            boxShadow: [
              BoxShadow(
                color: AppColors.champagneGold.withValues(alpha: 0.7),
                blurRadius: glowBlur * scale,
              ),
            ],
          ),
          child: ClipOval(
            child: Column(
              children: [
                SizedBox(
                  height: collection.photoHeight * scale,
                  width: double.infinity,
                  child: _FadedPhoto(asset: collection.imageAsset),
                ),
                Expanded(child: _CollectionCaption(collection, scale: scale)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FadedPhoto extends StatelessWidget {
  const _FadedPhoto({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover, excludeFromSemantics: true),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.transparent, AppColors.black],
              stops: [0.78, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionCaption extends StatelessWidget {
  const _CollectionCaption(this.collection, {required this.scale});

  final _LibraryCollection collection;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s14 * scale),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Text(
              collection.name,
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s8_2 * scale,
                height: 1.2,
                letterSpacing: 1.2 * scale,
              ),
            ),
            Text(
              collection.detail,
              textAlign: TextAlign.center,
              style: AppTypography.footnote.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s6_6 * scale,
                height: 1.3,
                letterSpacing: 0.2 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawOval(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}
