import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _lutWidth = 512;
const _octaves = [1, 2, 4];
const _partialWeights = [1.0, 0.78, 0.60, 0.46];
const _octaveWeights = [1.0, 0.52, 0.27];
const _rootScanStep = 0.05;
const _rootTolerance = 1e-11;

const _crystals = [
  _CrystalSpec(
    dartName: 'whiteQuartz',
    fileName: 'white_quartz',
    symmetry: 12,
    partials: [73.4, 146, 220, 294],
  ),
  _CrystalSpec(
    dartName: 'jade',
    fileName: 'jade',
    symmetry: 10,
    partials: [65.4, 131, 196, 262],
  ),
  _CrystalSpec(
    dartName: 'obsidian',
    fileName: 'obsidian',
    symmetry: 6,
    partials: [87.3, 174, 262, 349],
  ),
  _CrystalSpec(
    dartName: 'redJasper',
    fileName: 'red_jasper',
    symmetry: 8,
    partials: [82.4, 164, 247, 330],
  ),
];

/// Generates radial Chladni lookup textures and their domain metadata.
///
/// Run from the repository root:
/// `dart run tool/generate_cymatic_plate_luts.dart`
///
/// Rows are ordered by partial, then octave x1, x2, x4. Frequencies below
/// 50 Hz are discarded. Each effective frequency maps to a dimensionless
/// target wave number with `targetK = sqrt(frequencyHz)`. For every target,
/// the generator searches positive zeros of J_m where m is an exact,
/// non-negative multiple of the crystal symmetry. Including m=0 allows
/// concentric modes. The closest root wins; ties prefer lower m, then lower k.
///
/// The Bessel evaluator uses rational J_0/J_1 approximations followed by
/// stable upward recurrence at x >= m, and Miller downward recurrence below
/// that boundary. Roots are bracketed on a fixed 0.05 grid and refined by
/// deterministic bisection.
Future<void> main() async {
  final generated = <_GeneratedCrystal>[];

  for (final crystal in _crystals) {
    final frequencies = <double>[
      for (final partial in crystal.partials)
        if (partial >= 50)
          for (final octave in _octaves) partial * octave,
    ];
    if (frequencies.length != 12) {
      throw StateError(
        '${crystal.dartName} produced ${frequencies.length} rows, expected 12',
      );
    }

    final targets = [for (final frequency in frequencies) math.sqrt(frequency)];
    final roots = _candidateRoots(crystal.symmetry, targets.reduce(math.max));
    final modes = [for (final target in targets) _closestMode(target, roots)];
    final weights = _normalizedWeights();
    final encodedRows = <Uint8List>[];
    final radialRms = <double>[];

    for (final mode in modes) {
      final row = _sampleRow(mode.m, mode.k);
      encodedRows.add(row.bytes);
      radialRms.add(row.rms);
    }

    final pngBytes = _encodeRgbaPng(_lutWidth, encodedRows.length, encodedRows);
    final assetPath = 'assets/cymatic/lut_${crystal.fileName}.png';
    final asset = File(assetPath);
    await asset.parent.create(recursive: true);
    await asset.writeAsBytes(pngBytes, flush: true);

    generated.add(
      _GeneratedCrystal(
        spec: crystal,
        frequencies: frequencies,
        modes: modes,
        weights: weights,
        radialRms: radialRms,
      ),
    );
    stdout.writeln('$assetPath  ${_lutWidth}x${encodedRows.length} RGBA');
  }

  final dartPath =
      'lib/features/resonance_chamber/domain/cymatic_plate_profiles.g.dart';
  final dartFile = File(dartPath);
  await dartFile.parent.create(recursive: true);
  await dartFile.writeAsString(_generateDart(generated), flush: true);
  stdout.writeln('$dartPath  ${generated.length} crystal profiles');
}

