// Generates the design-system token classes from `tokens.json`
// (Tokens Studio export).
//
// Usage: dart run tool/generate_tokens.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const _tokensPath = 'tokens.json';
const _outputDir = 'lib/core/design_system/tokens';
const _tokenSet = 'global';

/// Path segments that only group tokens and are dropped from Dart names.
const _groupingSegments = {
  'grayscale',
  'brand',
  'special',
  'feedback',
  'screen',
};

const _fontWeights = {
  'Thin': 100,
  'ExtraLight': 200,
  'Light': 300,
  'Regular': 400,
  'Medium': 500,
  'SemiBold': 600,
  'Bold': 700,
  'ExtraBold': 800,
  'Black': 900,
};

const _header = '''
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: tokens.json. Regenerate with: dart run tool/generate_tokens.dart
''';

typedef Token = ({List<String> path, Map<String, dynamic> data});

void main() {
  final json = jsonDecode(File(_tokensPath).readAsStringSync());
  final root =
      (json as Map<String, dynamic>)[_tokenSet] as Map<String, dynamic>;
  final tokens = _collectTokens(root);

  Directory(_outputDir).createSync(recursive: true);

  final files = {
    'app_colors.dart': _buildColors(root, tokens),
    'app_gradients.dart': _buildGradients(root, tokens),
    'app_typography.dart': _buildTypography(root),
    'app_spacing.dart': _buildSpacing(root),
    'app_font_sizes.dart': _buildFontSizes(root),
    'app_radii.dart': _buildRadii(root),
  };

  files.forEach((name, content) {
    File('$_outputDir/$name').writeAsStringSync(content);
    stdout.writeln('Generated $_outputDir/$name');
  });

  Process.runSync('dart', ['format', _outputDir], runInShell: true);
}

// ---------------------------------------------------------------------------
// Token tree helpers
// ---------------------------------------------------------------------------

List<Token> _collectTokens(
  Map<String, dynamic> node, [
  List<String> path = const [],
]) {
  if (node.containsKey(r'$value')) return [(path: path, data: node)];

  return [
    for (final entry in node.entries)
      if (entry.value is Map<String, dynamic> && !entry.key.startsWith(r'$'))
        ..._collectTokens(entry.value as Map<String, dynamic>, [
          ...path,
          entry.key,
        ]),
  ];
}

Object? _resolve(Map<String, dynamic> root, Object? value) {
  if (value is! String) return value;

  final reference = RegExp(r'^\{(.+)\}$').firstMatch(value);
  if (reference == null) return value;

  Object? node = root;
  for (final segment in reference.group(1)!.split('.')) {
    if (node is! Map<String, dynamic> || !node.containsKey(segment)) {
      throw FormatException('Unresolved token reference: $value');
    }
    node = node[segment];
  }

  return _resolve(root, (node as Map<String, dynamic>)[r'$value']);
}

String _camelCase(Iterable<String> parts) {
  final words = parts
      .expand((part) => part.split(RegExp(r'[\s\-_]+')))
      .where((word) => word.isNotEmpty)
      .toList();

  return [
    for (var i = 0; i < words.length; i++)
      i == 0
          ? words[i].toLowerCase()
          : words[i][0].toUpperCase() + words[i].substring(1).toLowerCase(),
  ].join();
}

String _tokenName(List<String> path) =>
    _camelCase(path.where((segment) => !_groupingSegments.contains(segment)));

String _number(num value) {
  final fixed = value.toStringAsFixed(3);
  if (double.parse(fixed) == 0) return '0.0';

  final trimmed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  return trimmed.contains('.') ? trimmed : '$trimmed.0';
}

double _percent(String value) =>
    double.parse(value.replaceAll('%', '').trim()) / 100;

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

String _colorLiteral(String value) {
  final hex = RegExp(
    r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
  ).firstMatch(value.trim());
  if (hex != null) {
    final digits = hex.group(1)!.toUpperCase();
    final argb = digits.length == 6 ? 'FF$digits' : digits;
    return 'Color(0x$argb)';
  }

  final rgba = RegExp(r'^rgba?\(([^)]+)\)$').firstMatch(value.trim());
  if (rgba == null) throw FormatException('Unsupported color value: $value');

  final channels = rgba
      .group(1)!
      .split(',')
      .map((channel) => channel.trim())
      .toList();
  final opacity = channels.length > 3 ? channels[3] : '1';
  return 'Color.fromRGBO(${channels[0]}, ${channels[1]}, ${channels[2]}, $opacity)';
}

