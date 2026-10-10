import 'package:flutter_test/flutter_test.dart';
import 'package:hiraku/features/crystals/domain/crystal.dart';
import 'package:hiraku/features/library/domain/library_article.dart';

void main() {
  test('library topics reuse source copy and omit empty sections', () {
    const ids = [
      libraryMerkabaId,
      'jade',
      'whiteQuartz',
      'redJasper',
      'obsidian',
      libraryRitualsId,
    ];

    for (final id in ids) {
      final article = libraryArticleFor(id);
      expect(article, isNotNull, reason: id);
      expect(article!.blocks, isNotEmpty);
      for (final block in article.blocks) {
        expect(block.heading.trim(), isNotEmpty);
        expect(block.body.trim(), isNotEmpty);
      }
    }

    expect(libraryArticleFor('amethyst'), isNull);

    final merkaba = libraryArticleFor(libraryMerkabaId)!;
    expect(
      merkaba.blocks.map((block) => block.body).join('\n'),
      contains('Inhale 4 seconds. Hold 4 seconds. Exhale 6 seconds.'),
    );
    expect(
      merkaba.blocks.map((block) => block.body).join('\n'),
      contains('Gyan Mudra'),
    );

    final jade = libraryArticleFor(Crystal.jade.name)!;
    expect(
      jade.blocks.map((block) => block.body),
      contains(Crystal.jade.purpose),
    );
    expect(jade.blocks.last.body, 'Harmony, Self-Love, Renewal');

    final rituals = libraryArticleFor(libraryRitualsId)!;
    expect(rituals.blocks.single.body, contains('Light, Moderate, Firm'));
    expect(rituals.blocks.single.body, contains('54 facial muscles'));
    expect(
      rituals.blocks.single.body,
      contains('528 Hz, Maestro Jorge Alfano'),
    );
  });
}
