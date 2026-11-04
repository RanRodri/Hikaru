import 'dart:convert';

import 'library_article.dart';
import 'library_collection.dart';

/// Where a topic's infographic content lives.
///
/// `content` is the JSON shipped in `assets/library_content/` and `images` is
/// the folder under `assets/images/library/` that holds its `.webp` files.
class LibraryTopicSource {
  const LibraryTopicSource({required this.content, required this.images});

  final String content;
  final String images;

  String get contentAsset => 'assets/library_content/$content.json';

  String imageAsset(String file) => 'assets/images/library/$images/$file';

  /// Key of [file] in `libraryImageSizes`.
  String sizeKey(String file) => '$images/$file';
}

/// Topics drawn from the client infographics, by library collection id.
///
/// TODO(client): Jade is provisional. Its copy reuses existing app content
/// and its art reuses current Jade assets. Replace both when the official
/// infographic arrives.
const Map<String, LibraryTopicSource> libraryTopicSources = {
  libraryMerkabaId: LibraryTopicSource(content: 'merkaba', images: 'merkaba'),
  libraryRitualsId: LibraryTopicSource(content: 'rituals', images: 'rituals'),
  'jade': LibraryTopicSource(
    content: 'crystal_jade',
    images: 'crystal_jade',
  ),
  'whiteQuartz': LibraryTopicSource(
    content: 'crystal_white_quartz',
    images: 'crystal_white_quartz',
  ),
  'obsidian': LibraryTopicSource(
    content: 'crystal_obsidian',
    images: 'crystal_obsidian',
  ),
  'redJasper': LibraryTopicSource(
    content: 'crystal_red_jasper',
    images: 'crystal_red_jasper',
  ),
  libraryMeridiansId: LibraryTopicSource(
    content: 'meridians',
    images: 'meridians',
  ),
  libraryLymphaticId: LibraryTopicSource(
    content: 'lymphatic',
    images: 'lymphatic',
  ),
  libraryFasciaId: LibraryTopicSource(content: 'fascia', images: 'fascia'),
  libraryGuaShaId: LibraryTopicSource(content: 'gua_sha', images: 'gua_sha'),
};

/// One entry of a card, row, step or list.
class LibraryItem {
  const LibraryItem({
    required this.label,
    this.desc = '',
    this.icon,
    this.asset,
    this.bullets = const [],
  });

  final String label;
  final String desc;

  /// Name of a line icon, see `libraryIconFor`.
  final String? icon;

  /// Image file name inside the topic's image folder.
  final String? asset;
  final List<String> bullets;
}

enum LibraryCardsLayout { grid2, hscroll }

sealed class LibrarySection {
  const LibrarySection();
}

class LibraryHeading extends LibrarySection {
  const LibraryHeading(this.text, {this.sub});

  final String text;
  final String? sub;
}

class LibraryParagraph extends LibrarySection {
  const LibraryParagraph(
    this.text, {
    this.italic = false,
    this.emphasis = const [],
  });

  final String text;
  final bool italic;

  /// Phrases of [text] the infographic highlights in italic gold.
  final List<String> emphasis;
}

class LibraryImage extends LibrarySection {
  const LibraryImage(this.asset, {this.small = false});

  final String asset;
  final bool small;
}

class LibraryCard extends LibrarySection {
  const LibraryCard({
    required this.heading,
    this.asset,
    this.icon,
    this.text,
    this.bullets = const [],
    this.checks = const [],
  });

  final String heading;
  final String? asset;
  final String? icon;
  final String? text;
  final List<String> bullets;
  final List<String> checks;
}

class LibraryCards extends LibrarySection {
  const LibraryCards(this.layout, this.items);

  final LibraryCardsLayout layout;
  final List<LibraryItem> items;
}

class LibraryRows extends LibrarySection {
  const LibraryRows(this.items);

  final List<LibraryItem> items;
}

class LibraryNumbered extends LibrarySection {
  const LibraryNumbered(this.items, {this.circular = false});

  final List<LibraryItem> items;

