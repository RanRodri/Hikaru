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
    expect(
      jade.blocks.map((block) => block.body).join('\n'),
      contains(
        '528 Hz. Heart coherence, love & balance. Jade Harmony Protocol. 20 min. Maestro Jorge Alfano.',
      ),
    );

    final quartz = libraryArticleFor(Crystal.whiteQuartz.name)!;
    expect(
      Crystal.whiteQuartz.frequency,
      'Cellular Coherence Frequency • 528 Hz',
    );
    expect(
      Crystal.whiteQuartz.protocol,
      'Quartz Illumination Protocol — Maestro Jorge Alfano',
    );
    expect(
      quartz.blocks.map((block) => block.body).join('\n'),
      contains(Crystal.whiteQuartz.frequency),
    );
    expect(
      quartz.blocks.map((block) => block.body).join('\n'),
      contains(Crystal.whiteQuartz.protocol),
    );

    final jasper = libraryArticleFor(Crystal.redJasper.name)!;
    expect(
      Crystal.redJasper.frequency,
      'Vitality & Vascular Flow Frequency • 639 Hz',
    );
    expect(
      Crystal.redJasper.protocol,
      'Jasper Vitality Protocol — Maestro Jorge Alfano',
    );
    expect(
      jasper.blocks.map((block) => block.body).join('\n'),
      contains(Crystal.redJasper.frequency),
    );
    expect(
      jasper.blocks.map((block) => block.body).join('\n'),
      contains(Crystal.redJasper.protocol),
    );
    expect(Crystal.jade.frequency, '528 Hz');
    expect(Crystal.obsidian.frequency, '528 Hz');
    expect(Crystal.jade.protocol, 'Jade Harmony Protocol');
    expect(Crystal.obsidian.protocol, 'Obsidian Transformation Protocol');

    final rituals = libraryArticleFor(libraryRitualsId)!;
    expect(rituals.blocks.single.body, contains('Light, Moderate, Firm'));
    expect(rituals.blocks.single.body, contains('54 facial muscles'));
    expect(
      rituals.blocks.single.body,
      contains('528 Hz, Maestro Jorge Alfano'),
    );
  });
}
