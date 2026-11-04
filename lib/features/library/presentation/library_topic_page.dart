import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/library_article.dart';
import '../domain/library_collection.dart';
import '../domain/library_topic_content.dart';
import 'library_detail_screen.dart';
import 'library_topic_screen.dart';

final Map<String, Future<LibraryTopicContent>> _topicCache = {};

/// Loads and parses the topic's `content.json`, once per id.
Future<LibraryTopicContent> loadLibraryTopic(
  String id, {
  AssetBundle? bundle,
}) {
  final source = libraryTopicSources[id];
  if (source == null) {
    return Future.error(ArgumentError.value(id, 'id', 'No topic source'));
  }
  final assets = bundle ?? rootBundle;
  return _topicCache.putIfAbsent(
    id,
    () => assets
        .loadString(source.contentAsset)
        .then((json) => LibraryTopicContent.fromJson(id, source, json)),
  );
}

/// Chooses how a library id is drawn.
///
/// - The Hikaru Ritual and its four method topics (Gua Sha, Meridians,
///   Lymphatic, Fascia) open together as swipeable pages, starting at the
///   requested one.
/// - Jade uses a provisional infographic assembled from existing app copy.
/// - Topics with infographic copy use [LibraryTopicScreen]. Merkaba and the
///   crystals keep the translated chapter view in Spanish for now.
class LibraryTopicPage extends StatelessWidget {
  const LibraryTopicPage({super.key, required this.topicId});

  final String topicId;

  static bool usesInfographic(String id, Locale locale) {
    if (!libraryTopicSources.containsKey(id)) return false;
    if (libraryRitualPageIndex(id) >= 0) return true;
    return locale.languageCode != 'es';
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (!usesInfographic(topicId, locale)) {
      return LibraryDetailScreen(article: libraryArticleFor(topicId)!);
    }

    final ritualPage = libraryRitualPageIndex(topicId);
    if (ritualPage >= 0) return _RitualPages(initialPage: ritualPage);

    return FutureBuilder<LibraryTopicContent>(
      future: loadLibraryTopic(topicId),
      builder: (context, snapshot) {
        final content = snapshot.data;
        if (content != null) return LibraryTopicScreen(content: content);
        if (snapshot.hasError) {
          final article = libraryArticleFor(topicId);
          if (article != null) return LibraryDetailScreen(article: article);
        }
        return const Scaffold(backgroundColor: AppColors.darkIndigoBlue);
      },
    );
  }
}

class _RitualPages extends StatefulWidget {
  const _RitualPages({required this.initialPage});

  final int initialPage;

  @override
  State<_RitualPages> createState() => _RitualPagesState();
}

class _RitualPagesState extends State<_RitualPages> {
  late final Future<List<LibraryTopicContent>> _pages = Future.wait([
    for (final page in libraryRitualPages) loadLibraryTopic(page.id),
  ]);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LibraryTopicContent>>(
      future: _pages,
      builder: (context, snapshot) {
        final pages = snapshot.data;
        if (pages == null) {
          return const Scaffold(backgroundColor: AppColors.darkIndigoBlue);
        }
        return LibraryTopicScreen.paged(
          pages: pages,
          initialPage: widget.initialPage,
          tabs: [
            for (final page in libraryRitualPages)
              LibraryTopicTab(
                label: libraryRitualPageLabels[page.id]!,
                thumbnail: page.imageAsset,
              ),
          ],
        );
      },
    );
  }
}
