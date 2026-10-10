import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';

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
    required this.layers,
    required this.label,
    required this.labelBounds,
    required this.semanticsLabel,
    this.route,
    this.showsSelectedCrystal = false,
  });

  final Rect bounds;
  final String? route;
  final bool showsSelectedCrystal;
  final List<_Layer> layers;
  final String label;
  final Rect labelBounds;
  final String semanticsLabel;
}

const List<_DestinationSpec> _destinations = [
  _DestinationSpec(
    semanticsLabel: 'Merkaba',
    bounds: Rect.fromLTWH(144, 200, 103, 104),
    layers: [
      _Layer(
        'assets/images/harmony_merkaba_halo.svg',
        Rect.fromLTWH(144, 200, 103, 104),
      ),
      _Layer(
        'assets/images/harmony_merkaba.png',
        Rect.fromLTWH(156, 212, 79, 80),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_face_scrim.svg',
        Rect.fromLTWH(156, 212, 79, 80),
      ),
    ],
    label: 'Merkaba',
    labelBounds: Rect.fromLTWH(165, 263, 61, 13),
  ),
  _DestinationSpec(
    semanticsLabel: 'Hikaru Ritual Face',
    bounds: Rect.fromLTWH(12, 266, 122, 130),
    layers: [
      _Layer(
        'assets/images/harmony_face_halo.svg',
        Rect.fromLTWH(12, 266, 122, 130),
      ),
      _Layer(
        'assets/images/harmony_face.png',
        Rect.fromLTWH(24, 278, 98, 106),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_face_scrim.svg',
        Rect.fromLTWH(24, 278, 98, 106),
      ),
    ],
    label: 'Hikaru Ritual\nFace',
    labelBounds: Rect.fromLTWH(34, 342, 78, 26),
  ),
  _DestinationSpec(
    semanticsLabel: 'Listening Sanctuary',
    route: AppRoutes.fourTemples,
    showsSelectedCrystal: true,
    bounds: Rect.fromLTWH(256, 268, 122, 129),
    layers: [
      _Layer(
        'assets/images/harmony_listening_halo.svg',
        Rect.fromLTWH(256, 268, 122, 129),
      ),
      _Layer(
        'assets/images/harmony_listening.png',
        Rect.fromLTWH(268, 280, 98, 105),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_listening_scrim.svg',
        Rect.fromLTWH(268, 280, 98, 105),
      ),
    ],
    label: 'Listening\nSanctuary',
    labelBounds: Rect.fromLTWH(279, 343, 76, 26),
  ),
  _DestinationSpec(
    semanticsLabel: 'Hikaru Ritual Body',
    bounds: Rect.fromLTWH(5, 383, 125, 131),
    layers: [
      _Layer(
        'assets/images/harmony_body_halo.svg',
        Rect.fromLTWH(5, 383, 125, 131),
      ),
      _Layer(
        'assets/images/harmony_body.png',
        Rect.fromLTWH(17, 395, 101, 107),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_body_scrim.svg',
        Rect.fromLTWH(17, 395, 101, 107),
      ),
    ],
    label: 'Hikaru Ritual\nBody',
    labelBounds: Rect.fromLTWH(27, 453, 80, 26),
  ),
  _DestinationSpec(
    semanticsLabel: 'Library',
    bounds: Rect.fromLTWH(265, 383, 122, 131),
    layers: [
      _Layer(
        'assets/images/harmony_library_halo.svg',
        Rect.fromLTWH(265, 383, 122, 131),
      ),
      _Layer(
        'assets/images/harmony_library.png',
        Rect.fromLTWH(277, 395, 98, 107),
        isPhoto: true,
      ),
      _Layer(
        'assets/images/harmony_library_scrim.svg',
        Rect.fromLTWH(277, 395, 98, 107),
      ),
    ],
    label: 'Library',
    labelBounds: Rect.fromLTWH(292, 464, 65, 13),
  ),
];

const List<Offset> _glowDots = [
  Offset(231.26, 252.83),
  Offset(152.71, 252.57),
  Offset(94.31, 282.94),
  Offset(43.01, 371.08),
  Offset(340.23, 372.43),
  Offset(289.77, 283.86),
  Offset(40.5, 398.61),
  Offset(75.88, 495.62),
  Offset(308.44, 494.02),
  Offset(342.5, 398.08),
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
          const Rect.fromLTWH(44, 251, 302, 302),
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

  static const double _crystalRingRatio = 280 / 236;

  final _DestinationSpec spec;
  final double scale;
  final VoidCallback onPressed;
  final Crystal? crystal;

  Widget _buildPhoto(String asset) {
    final selectedCrystal = crystal;
    if (selectedCrystal == null) {
      return Image.asset(asset, fit: BoxFit.cover);
    }
    return ClipOval(
      child: Transform.scale(
        scale: _crystalRingRatio,
        child: Image.asset(selectedCrystal.imageAsset, fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bounds = spec.bounds;

    return Positioned(
      left: bounds.left * scale,
      top: bounds.top * scale,
      width: bounds.width * scale,
      height: bounds.height * scale,
      child: Semantics(
        button: true,
        label: crystal == null
            ? spec.semanticsLabel
            : '${spec.semanticsLabel}, ${crystal!.displayName}',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final layer in spec.layers)
                Positioned(
                  left: (layer.rect.left - bounds.left) * scale,
                  top: (layer.rect.top - bounds.top) * scale,
                  width: layer.rect.width * scale,
                  height: layer.rect.height * scale,
                  child: layer.isPhoto
                      ? _buildPhoto(layer.asset)
                      : SvgPicture.asset(layer.asset, fit: BoxFit.fill),
                ),
              Positioned(
                left: (spec.labelBounds.left - bounds.left) * scale,
                top: (spec.labelBounds.top - bounds.top) * scale,
                width: spec.labelBounds.width * scale,
                child: Text(
                  spec.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.white,
                    fontSize: 10.5 * scale,
                    height: 1.14,
                    letterSpacing: 0.42 * scale,
                  ),
                ),
              ),
            ],
          ),
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
              fontSize: 10 * scale,
              height: 1.1,
              letterSpacing: 1.6 * scale,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Harmony Garden',
            style: style.copyWith(
              fontSize: 20 * scale,
              height: 1.1,
              letterSpacing: 1.6 * scale,
            ),
          ),
          SizedBox(height: 4 * scale),
          _rule(34),
          SizedBox(height: 4 * scale),
          Text(
            'Your Journey Begins Within',
            textAlign: TextAlign.center,
            style: style.copyWith(
              fontSize: 10 * scale,
              height: 1.2,
              letterSpacing: 0.6 * scale,
            ),
          ),
          SizedBox(height: 4 * scale),
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
