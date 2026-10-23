import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/library_article.dart';
import '../domain/library_collection.dart';
import 'library_screen.dart';
import 'library_texts.dart';

final TextStyle _eyebrowStyle = AppTypography.subheadline.copyWith(
  color: AppColors.champagneGold,
  fontSize: AppFontSizes.s10,
  letterSpacing: 1.8,
);

final TextStyle _bodyStyle = AppTypography.body.copyWith(
  color: AppColors.fog,
  fontSize: AppFontSizes.s13,
  height: 1.55,
  letterSpacing: 0.2,
);

String _chapterNumber(int number) => number.toString().padLeft(2, '0');

class LibraryDetailScreen extends StatefulWidget {
  const LibraryDetailScreen({super.key, required this.article});

  final LibraryArticle article;

  @override
  State<LibraryDetailScreen> createState() => _LibraryDetailScreenState();
}

class _LibraryDetailScreenState extends State<LibraryDetailScreen> {
  static const Duration _scrollDuration = Duration(milliseconds: 450);
  static const Duration _switchDuration = Duration(milliseconds: 320);

  final GlobalKey _featuredKey = GlobalKey();

  /// Index of the chapter chosen in the filter. `null` means ALL.
  int? _selectedChapter;

  int get _featuredIndex => _selectedChapter ?? 0;

  @override
  void didUpdateWidget(covariant LibraryDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.id == widget.article.id) return;
    _selectedChapter = null;
  }

  void _handleBackPressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.library);
  }

  void _handleFilterSelected(int? index) {
    setState(() => _selectedChapter = index);
    _scrollToFeatured();
  }

  void _scrollToFeatured() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final featuredContext = _featuredKey.currentContext;
      if (featuredContext == null) return;
      Scrollable.ensureVisible(
        featuredContext,
        duration: _scrollDuration,
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  void _handleNextPressed(LibraryCollection next) {
    context.pushReplacement(AppRoutes.libraryTopicFor(next.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final article = localizedLibraryArticle(l10n, widget.article);
    final collection = libraryCollectionFor(article.id);
    final next = nextLibraryCollection(article.id);
    final crystal = Crystal.fromName(article.id);
    final chapters = article.blocks;
    final featuredIndex = _featuredIndex;
    final otherChapters = [
      for (final (index, block) in chapters.indexed)
        if (index != featuredIndex) (index, block),
    ];

    return HikaruScrollPage(
      active: HikaruDestination.library,
      backgroundAsset: libraryBackgroundAsset,
      dimBackground: true,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _BackButton(onPressed: _handleBackPressed),
        ),
        const SizedBox(height: AppSpacing.s8),
        if (collection != null) ...[
          Text(
            collection.localizedCategory(l10n),
            textAlign: TextAlign.center,
            style: _eyebrowStyle,
          ),
          const SizedBox(height: AppSpacing.s10),
        ],
        HikaruPageIntro(
          title: article.title,
          subtitle: collection?.localizedInlineDetail(l10n) ?? '',
        ),
        const SizedBox(height: AppSpacing.s14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            _MetaPill(label: l10n.libraryChapterCount(chapters.length)),
            _MetaPill(label: l10n.libraryReadingTime(article.readingMinutes)),
            if (crystal != null) _MetaPill(label: crystal.hertzLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.s20),
        if (chapters.length > 1) ...[
          _ChapterFilter(
            headings: [for (final block in chapters) block.heading],
            selected: _selectedChapter,
            onSelected: _handleFilterSelected,
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
        KeyedSubtree(
          key: _featuredKey,
          child: AnimatedSwitcher(
            duration: _switchDuration,
            child: _FeaturedChapter(
              key: ValueKey('${article.id}-$featuredIndex'),
              number: featuredIndex + 1,
              block: chapters[featuredIndex],
              subtitle: collection?.localizedInlineDetail(l10n) ?? article.title,
              imageAsset: collection?.imageAsset,
            ),
          ),
        ),
        if (otherChapters.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s12),
          _ChapterGrid(
            chapters: otherChapters,
            onSelected: _handleFilterSelected,
          ),
        ],
        if (next != null) ...[
          const SizedBox(height: AppSpacing.s12),
          _NextCard(
            collection: next,
            onPressed: () => _handleNextPressed(next),
          ),
        ],
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.libraryBackSemantics,
      excludeSemantics: true,
      child: Material(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.45),
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.6),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Text(
              l10n.commonBack,
              style: _eyebrowStyle.copyWith(fontSize: AppFontSizes.s11),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.45),
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
        child: Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s11,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _ChapterFilter extends StatelessWidget {
  const _ChapterFilter({
    required this.headings,
    required this.selected,
    required this.onSelected,
  });

  static const double _height = 34;

  final List<String> headings;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: _height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: l10n.libraryFilterAll,
            semanticsLabel: l10n.libraryFilterAllSemantics,
            selected: selected == null,
            onPressed: () => onSelected(null),
          ),
          for (final (index, heading) in headings.indexed) ...[
            const SizedBox(width: AppSpacing.s8),
            _FilterChip(
              label: heading.toUpperCase(),
              semanticsLabel: l10n.libraryFilterChapterSemantics(
                index + 1,
                heading,
              ),
              selected: selected == index,
              onPressed: () => onSelected(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.semanticsLabel,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(
              alpha: selected ? 1 : 0.55,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      AppColors.splashHighlight,
                      AppColors.champagneGold,
                    ],
                  )
                : null,
            color: selected
                ? null
                : AppColors.darkIndigoBlue.withValues(alpha: 0.5),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.subheadline.copyWith(
                    color: selected
                        ? AppColors.darkIndigoBlue
                        : AppColors.white,
                    fontSize: AppFontSizes.s10,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.r16);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkIndigoBlue.withValues(alpha: 0.72),
                AppColors.black.withValues(alpha: 0.55),
              ],
            ),
            borderRadius: radius,
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.45),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FeaturedChapter extends StatelessWidget {
  const _FeaturedChapter({
    super.key,
    required this.number,
    required this.block,
    required this.subtitle,
    required this.imageAsset,
  });

  final int number;
  final LibraryBlock block;
  final String subtitle;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final lines = block.body.split('\n');
    final image = imageAsset;

    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).libraryChapterLabel(_chapterNumber(number)),
                        style: _eyebrowStyle,
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Text(
                        block.heading,
                        style: AppTypography.title.copyWith(
                          color: AppColors.white,
                          fontSize: AppFontSizes.s26,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        subtitle,
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s13,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (image != null) ...[
                  const SizedBox(width: AppSpacing.s12),
                  _GlowingCover(asset: image),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s14),
            Container(
              height: AppSpacing.s0_6,
              color: AppColors.champagneGold.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.s14),
            if (lines.length == 1)
              Text(block.body, style: _bodyStyle)
            else
              for (final line in lines) _BulletLine(line),
          ],
        ),
      ),
    );
  }
}