List<_Mode> _candidateRoots(int symmetry, double maximumTarget) {
  final upper = maximumTarget + 2 * math.pi;
  final roots = <_Mode>[];
  for (var m = 0; m <= upper.floor(); m += symmetry) {
    var left = m == 0 ? 1e-7 : m.toDouble();
    var leftValue = _besselJ(m, left);
    for (
      var right = left + _rootScanStep;
      right <= upper;
      right += _rootScanStep
    ) {
      final rightValue = _besselJ(m, right);
      if (leftValue * rightValue < 0) {
        final root = _bisectRoot(m, left, right, leftValue);
        if (_besselJ(m, root).abs() > 2e-7) {
          throw StateError('Root residual too large for J_$m($root)');
        }
        roots.add(_Mode(m, root));
      }
      left = right;
      leftValue = rightValue;
    }
  }
  if (roots.isEmpty) throw StateError('No Bessel roots found for S=$symmetry');
  return roots;
}

_Mode _closestMode(double target, List<_Mode> roots) {
  var best = roots.first;
  var bestDistance = (best.k - target).abs();
  for (final candidate in roots.skip(1)) {
    final distance = (candidate.k - target).abs();
    if (distance < bestDistance - 1e-12 ||
        ((distance - bestDistance).abs() <= 1e-12 &&
            (candidate.m < best.m ||
                (candidate.m == best.m && candidate.k < best.k)))) {
      best = candidate;
      bestDistance = distance;
    }
  }
  return best;
}

double _bisectRoot(int m, double left, double right, double leftValue) {
  var low = left;
  var high = right;
  var lowValue = leftValue;
  while (high - low > _rootTolerance) {
    final middle = (low + high) * 0.5;
    final middleValue = _besselJ(m, middle);
    if (lowValue * middleValue <= 0) {
      high = middle;
    } else {
      low = middle;
      lowValue = middleValue;
    }
  }
  return (low + high) * 0.5;
}

_Row _sampleRow(int m, double k) {
  final values = List<double>.filled(_lutWidth, 0);
  var peak = 0.0;
  for (var x = 0; x < _lutWidth; x++) {
    final radius = x / (_lutWidth - 1);
    final value = _besselJ(m, k * radius);
    values[x] = value;
    peak = math.max(peak, value.abs());
  }
  if (peak <= 0) throw StateError('Zero-amplitude row for J_$m($k r)');

  final bytes = Uint8List(_lutWidth * 4);
  var squareSum = 0.0;
  for (var x = 0; x < _lutWidth; x++) {
    final normalized = (values[x] / peak).clamp(-1.0, 1.0);
    final encoded = ((normalized + 1) * 32767.5).round().clamp(0, 65535);
    final decoded = encoded / 32767.5 - 1;
    squareSum += decoded * decoded;
    final offset = x * 4;
    bytes[offset] = encoded >> 8;
    bytes[offset + 1] = encoded & 0xff;
    bytes[offset + 2] = 0;
    bytes[offset + 3] = 255;
  }
  return _Row(bytes, math.sqrt(squareSum / _lutWidth));
}

List<double> _normalizedWeights() {
  final weights = <double>[
    for (final partialWeight in _partialWeights)
      for (final octaveWeight in _octaveWeights) partialWeight * octaveWeight,
  ];
  final sum = weights.fold<double>(0, (total, value) => total + value);
  return [for (final weight in weights) weight / sum];
}

// Integer-order cylindrical Bessel J. The coefficients are the standard
// minimax approximations commonly used for J_0 and J_1.
double _besselJ(int order, double x) {
  if (order < 0 || x < 0) throw ArgumentError('Expected order and x >= 0');
  if (x == 0) return order == 0 ? 1 : 0;
  if (order == 0) return _besselJ0(x);
  if (order == 1) return _besselJ1(x);

  if (x >= order) {
    final scale = 2 / x;
    var previous = _besselJ0(x);
    var current = _besselJ1(x);
    for (var n = 1; n < order; n++) {
      final next = n * scale * current - previous;
      previous = current;
      current = next;
    }
    return current;
  }

  const accuracy = 40.0;
  const large = 1e100;
  const inverseLarge = 1e-100;
  final scale = 2 / x;
  var start = 2 * ((order + math.sqrt(accuracy * order)).floor() ~/ 2);
  if (start < order + 2) start = order + 2;
  var next = 0.0;
  var current = 1.0;
  var sum = 0.0;
  var addToSum = false;
  var answer = 0.0;
  for (var n = start; n > 0; n--) {
    final previous = n * scale * current - next;
    next = current;
    current = previous;
    if (current.abs() > large) {
      current *= inverseLarge;
      next *= inverseLarge;
      answer *= inverseLarge;
      sum *= inverseLarge;
    }
    if (addToSum) sum += current;
    addToSum = !addToSum;
    if (n == order) answer = next;
  }
  return answer / (2 * sum - current);
}

