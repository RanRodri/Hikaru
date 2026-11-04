import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/library/domain/library_collection.dart';
import 'package:hikaru/features/library/domain/library_image_sizes.dart';
import 'package:hikaru/features/library/domain/library_topic_content.dart';
import 'package:hikaru/features/library/presentation/library_screen.dart';
import 'package:hikaru/features/library/presentation/library_topic_screen.dart';
import 'package:hikaru/features/library/presentation/library_topic_widgets.dart';
import 'package:hikaru/l10n/app_localizations.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const List<String> _topicIds = [
  'merkaba',
  'rituals',
  'jade',
  'whiteQuartz',
  'obsidian',
  'redJasper',
  'meridians',
  'lymphatic',
  'fascia',
  'gua_sha',
];

/// Every user-facing string of a raw `content.json`, found by walking the
/// JSON instead of reusing the app's parser.
Set<String> _expectedStrings(String json) {
  final out = <String>{};
  final uncertain = RegExp(r'\s*\[UNCERTAIN\]');
  final note = RegExp(r'\s*\(emphasis/italic gold:.*\)\s*$', dotAll: true);

  void add(Object? value) {
    if (value is! String) return;
    final cleaned = value.replaceAll(note, '').replaceAll(uncertain, '');
    for (final line in cleaned.split('\n')) {
      if (line.trim().isNotEmpty) out.add(line);
    }
  }

  void addItems(Object? items) {
    for (final item in (items as List? ?? const [])) {
      if (item is String) {
        add(item);
      } else if (item is Map) {
        add(item['label']);
        add(item['desc']);
        for (final bullet in (item['bullets'] as List? ?? const [])) {
          add(bullet);
        }
      }
    }
  }

  final sections =
      (jsonDecode(json) as Map<String, dynamic>)['sections'] as List;
  for (final raw in sections.cast<Map<String, dynamic>>()) {
    final type = raw['type'];
    if (type == 'brand' || type == 'image') continue;
    if (type == 'cta' && '${raw['text']}'.startsWith('SELECT')) continue;
    add(raw['text']);
    add(raw['heading']);
    final sub = raw['sub'];
    if (sub is String && !sub.startsWith('NOTE:')) add(sub);
    for (final key in ['bullets', 'checks']) {
      for (final line in (raw[key] as List? ?? const [])) {
        add(line);
      }
    }
    addItems(raw['items']);
  }
  return out;
}

/// Scrolls the page until [finder] sits mid-screen, clear of the bars.
Future<void> _bringToMiddle(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(finder, 300, scrollable: scrollable);
  final screenMiddle = tester.view.physicalSize.height / 2;
  final dy = tester.getCenter(finder).dy - screenMiddle;
  await tester.drag(scrollable, Offset(0, -dy));
  await tester.pump(const Duration(milliseconds: 700));
}