class _GlowingCover extends StatelessWidget {
  const _GlowingCover({required this.asset});

  static const double _size = 92;

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.black,
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.55),
            blurRadius: 22,
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.champagneGold, width: 1.2),
      ),
      child: ClipOval(
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.s5,
            height: AppSpacing.s5,
            margin: const EdgeInsets.only(
              top: AppSpacing.s8,
              right: AppSpacing.s12,
            ),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.champagneGold,
            ),
          ),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }
}

class _ChapterGrid extends StatelessWidget {
  const _ChapterGrid({required this.chapters, required this.onSelected});

  final List<(int, LibraryBlock)> chapters;
  final ValueChanged<int> onSelected;

  Widget _tile((int, LibraryBlock) chapter) {
    final (index, block) = chapter;
    return _ChapterTile(
      number: index + 1,
      block: block,
      onPressed: () => onSelected(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < chapters.length; start += 2) {
      final hasPair = start + 1 < chapters.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s12),
          child: hasPair
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _tile(chapters[start])),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(child: _tile(chapters[start + 1])),
                    ],
                  ),
                )
              : _tile(chapters[start]),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.number,
    required this.block,
    required this.onPressed,
  });

  static const double _badgeSize = 34;

  final int number;
  final LibraryBlock block;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(
        context,
      ).libraryOpenChapterSemantics(number, block.heading),
      excludeSemantics: true,
      child: _GlassCard(
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: _badgeSize,
                    height: _badgeSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.champagneGold),
                    ),
                    child: Text(
                      _chapterNumber(number),
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.champagneGold,
                        fontSize: AppFontSizes.s11,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    block.heading.toUpperCase(),
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s11,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    block.body.split('\n').first,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _bodyStyle.copyWith(
                      fontSize: AppFontSizes.s11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.collection, required this.onPressed});

  static const double _thumbSize = 56;

  final LibraryCollection collection;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.libraryNextSemantics(collection.localizedSemanticsLabel(l10n)),
      excludeSemantics: true,
      child: _GlassCard(
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s14),
              child: Row(
                children: [
                  Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    foregroundDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.champagneGold),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        collection.imageAsset,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.libraryNextLabel,
                          style: _eyebrowStyle.copyWith(
                            fontSize: AppFontSizes.s9,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          collection.localizedName(l10n),
                          style: AppTypography.headline.copyWith(
                            color: AppColors.white,
                            fontSize: AppFontSizes.s15,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          collection.localizedInlineDetail(l10n),
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.fog,
                            fontSize: AppFontSizes.s11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.libraryRead,
                    style: _eyebrowStyle.copyWith(fontSize: AppFontSizes.s11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