  /// Draw the steps around a ring (the 4-4-6 breath) instead of a list.
  final bool circular;
}

class LibraryChecklist extends LibrarySection {
  const LibraryChecklist(this.items);

  final List<String> items;
}

class LibraryBullets extends LibrarySection {
  const LibraryBullets(this.items);

  final List<String> items;
}

class LibraryCta extends LibrarySection {
  const LibraryCta(this.text);

  final String text;
}

/// A topic ready to draw: header lines, hero image and body sections in
/// reading order.
class LibraryTopicContent {
  const LibraryTopicContent({
    required this.id,
    required this.source,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.tagline,
    this.hero,
    required this.sections,
  });

  final String id;
  final LibraryTopicSource source;
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? tagline;
  final LibraryImage? hero;
  final List<LibrarySection> sections;

  /// Parses the verbatim `content.json` of a topic.
  ///
  /// Text is kept as written. Only editorial marks are removed: the
  /// `[UNCERTAIN]` flags and the `(emphasis/italic gold: ...)` notes.
  ///
  /// TODO(client): confirm the phrases that were flagged `[UNCERTAIN]` in the
  /// rituals infographic. They are shown without the mark:
  ///  - "Supports the lymphatic system"
  ///  - "frequency music" (in the A MULTI-FUNCTIONAL DESIGN paragraph)
  ///  - "renowned musician Jorge Alfano"
  ///  - "body, mind, and energy field"
  ///  - "Crystal energetics"
  ///  - "Presence & renewal"
  /// TODO(client): the rituals paragraph under HIKARU LIFT® ends with an
  /// unfinished sentence ("... experience. the facial and body vitality,
  /// beauty, and longevity."), and Obsidian lists "Protection" twice. Both are
  /// shown as supplied.
  /// TODO(client): the other `typos_fixed` entries in each `content.json`
  /// are listed in the pull request for review.
  factory LibraryTopicContent.fromJson(
    String id,
    LibraryTopicSource source,
    String json,
  ) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final raw = (data['sections'] as List).cast<Map<String, dynamic>>();

    String? eyebrow;
    String? subtitle;
    String? tagline;
    String title = '';
    LibraryImage? hero;
    final sections = <LibrarySection>[];
    var bodyStarted = false;

    for (final entry in raw) {
      final type = entry['type'] as String;
      switch (type) {
        case 'brand':
          break; // The app header already carries the logo.
        case 'eyebrow':
          eyebrow = cleanLibraryText(entry['text'] as String).text;
        case 'title':
          title = cleanLibraryText(entry['text'] as String).text;
        case 'subtitle':
          subtitle = cleanLibraryText(entry['text'] as String).text;
        case 'tagline':
          tagline = cleanLibraryText(entry['text'] as String).text;
        case 'image':
          final image = LibraryImage(
            entry['asset'] as String,
            small: entry['small'] == true,
          );
          if (hero == null && !bodyStarted) {
            hero = image;
          } else {
            sections.add(image);
          }
        default:
          final section = _section(type, entry);
          if (section == null) break;
          if (section is LibraryCard || section is LibraryCards) {
            bodyStarted = true;
          }
          sections.add(section);
      }
    }

    return LibraryTopicContent(
      id: id,
      source: source,
      title: title,
      eyebrow: eyebrow,
      subtitle: subtitle,
      tagline: tagline,
      hero: hero,
      sections: sections,
    );
  }

  /// Every string the topic shows, in reading order. Used by tests to compare
  /// the screen with `content.json`.
  List<String> get allText {
    final out = <String>[
      ?eyebrow,
      title,
      ?subtitle,
      ?tagline,
    ];
    for (final section in sections) {
      switch (section) {
        case LibraryHeading(:final text, :final sub):
          out
            ..add(text)
            ..addAll([?sub]);
        case LibraryParagraph(:final text):
          out.add(text);
        case LibraryImage():
          break;
        case LibraryCard(
          :final heading,
          :final text,
          :final bullets,
          :final checks,
        ):
          out
            ..add(heading)
            ..addAll([?text])
            ..addAll(bullets)
            ..addAll(checks);
        case LibraryCards(:final items) ||
            LibraryRows(:final items) ||
            LibraryNumbered(:final items):
          for (final item in items) {
            out
              ..add(item.label)
              ..addAll([if (item.desc.isNotEmpty) item.desc])
              ..addAll(item.bullets);
          }
        case LibraryChecklist(:final items) || LibraryBullets(:final items):
          out.addAll(items);
        case LibraryCta(:final text):
          out.add(text);
      }
    }
    return out;
  }
}

