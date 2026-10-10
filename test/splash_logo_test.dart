import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hiraku/core/design_system/tokens/app_colors.dart';
import 'package:hiraku/features/splash/presentation/splash_logo.dart';

void main() {
  testWidgets('locked figure-8 is a narrow rounded amber mark', (
    WidgetTester tester,
  ) async {
    final stats = await _measureMark(tester, 7.2 / 7.5);
    expect(stats.widthFraction, inInclusiveRange(0.44, 0.51));
    expect(stats.heightFraction, inInclusiveRange(0.50, 0.58));
    expect(
      stats.flatRows,
      greaterThan(10),
      reason: 'side caps should be rounded, not a single-pixel tip',
    );
    expect(stats.leftRuns, inInclusiveRange(8, 12));
    expect(stats.gapSpread, lessThan(2.5));
    expect(stats.meanRed, greaterThan(stats.meanGreen));
    expect(stats.meanGreen, greaterThan(stats.meanBlue + 20));
    expect(stats.meanBlue, lessThan(150));
    expect(stats.meanRed, lessThan(230));
  });
}

class _MarkStats {
  const _MarkStats({
    required this.widthFraction,
    required this.heightFraction,
    required this.flatRows,
    required this.leftRuns,
    required this.gapSpread,
    required this.meanRed,
    required this.meanGreen,
    required this.meanBlue,
  });

  final double widthFraction;
  final double heightFraction;
  final int flatRows;
  final int leftRuns;
  final double gapSpread;
  final double meanRed;
  final double meanGreen;
  final double meanBlue;
}

Future<_MarkStats> _measureMark(WidgetTester tester, double t) async {
  tester.view.physicalSize = const Size(860, 1864);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.darkIndigoBlue,
        body: RepaintBoundary(
          key: const Key('mark'),
          child: ColoredBox(
            color: AppColors.darkIndigoBlue,
            child: CustomPaint(
              painter: SplashLogoPainter(wordmark: null, t: t),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('mark')),
  );
  final captured = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final size = (width: image.width, height: image.height);
    image.dispose();
    return (bytes: bytes, width: size.width, height: size.height);
  });
  final bytes = captured?.bytes;
  final width = captured?.width ?? 0;
  final height = captured?.height ?? 0;
  if (bytes == null) fail('mark image has no bytes');

  final data = bytes.buffer.asUint8List();
  bool goldAt(int x, int y) {
    final i = (y * width + x) * 4;
    final r = data[i];
    final g = data[i + 1];
    final b = data[i + 2];
    return r > 70 && g > 35 && r > b + 28;
  }

  final rows = <List<int>>[];
  var red = 0;
  var green = 0;
  var blue = 0;
  var count = 0;
  for (var y = 0; y < height; y++) {
    final xs = <int>[];
    for (var x = 0; x < width; x++) {
      if (!goldAt(x, y)) continue;
      xs.add(x);
      final i = (y * width + x) * 4;
      red += data[i];
      green += data[i + 1];
      blue += data[i + 2];
      count++;
    }
    rows.add(xs);
  }
  if (count == 0) fail('figure-8 painted no gold');

  // The mark is the wide rows. The dot below the loops is a narrow run.
  final figureRows = <int>[];
  for (var y = 0; y < height; y++) {
    if (rows[y].isEmpty) continue;
    if (rows[y].last - rows[y].first > 40) figureRows.add(y);
  }
  expect(figureRows, isNotEmpty);
  var minX = width;
  var maxX = 0;
  for (final y in figureRows) {
    if (rows[y].first < minX) minX = rows[y].first;
    if (rows[y].last > maxX) maxX = rows[y].last;
  }
  final topHalf = figureRows.where(
    (y) => y < figureRows.first + (figureRows.last - figureRows.first) ~/ 2,
  );
  var maxSpan = 0;
  for (final y in topHalf) {
    final span = rows[y].last - rows[y].first;
    if (span > maxSpan) maxSpan = span;
  }
  final flatRows = topHalf.where((y) {
    return rows[y].last - rows[y].first >= maxSpan - 4;
  }).length;

  final wideY = topHalf.firstWhere(
    (y) => rows[y].last - rows[y].first >= maxSpan - 2,
  );
  final mid = width ~/ 2;
  final left = rows[wideY].where((x) => x < mid).toList();
  final runs = <double>[];
  if (left.isNotEmpty) {
    var start = left.first;
    var prev = left.first;
    for (final x in left.skip(1)) {
      if (x > prev + 3) {
        runs.add((start + prev) / 2);
        start = x;
      }
      prev = x;
    }
    runs.add((start + prev) / 2);
  }
  final gaps = <double>[
    for (var i = 1; i < runs.length; i++) runs[i] - runs[i - 1],
  ];
  var spread = 0.0;
  if (gaps.isNotEmpty) {
    final mean = gaps.reduce((a, b) => a + b) / gaps.length;
    for (final gap in gaps) {
      final delta = (gap - mean).abs();
      if (delta > spread) spread = delta;
    }
  }

  return _MarkStats(
    widthFraction: (maxX - minX + 1) / width,
    heightFraction: (figureRows.last - figureRows.first + 1) / height,
    flatRows: flatRows,
    leftRuns: runs.length,
    gapSpread: spread,
    meanRed: red / count,
    meanGreen: green / count,
    meanBlue: blue / count,
  );
}
