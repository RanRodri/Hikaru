import 'package:flutter/material.dart';

/// Maps the `icon:` names used in the infographic packs to a line icon.
///
/// The source infographics drew these as filled gold ✦ glyphs; here they are
/// rebuilt as thin outlined icons inside a gold ring (see
/// `LibraryIconBadge`), matching the "vector line icon" guidance in each
/// topic's `layout.md`.
const Map<String, IconData> _libraryIcons = {
  'lungs': Icons.air,
  'intestine': Icons.all_inclusive,
  'stomach': Icons.circle_outlined,
  'heart': Icons.favorite_border,
  'kidney': Icons.water_drop_outlined,
  'liver': Icons.eco_outlined,
  'lotus': Icons.spa_outlined,
  'waves': Icons.waves,
  'sparkle': Icons.auto_awesome_outlined,
  'leaf': Icons.eco_outlined,
  'drop': Icons.water_drop_outlined,
  'triangle': Icons.change_history_outlined,
  'arrows_up': Icons.north_outlined,
  'edge': Icons.gesture,
  'face': Icons.face_retouching_natural_outlined,
  'jaw': Icons.face_outlined,
  'bolt': Icons.bolt_outlined,
  'infinity': Icons.all_inclusive,
  'flower': Icons.filter_vintage_outlined,
  'eye': Icons.visibility_outlined,
  'ear': Icons.hearing_outlined,
  'hand': Icons.pan_tool_outlined,
  'gem': Icons.diamond_outlined,
  'dna': Icons.biotech_outlined,
  'sun': Icons.wb_sunny_outlined,
  'spiral': Icons.cyclone_outlined,
  'circles': Icons.hub_outlined,
  'star': Icons.auto_awesome_outlined,
  'meditation': Icons.self_improvement_outlined,
  'shield': Icons.shield_outlined,
  'stones': Icons.blur_circular_outlined,
};

IconData libraryIconFor(String? name) =>
    _libraryIcons[name] ?? Icons.circle_outlined;