String _allRenderedText(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((widget) => widget.text.toPlainText())
    .join('\n');

void main() {
  // Read the JSON once, outside any fake-async test zone. A cached bundle
  // future created inside one testWidgets never completes in the next.
  final jsonById = <String, String>{};
  setUpAll(() {
    for (final id in _topicIds) {
      final source = libraryTopicSources[id]!;
      jsonById[id] = File(source.contentAsset).readAsStringSync();
    }
  });

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<LibraryTopicContent> load(String id) async =>
      LibraryTopicContent.fromJson(id, libraryTopicSources[id]!, jsonById[id]!);

  Future<void> pumpTopic(
    WidgetTester tester,
    LibraryTopicContent content, {
    Size size = const Size(360, 640),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LibraryTopicScreen(content: content),
        ),
        GoRoute(
          path: AppRoutes.merkaba,
          builder: (context, state) => const Text('MERKABA SESSION'),
        ),
        GoRoute(
          path: AppRoutes.library,
          builder: (context, state) => const Text('LIBRARY'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  test('every image a topic uses exists and has a known native size', () async {
    for (final id in _topicIds) {
      final source = libraryTopicSources[id]!;
      final content = await load(id);
      final files = <String>{
        ?content.hero?.asset,
        for (final section in content.sections)
          ...switch (section) {
            LibraryImage(:final asset) => [asset],
            LibraryCard(:final asset) => [?asset],
            LibraryCards(:final items) ||
            LibraryRows(:final items) => [
              for (final item in items) ?item.asset,
            ],
            _ => const <String>[],
          },
      };
      for (final file in files) {
        expect(
          File('assets/images/library/${source.images}/$file').existsSync(),
          isTrue,
          reason: '$id/$file',
        );
        expect(
          libraryImageSizes.containsKey(source.sizeKey(file)),
          isTrue,
          reason: '$id/$file',
        );
      }
    }
  });

  test('parser keeps content.json text and drops only editorial marks', () async {
    for (final id in _topicIds) {
      final json = jsonById[id]!;
      final content = await load(id);
      final parsed = content.allText.expand((text) => text.split('\n')).toSet();
      for (final expected in _expectedStrings(json)) {
        expect(parsed, contains(expected), reason: '$id: $expected');
      }
      for (final text in parsed) {
        expect(text, isNot(contains('[UNCERTAIN]')), reason: id);
        expect(text, isNot(contains('emphasis/italic')), reason: id);
        expect(text, isNot(startsWith('NOTE:')), reason: id);
        expect(text, isNot(contains('SELECT THIS CRYSTAL')), reason: id);
      }
    }
  });

  for (final id in _topicIds) {
    testWidgets('$id shows all of its content text', (tester) async {
      final json = jsonById[id]!;
      final content = await load(id);
      // A tall surface builds every sliver child at once.
      await pumpTopic(tester, content, size: const Size(360, 40000));
      await tester.pump(const Duration(milliseconds: 800));

      final rendered = _allRenderedText(tester);
      for (final expected in _expectedStrings(json)) {
        expect(rendered, contains(expected), reason: '$id: $expected');
      }
      expect(rendered, isNot(contains('SELECT THIS CRYSTAL')));
      expect(rendered, isNot(contains('01 / 04')));
      expect(rendered, isNot(contains('[UNCERTAIN]')));
    });

    for (final scale in [1.0, 1.3]) {
      testWidgets('$id scrolls at 360x640, text x$scale, without overflow', (
        tester,
      ) async {
        final content = await load(id);
        await pumpTopic(tester, content, textScale: scale);

        final scrollable = find.byType(CustomScrollView);
        for (var i = 0; i < 12; i++) {
          await tester.drag(scrollable, const Offset(0, -420));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('an odd last card in a two-column grid is centered', (
    tester,
  ) async {
    final content = await load('rituals');
    await pumpTopic(tester, content, size: const Size(360, 40000));

    final card = find.ancestor(
      of: find.text('A MORE RADIANT, VITAL & YOUTHFUL LOOK'),
      matching: find.byType(LibraryPanel),
    );
    expect(card, findsOneWidget);
    expect(tester.getCenter(card).dx, closeTo(180, 1));
  });

  testWidgets('photos are never drawn larger than their native size', (
    tester,
  ) async {
    final content = await load('merkaba');
    await pumpTopic(tester, content, size: const Size(360, 40000));

    final source = content.source;
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      final provider = image.image;
      final asset = switch (provider) {
        ResizeImage(:final imageProvider) when imageProvider is AssetImage =>
          imageProvider.assetName,
        AssetImage() => provider.assetName,
        _ => null,
      };
      if (asset == null || !asset.contains('/library/')) continue;
      final native = libraryImageSizes[asset.split('/library/').last];
      if (native == null) continue;
      final size = element.size!;
      expect(size.width, lessThanOrEqualTo(native.$1 + 0.5), reason: asset);
      expect(size.height, lessThanOrEqualTo(native.$2 + 0.5), reason: asset);
    }
    expect(source.images, 'merkaba');
  });

  testWidgets('the Merkaba video card opens the Merkaba session', (
    tester,
  ) async {
    final content = await load('merkaba');
    await pumpTopic(tester, content);

    await _bringToMiddle(tester, find.text(libraryGuidedActivationHeading));
    await tester.tap(find.text(libraryGuidedActivationHeading));
    await tester.pumpAndSettle();

    expect(find.text('MERKABA SESSION'), findsOneWidget);
  });

  testWidgets('the meridians map opens full screen with zoom', (tester) async {
    final content = await load('meridians');
    await pumpTopic(tester, content);

    final cta = find.text('EXPLORE THE MERIDIANS MAP →');
    await _bringToMiddle(tester, cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.byType(LibraryMapViewer), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('the library no longer shows the method topics as circles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LibraryScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    for (final page in libraryRitualPages.skip(1)) {
      expect(
        find.bySemanticsLabel('${page.name}, ${page.inlineDetail}'),
        findsNothing,
        reason: page.id,
      );
    }
  });

  testWidgets('The Hikaru Ritual pages swipe and switch from the tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pages = [for (final page in libraryRitualPages) await load(page.id)];
    final tabs = [
      for (final page in libraryRitualPages)
        LibraryTopicTab(
          label: libraryRitualPageLabels[page.id]!,
          thumbnail: page.imageAsset,
        ),
    ];
    for (final tab in tabs) {
      expect(File(tab.thumbnail).existsSync(), isTrue, reason: tab.label);
    }

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              LibraryTopicScreen.paged(pages: pages, tabs: tabs),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    Future<void> frames() async {
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    PageController controller() =>
        tester.widget<PageView>(find.byType(PageView)).controller!;

    expect(find.text('THE HIKARU RITUAL'), findsWidgets);
    for (final tab in tabs) {
      expect(find.bySemanticsLabel(tab.label), findsOneWidget);
    }

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await frames();
    expect(controller().page, closeTo(1, 0.01));
    expect(find.text('GUA SHA'), findsWidgets);

    await tester.ensureVisible(find.bySemanticsLabel('FASCIA'));
    await frames();
    await tester.tap(find.bySemanticsLabel('FASCIA'));
    await frames();
    expect(controller().page, closeTo(4, 0.01));
    expect(find.text('THE FASCIA'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