double _besselJ0(double x) {
  if (x < 8) {
    final y = x * x;
    final numerator =
        57568490574.0 +
        y *
            (-13362590354.0 +
                y *
                    (651619640.7 +
                        y *
                            (-11214424.18 +
                                y * (77392.33017 - y * 184.9052456))));
    final denominator =
        57568490411.0 +
        y *
            (1029532985.0 +
                y * (9494680.718 + y * (59272.64853 + y * (267.8532712 + y))));
    return numerator / denominator;
  }
  final z = 8 / x;
  final y = z * z;
  final phase = x - 0.785398164;
  final p =
      1 +
      y *
          (-0.001098628627 +
              y *
                  (0.00002734510407 +
                      y * (-0.000002073370639 + y * 2.093887211e-7)));
  final q =
      -0.01562499995 +
      y *
          (0.0001430488765 +
              y *
                  (-0.000006911147651 +
                      y * (7.621095161e-7 - y * 9.34945152e-8)));
  return math.sqrt(0.636619772 / x) *
      (math.cos(phase) * p - z * math.sin(phase) * q);
}

double _besselJ1(double x) {
  if (x < 8) {
    final y = x * x;
    final numerator =
        x *
        (72362614232.0 +
            y *
                (-7895059235.0 +
                    y *
                        (242396853.1 +
                            y *
                                (-2972611.439 +
                                    y * (15704.48260 - y * 30.16036606)))));
    final denominator =
        144725228442.0 +
        y *
            (2300535178.0 +
                y * (18583304.74 + y * (99447.43394 + y * (376.9991397 + y))));
    return numerator / denominator;
  }
  final z = 8 / x;
  final y = z * z;
  final phase = x - 2.356194491;
  final p =
      1 +
      y *
          (0.00183105 +
              y *
                  (-0.00003516396496 +
                      y * (0.000002457520174 - y * 2.40337019e-7)));
  final q =
      0.04687499995 +
      y *
          (-0.0002002690873 +
              y *
                  (0.000008449199096 +
                      y * (-8.8228987e-7 + y * 1.05787412e-7)));
  return math.sqrt(0.636619772 / x) *
      (math.cos(phase) * p - z * math.sin(phase) * q);
}

Uint8List _encodeRgbaPng(int width, int height, List<Uint8List> rows) {
  if (rows.length != height || rows.any((row) => row.length != width * 4)) {
    throw ArgumentError('PNG rows do not match ${width}x$height RGBA');
  }
  final raw = BytesBuilder(copy: false);
  for (final row in rows) {
    raw.addByte(0); // PNG filter: None.
    raw.add(row);
  }

  final output = BytesBuilder(copy: false)
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
    ..add(_pngChunk('IHDR', _ihdr(width, height)))
    ..add(
      _pngChunk(
        'IDAT',
        Uint8List.fromList(ZLibCodec().encode(raw.takeBytes())),
      ),
    )
    ..add(_pngChunk('IEND', Uint8List(0)));
  return output.takeBytes();
}

Uint8List _ihdr(int width, int height) {
  final bytes = Uint8List(13);
  ByteData.sublistView(bytes)
    ..setUint32(0, width, Endian.big)
    ..setUint32(4, height, Endian.big);
  bytes[8] = 8;
  bytes[9] = 6; // 8-bit RGBA.
  return bytes;
}

