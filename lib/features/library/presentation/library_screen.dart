import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/media/remote_image.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/library_collection.dart';
import 'library_collection_circle.dart';
import 'library_texts.dart';

const String libraryBackgroundAsset = 'assets/images/library.png';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HikaruScrollPage(
      active: HikaruDestination.library,
      backgroundAsset: libraryBackgroundAsset,
      children: [
        HikaruPageIntro(
          title: l10n.libraryTitle,
          subtitle: l10n.librarySubtitle,
        ),
        const SizedBox(height: AppSpacing.s14),
        _CollectionsConstellation(
          onOpen: (id) => context.push(AppRoutes.libraryTopicFor(id)),
        ),
      ],
    );
  }
}

final List<(LibraryCollection, Offset)> _placements = [
  (merkabaCollection, const Offset(120, 5)),
  (crystalCollections[Crystal.jade]!, const Offset(6, 71)),
  (crystalCollections[Crystal.whiteQuartz]!, const Offset(238, 71)),
  (crystalCollections[Crystal.redJasper]!, const Offset(6, 200)),
  (crystalCollections[Crystal.obsidian]!, const Offset(238, 200)),
  (ritualsCollection, const Offset(120, 245)),
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
              for (final (collection, topLeft) in _placements)
                place(
                  topLeft & Size.square(collection.diameter),
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

  final LibraryCollection collection;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: collection.localizedSemanticsLabel(AppLocalizations.of(context)),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: LibraryCollectionCircle(collection: collection, scale: scale),
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