bool _isGradient(String value) => value.trim().startsWith('linear-gradient');

String _buildColors(Map<String, dynamic> root, List<Token> tokens) {
  final buffer = StringBuffer()
    ..writeln(_header)
    ..writeln("import 'package:flutter/painting.dart';")
    ..writeln()
    ..writeln('abstract final class AppColors {');

  for (final token in tokens.where(
    (token) => token.data[r'$type'] == 'color',
  )) {
    final value = _resolve(root, token.data[r'$value']) as String;
    if (_isGradient(value)) continue;

    buffer.writeln(
      '  static const Color ${_tokenName(token.path)} = ${_colorLiteral(value)};',
    );
  }

  buffer.writeln('}');
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Gradients
// ---------------------------------------------------------------------------

String _alignment(double x, double y) =>
    'Alignment(${_number(x)}, ${_number(y)})';

String _linearGradientLiteral(String value) {
  final body = RegExp(
    r'^linear-gradient\((.+)\)$',
  ).firstMatch(value.trim())!.group(1)!;
  final parts = body
      .split(RegExp(r',(?![^(]*\))'))
      .map((part) => part.trim())
      .toList();

  final angleMatch = RegExp(r'^(-?[\d.]+)deg$').firstMatch(parts.first);
  final angle = angleMatch == null ? 180.0 : double.parse(angleMatch.group(1)!);
  final stopParts = angleMatch == null ? parts : parts.skip(1).toList();

  final radians = angle * math.pi / 180;
  final dx = math.sin(radians);
  final dy = -math.cos(radians);

  final colors = <String>[];
  final stops = <String>[];
  for (final stop in stopParts) {
    final match = RegExp(r'^(.+?)\s+([\d.]+%)$').firstMatch(stop)!;
    colors.add(_colorLiteral(match.group(1)!));
    stops.add(_number(_percent(match.group(2)!)));
  }

  return 'LinearGradient('
      'begin: ${_alignment(-dx, -dy)}, '
      'end: ${_alignment(dx, dy)}, '
      'colors: [${colors.join(', ')}], '
      'stops: [${stops.join(', ')}],)';
}

String _buildGradients(Map<String, dynamic> root, List<Token> tokens) {
  final buffer = StringBuffer()
    ..writeln(_header)
    ..writeln("import 'package:flutter/painting.dart';")
    ..writeln()
    ..writeln('abstract final class AppGradients {');

  for (final token in tokens.where(
    (token) => token.data[r'$type'] == 'color',
  )) {
    final value = _resolve(root, token.data[r'$value']) as String;
    if (!_isGradient(value)) continue;

    buffer.writeln(
      '  static const LinearGradient ${_tokenName(token.path)} = ${_linearGradientLiteral(value)};',
    );
  }

  buffer.writeln('}');
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

double _letterSpacing(Object? value, num fontSize) {
  if (value is num) return value.toDouble();
  if (value is String && value.endsWith('%')) return fontSize * _percent(value);
  return double.parse(value.toString());
}

void _writeTextStyle(
  StringBuffer buffer,
  Set<String> families,
  String name,
  String family,
  String weightName,
  num fontSize,
  double lineHeight,
  double letterSpacing,
  String textCase,
) {
  final weight =
      _fontWeights[weightName] ??
      (throw FormatException('Unknown font weight: $weightName'));
  families.add(family);
  if (textCase != 'none') {
    buffer.writeln(
      '  /// Apply text case `$textCase` to the content (not expressible in TextStyle).',
    );
  }
  buffer
    ..writeln('  static const TextStyle ${_camelCase([name])} = TextStyle(')
    ..writeln('    fontFamily: ${_familyConstant(family)},')
    ..writeln('    fontWeight: FontWeight.w$weight,')
    ..writeln('    fontSize: ${_number(fontSize)},')
    ..writeln('    height: ${_number(lineHeight)},')
    ..writeln('    letterSpacing: ${_number(letterSpacing)},')
    ..writeln('  );')
    ..writeln();
}

String? _styleField(
  Map<String, dynamic> root,
  Map<String, dynamic> style,
  String key,
) {
  final raw = style[key];
  if (raw is Map<String, dynamic>) {
    return _resolve(root, raw[r'$value'])?.toString();
  }
  return _resolve(root, raw)?.toString();
}

String _buildTypography(Map<String, dynamic> root) {
  final styles = root['basic'] as Map<String, dynamic>;
  final families = <String>{};
  final buffer = StringBuffer();

  for (final entry in styles.entries) {
    final style = entry.value as Map<String, dynamic>;
    final family = _styleField(root, style, 'fontFamily')!;
    final weightName = _styleField(root, style, 'fontWeight')!;
    final fontSize = num.parse(_styleField(root, style, 'fontSize')!);
    final lineHeight = _percent(_styleField(root, style, 'lineHeight')!);
    final letterSpacing = _letterSpacing(
      _styleField(root, style, 'letterSpacing'),
      fontSize,
    );
    final textCase = _styleField(root, style, 'textCase') ?? 'none';
    _writeTextStyle(
      buffer,
      families,
      entry.key,
      family,
      weightName,
      fontSize,
      lineHeight,
      letterSpacing,
      textCase,
    );
  }

  final roles = root['roles'] as Map<String, dynamic>? ?? {};
  for (final entry in roles.entries) {
    final style = entry.value as Map<String, dynamic>;
    final family = _styleField(root, style, 'fontFamily')!;
    final weightName = _styleField(root, style, 'fontWeight')!;
    final fontSize = num.parse(_styleField(root, style, 'fontSize')!);
    final lineHeight = _percent(_styleField(root, style, 'lineHeight')!);
    final letterSpacing = _letterSpacing(
      _styleField(root, style, 'letterSpacing'),
      fontSize,
    );
    final textCase = _styleField(root, style, 'textCase') ?? 'none';
    _writeTextStyle(
      buffer,
      families,
      entry.key,
      family,
      weightName,
      fontSize,
      lineHeight,
      letterSpacing,
      textCase,
    );
  }

  return (StringBuffer()
        ..writeln(_header)
        ..writeln("import 'package:flutter/painting.dart';")
        ..writeln()
        ..writeln('abstract final class AppFontFamilies {')
        ..writeAll(
          families.map(
            (family) =>
                "  static const String ${_camelCase([family])} = '$family';\n",
          ),
        )
        ..writeln('}')
        ..writeln()
        ..writeln('abstract final class AppTypography {')
        ..write(buffer)
        ..writeln('}'))
      .toString();
}

String _familyConstant(String family) =>
    'AppFontFamilies.${_camelCase([family])}';

// ---------------------------------------------------------------------------
// Spacing
// ---------------------------------------------------------------------------

String _buildSpacing(Map<String, dynamic> root) {
  final spacing = root['spacing'] as Map<String, dynamic>? ?? {};
  final buffer = StringBuffer()
    ..writeln(_header)
    ..writeln('abstract final class AppSpacing {');

  for (final entry in spacing.entries) {
    final value = num.parse(
      _resolve(
        root,
        (entry.value as Map<String, dynamic>)[r'$value'],
      ).toString(),
    );
    final name = entry.key.replaceAll('.', '_');
    buffer.writeln('  static const double s$name = ${_number(value)};');
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _scaleName(String key) => 's${key.replaceAll('.', '_')}';

String _radiusName(String key) => 'r${key.replaceAll('.', '_')}';

String _buildScaleClass(
  Map<String, dynamic> root,
  String group,
  String className,
  String Function(String key) nameFor,
) {
  final scale = root[group] as Map<String, dynamic>? ?? {};
  final buffer = StringBuffer()
    ..writeln(_header)
    ..writeln('abstract final class $className {');

  for (final entry in scale.entries) {
    final value = num.parse(
      _resolve(
        root,
        (entry.value as Map<String, dynamic>)[r'$value'],
      ).toString(),
    );
    buffer.writeln(
      '  static const double ${nameFor(entry.key)} = ${_number(value)};',
    );
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _buildFontSizes(Map<String, dynamic> root) =>
    _buildScaleClass(root, 'fontScale', 'AppFontSizes', _scaleName);

String _buildRadii(Map<String, dynamic> root) =>
    _buildScaleClass(root, 'radius', 'AppRadii', _radiusName);
