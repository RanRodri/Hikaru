import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../library/domain/library_collection.dart';
import '../../library/presentation/library_collection_circle.dart';

class HarmonyGardenScreen extends ConsumerWidget {
  const HarmonyGardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrystal = ref.watch(selectedCrystalProvider).value;

    return HikaruShell(
      active: HikaruDestination.home,
      builder: (context, scale) =>
          _Garden(scale: scale, selectedCrystal: selectedCrystal),
    );
  }
}

class _Layer {
  const _Layer(this.asset, this.rect, {this.isPhoto = false});

  final String asset;
  final Rect rect;
  final bool isPhoto;
}

class _DestinationSpec {
  const _DestinationSpec({
    required this.bounds,
    required this.semanticsLabel,
    this.layers = const [],
    this.label,
    this.labelBounds,
    this.collection,
    this.route,
    this.showsSelectedCrystal = false,
  });

  final Rect bounds;
  final String semanticsLabel;
  final List<_Layer> layers;
  final String? label;
  final Rect? labelBounds;
  final LibraryCollection? collection;
  final String? route;
  final bool showsSelectedCrystal;
}

const LibraryCollection _listeningCollection = LibraryCollection(
  id: 'listening',
  name: 'LISTENING',
  detail: 'Sanctuary',
  category: 'LISTENING SANCTUARY',
  imageAsset: 'assets/images/harmony_listening.png',
  photoHeight: 70,
);

/// Shared size for the garden circles on the left and the right.
const double homeSideCircleWidth = 122;
const double homeSideCircleHeight = 130;

const List<_DestinationSpec> _destinations = [
  _DestinationSpec(
    semanticsLabel: 'Merkaba',
    bounds: Rect.fromLTWH(134, 36, homeSideCircleWidth, homeSideCircleHeight),
    collection: merkabaCollection,
    route: AppRoutes.merkaba,
  ),
  _DestinationSpec(
    semanticsLabel: 'Hikaru Ritual Face',
    bounds: Rect.fromLTWH(260, 228, homeSideCircleWidth, homeSideCircleHeight),
    layers: [
      _Layer(
        'assets/images/harmony_face_halo.svg',
        Rect.fromLTWH(260, 228, homeSideCircleWidth, homeSideCircleHeight),
      ),
      _Layer(
        'assets/images/harmony_face.png',
        Rect.fromLTWH(272, 240, 98, 106),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_face_scrim.svg',
        Rect.fromLTWH(272, 240, 98, 106),
      ),
    ],
    label: 'Hikaru Ritual\nFace',
    labelBounds: Rect.fromLTWH(282, 304, 78, 26),
    route: AppRoutes.ritualFace,
  ),
  _DestinationSpec(
    semanticsLabel: 'Hikaru Ritual Body',
    bounds: Rect.fromLTWH(260, 392, homeSideCircleWidth, homeSideCircleHeight),
    layers: [
      _Layer(
        'assets/images/harmony_body_halo.svg',
        Rect.fromLTWH(260, 392, homeSideCircleWidth, homeSideCircleHeight),
      ),
      _Layer(
        'assets/images/harmony_body.png',
        Rect.fromLTWH(272, 404, 98, 106),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_body_scrim.svg',
        Rect.fromLTWH(272, 404, 98, 106),
      ),
    ],
    label: 'Hikaru Ritual\nBody',
    labelBounds: Rect.fromLTWH(281, 468, 80, 26),
    route: AppRoutes.ritualBody,
  ),
  _DestinationSpec(
    semanticsLabel: 'Listening Sanctuary',
    bounds: Rect.fromLTWH(8, 392, homeSideCircleWidth, homeSideCircleHeight),
    collection: _listeningCollection,
    route: AppRoutes.fourTemples,
    showsSelectedCrystal: true,
  ),
  _DestinationSpec(
    semanticsLabel: 'Library',
    bounds: Rect.fromLTWH(8, 228, homeSideCircleWidth, homeSideCircleHeight),
    layers: [
      _Layer(
        'assets/images/harmony_library_halo.svg',
        Rect.fromLTWH(8, 228, homeSideCircleWidth, homeSideCircleHeight),
      ),
      _Layer(
        'assets/images/harmony_library.png',
        Rect.fromLTWH(20, 240, 98, 106),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_library_scrim.svg',
        Rect.fromLTWH(20, 240, 98, 106),
      ),
    ],
    label: 'Library',
    labelBounds: Rect.fromLTWH(36.5, 304, 65, 13),
    route: AppRoutes.library,
  ),
];

const List<Offset> _glowDots = [
  Offset(195, 214),
  Offset(186, 292),
  Offset(204, 292),
  Offset(195, 372),
  Offset(150, 430),
  Offset(240, 430),
];