Uint8List _pngChunk(String type, Uint8List payload) {
  final typeBytes = Uint8List.fromList(type.codeUnits);
  final bytes = Uint8List(12 + payload.length);
  final data = ByteData.sublistView(bytes)
    ..setUint32(0, payload.length, Endian.big);
  bytes.setRange(4, 8, typeBytes);
  bytes.setRange(8, 8 + payload.length, payload);
  data.setUint32(
    8 + payload.length,
    _crc32([...typeBytes, ...payload]),
    Endian.big,
  );
  return bytes;
}

int _crc32(List<int> bytes) {
  var crc = 0xffffffff;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}

String _generateDart(List<_GeneratedCrystal> crystals) {
  final output = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Generated by tool/generate_cymatic_plate_luts.dart.')
    ..writeln()
    ..writeln("import '../../crystals/domain/crystal.dart';")
    ..writeln()
    ..writeln('final class CymaticPlateProfile {')
    ..writeln('  const CymaticPlateProfile({')
    ..writeln('    required this.lutAsset,')
    ..writeln('    required this.frequencies,')
    ..writeln('    required this.symmetry,')
    ..writeln('    required this.modes,')
    ..writeln('    required this.weights,')
    ..writeln('    required this.radialRms,')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final String lutAsset;')
    ..writeln('  final List<double> frequencies;')
    ..writeln('  final int symmetry;')
    ..writeln('  final List<int> modes;')
    ..writeln('  final List<double> weights;')
    ..writeln('  final List<double> radialRms;')
    ..writeln('}')
    ..writeln()
    ..writeln(
      '/// Row order is partial-major, with octave x1, x2, x4 per partial.',
    )
    ..writeln(
      '/// Frequencies, modes, weights, and LUT rows share the same order.',
    )
    ..writeln(
      '/// Weights sum to 1. Radial RMS values match the quantized LUT rows.',
    )
    ..writeln('const cymaticPlateProfiles = <Crystal, CymaticPlateProfile>{');

  for (final crystal in crystals) {
    output
      ..writeln('  Crystal.${crystal.spec.dartName}: CymaticPlateProfile(')
      ..writeln(
        "    lutAsset: 'assets/cymatic/lut_${crystal.spec.fileName}.png',",
      )
      ..writeln('    frequencies: [')
      ..writeln(_formatDoubles(crystal.frequencies, indent: '      '))
      ..writeln('    ],')
      ..writeln('    symmetry: ${crystal.spec.symmetry},')
      ..writeln(
        '    modes: [${crystal.modes.map((mode) => mode.m).join(', ')}],',
      )
      ..writeln('    weights: [')
      ..writeln(_formatDoubles(crystal.weights, indent: '      '))
      ..writeln('    ],')
      ..writeln('    radialRms: [')
      ..writeln(_formatDoubles(crystal.radialRms, indent: '      '))
      ..writeln('    ],')
      ..writeln('  ),');
  }

  output
    ..writeln('};')
    ..writeln()
    ..writeln('extension CymaticPlateProfileForCrystal on Crystal {')
    ..writeln('  CymaticPlateProfile get cymaticPlateProfile =>')
    ..writeln('      cymaticPlateProfiles[this]!;')
    ..writeln('}');
  return output.toString();
}

String _formatDoubles(List<double> values, {required String indent}) {
  return [
    for (var start = 0; start < values.length; start += 4)
      '$indent${values.skip(start).take(4).map((value) => value.toStringAsFixed(10)).join(', ')},',
  ].join('\n');
}

final class _CrystalSpec {
  const _CrystalSpec({
    required this.dartName,
    required this.fileName,
    required this.symmetry,
    required this.partials,
  });

  final String dartName;
  final String fileName;
  final int symmetry;
  final List<double> partials;
}

final class _Mode {
  const _Mode(this.m, this.k);

  final int m;
  final double k;
}

final class _Row {
  const _Row(this.bytes, this.rms);

  final Uint8List bytes;
  final double rms;
}

final class _GeneratedCrystal {
  const _GeneratedCrystal({
    required this.spec,
    required this.frequencies,
    required this.modes,
    required this.weights,
    required this.radialRms,
  });

  final _CrystalSpec spec;
  final List<double> frequencies;
  final List<_Mode> modes;
  final List<double> weights;
  final List<double> radialRms;
}