LibrarySection? _section(String type, Map<String, dynamic> entry) {
  switch (type) {
    case 'heading':
      final sub = entry['sub'] as String?;
      return LibraryHeading(
        cleanLibraryText(entry['text'] as String).text,
        // "NOTE: ..." is a hand-off remark in the pack, not infographic copy.
        sub: sub == null || sub.startsWith('NOTE:')
            ? null
            : cleanLibraryText(sub).text,
      );
    case 'paragraph':
      final cleaned = cleanLibraryText(entry['text'] as String);
      return LibraryParagraph(
        cleaned.text,
        italic: entry['italic'] == true,
        emphasis: cleaned.emphasis,
      );
    case 'card':
      return LibraryCard(
        heading: cleanLibraryText(entry['heading'] as String).text,
        asset: entry['asset'] as String?,
        icon: entry['icon'] as String?,
        text: entry['text'] == null
            ? null
            : cleanLibraryText(entry['text'] as String).text,
        bullets: _strings(entry['bullets']),
        checks: _strings(entry['checks']),
      );
    case 'cards':
      return LibraryCards(
        entry['layout'] == 'hscroll'
            ? LibraryCardsLayout.hscroll
            : LibraryCardsLayout.grid2,
        _items(entry['items']),
      );
    case 'rows':
      return LibraryRows(_items(entry['items']));
    case 'numbered':
      return LibraryNumbered(
        _items(entry['items']),
        circular: '${entry['note']}'.contains('circular'),
      );
    case 'checklist':
      return LibraryChecklist(_strings(entry['items']));
    case 'bullets':
      return LibraryBullets(_strings(entry['items']));
    case 'cta':
      final text = cleanLibraryText(entry['text'] as String).text;
      // The crystal pages already arrive assigned: no "select" action.
      if (text.startsWith('SELECT THIS CRYSTAL')) return null;
      return LibraryCta(text);
  }
  return null;
}

List<String> _strings(Object? value) => [
  for (final item in (value as List?) ?? const [])
    cleanLibraryText(item as String).text,
];

List<LibraryItem> _items(Object? value) => [
  for (final item in ((value as List?) ?? const []).cast<Map<String, dynamic>>())
    LibraryItem(
      label: cleanLibraryText(item['label'] as String).text,
      desc: cleanLibraryText((item['desc'] as String?) ?? '').text,
      icon: item['icon'] as String?,
      asset: item['asset'] as String?,
      bullets: _strings(item['bullets']),
    ),
];

/// Text without editorial marks, plus the phrases to highlight.
class CleanLibraryText {
  const CleanLibraryText(this.text, this.emphasis);

  final String text;
  final List<String> emphasis;
}

final RegExp _uncertainMark = RegExp(r'\s*\[UNCERTAIN\]');
final RegExp _emphasisNote = RegExp(
  r'\s*\(emphasis/italic gold:\s*(.*)\)\s*$',
  dotAll: true,
);

CleanLibraryText cleanLibraryText(String raw) {
  var text = raw;
  var emphasis = const <String>[];
  final note = _emphasisNote.firstMatch(text);
  if (note != null) {
    emphasis = [
      for (final match in RegExp(r'"([^"]+)"').allMatches(note.group(1)!))
        match.group(1)!,
    ];
    text = text.substring(0, note.start);
  }
  text = text.replaceAll(_uncertainMark, '');
  return CleanLibraryText(text, emphasis);
}