class _Garden extends StatelessWidget {
  const _Garden({required this.scale, required this.selectedCrystal});

  final double scale;
  final Crystal? selectedCrystal;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _scaled(
          const Rect.fromLTWH(24, 88, 342, 400),
          SvgPicture.asset(
            'assets/images/harmony_orbit.svg',
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
        ),
        for (final dot in _glowDots)
          _scaled(
            Rect.fromLTWH(dot.dx, dot.dy, 7, 7),
            SvgPicture.asset(
              'assets/images/harmony_orbit_glow.svg',
              fit: BoxFit.fill,
              excludeFromSemantics: true,
            ),
          ),
        for (final destination in _destinations)
          _Destination(
            spec: destination,
            scale: scale,
            crystal: destination.showsSelectedCrystal ? selectedCrystal : null,
            onPressed: () => _handleDestinationPressed(context, destination),
          ),
        _Title(scale: scale),
      ],
    );
  }

  void _handleDestinationPressed(
    BuildContext context,
    _DestinationSpec destination,
  ) {
    final route = destination.route;
    if (route == null) return;
    context.push(route);
  }

  Widget _scaled(Rect rect, Widget child) {
    return Positioned(
      left: rect.left * scale,
      top: rect.top * scale,
      width: rect.width * scale,
      height: rect.height * scale,
      child: child,
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.spec,
    required this.scale,
    required this.onPressed,
    this.crystal,
  });

  final _DestinationSpec spec;
  final double scale;
  final VoidCallback onPressed;
  final Crystal? crystal;

  Widget _buildCollection(LibraryCollection fallback) {
    final selectedCrystal = crystal;
    final collection = selectedCrystal == null
        ? fallback
        : crystalCollections[selectedCrystal] ?? fallback;
    final diameter = collection.diameter * scale;

    return Center(
      child: SizedBox.square(
        dimension: diameter,
        child: LibraryCollectionCircle(collection: collection, scale: scale),
      ),
    );
  }

  Widget _buildLayers() {
    final bounds = spec.bounds;
    final label = spec.label;
    final labelBounds = spec.labelBounds;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final layer in spec.layers)
          Positioned(
            left: (layer.rect.left - bounds.left) * scale,
            top: (layer.rect.top - bounds.top) * scale,
            width: layer.rect.width * scale,
            height: layer.rect.height * scale,
            child: layer.isPhoto
                ? Image.asset(layer.asset, fit: BoxFit.cover)
                : SvgPicture.asset(layer.asset, fit: BoxFit.fill),
          ),
        if (label != null && labelBounds != null)
          Positioned(
            left: (labelBounds.left - bounds.left) * scale,
            top: (labelBounds.top - bounds.top) * scale,
            width: labelBounds.width * scale,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s10_5 * scale,
                height: 1.14,
                letterSpacing: 0.42 * scale,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bounds = spec.bounds;
    final collection = spec.collection;

    return Positioned(
      left: bounds.left * scale,
      top: bounds.top * scale,
      width: bounds.width * scale,
      height: bounds.height * scale,
      child: Semantics(
        button: true,
        label: crystal == null ? spec.semanticsLabel : crystal!.displayName,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: collection == null
              ? _buildLayers()
              : _buildCollection(collection),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.headline.copyWith(color: AppColors.white);

    return Positioned(
      left: 100 * scale,
      top: 560 * scale,
      width: 190 * scale,
      child: Column(
        children: [
          Text(
            'The',
            style: style.copyWith(
              fontSize: AppFontSizes.s10 * scale,
              height: 1.1,
              letterSpacing: 1.6 * scale,
            ),
          ),
          SizedBox(height: AppSpacing.s4 * scale),
          Text(
            'Harmony Garden',
            style: style.copyWith(
              fontSize: AppFontSizes.s20 * scale,
              height: 1.1,
              letterSpacing: 1.6 * scale,
            ),
          ),
          SizedBox(height: AppSpacing.s4 * scale),
          _rule(34),
          SizedBox(height: AppSpacing.s4 * scale),
          Text(
            'Your Journey Begins Within',
            textAlign: TextAlign.center,
            style: style.copyWith(
              fontSize: AppFontSizes.s10 * scale,
              height: 1.2,
              letterSpacing: 0.6 * scale,
            ),
          ),
          SizedBox(height: AppSpacing.s4 * scale),
          _rule(30),
        ],
      ),
    );
  }

  Widget _rule(double width) {
    return Container(
      width: width * scale,
      height: 0.8,
      color: AppColors.champagneGold,
    );
  }
}
