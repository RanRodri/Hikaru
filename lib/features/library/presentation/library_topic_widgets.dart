import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/library_image_sizes.dart';
import '../domain/library_topic_content.dart';
import 'library_icons.dart';
import 'library_topic_styles.dart';

/// Smallest touch target, in logical pixels.
const double libraryTouchTarget = 44;

/// Gap between a section and the one before it. A heading sits close to what
/// it introduces; everything else gets generous white space.
double libraryGapBefore(LibrarySection? previous) =>
    previous is LibraryHeading ? AppSpacing.s14 : AppSpacing.s36;

// ---------------------------------------------------------------------------
// Reveal on scroll
// ---------------------------------------------------------------------------

/// Fades its child in, with a slight upward drift, the first time it comes
/// near the visible area. Only sections that have not appeared yet listen to
/// the scroll position, and nothing rebuilds the page.
class LibraryReveal extends StatefulWidget {
  const LibraryReveal({super.key, required this.child});

  final Widget child;

  @override
  State<LibraryReveal> createState() => _LibraryRevealState();
}

class _LibraryRevealState extends State<LibraryReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  ScrollPosition? _position;
  bool _revealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealed) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reveal(animate: false);
      return;
    }
    final next = Scrollable.maybeOf(context)?.position;
    if (next == _position) return;
    _position?.removeListener(_check);
    _position = next?..addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_revealed || !mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final screen = MediaQuery.sizeOf(context).height;
    if (top < screen * 0.94) _reveal();
  }

  void _reveal({bool animate = true}) {
    _revealed = true;
    _position?.removeListener(_check);
    _position = null;
    if (animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _curve.value) * 16),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Images
// ---------------------------------------------------------------------------

/// A topic photo drawn no larger than its native pixels.
///
/// The box is the largest size that fits [maxWidth] x [maxHeight] while
/// keeping the photo's proportions, and never exceeds its native size, so
/// small crops stay sharp. `cacheWidth` makes Flutter decode only what it
/// paints.
class LibraryPhoto extends StatelessWidget {
  const LibraryPhoto({
    super.key,
    required this.source,
    required this.file,
    required this.maxWidth,
    required this.maxHeight,
    this.fit = BoxFit.cover,
    this.radius = AppRadii.r12,
    this.circle = false,
  });

  final LibraryTopicSource source;
  final String file;
  final double maxWidth;
  final double maxHeight;
  final BoxFit fit;
  final double radius;

  /// Crop to a circle: a square no bigger than the photo's shorter side.
  final bool circle;

  /// Size the photo will be drawn at.
  static Size fitted(
    LibraryTopicSource source,
    String file,
    double maxWidth,
    double maxHeight,
  ) {
    final native = libraryImageSizes[source.sizeKey(file)];
    if (native == null) return Size(maxWidth, maxHeight);
    final (width, height) = native;
    final scale = math.min(
      1.0,
      math.min(maxWidth / width, maxHeight / height),
    );
    return Size(width * scale, height * scale);
  }

  @override
  Widget build(BuildContext context) {
    final native = libraryImageSizes[source.sizeKey(file)];
    var size = fitted(source, file, maxWidth, maxHeight);
    if (circle) {
      final side = native == null
          ? math.min(maxWidth, maxHeight)
          : math.min(
              math.min(maxWidth, maxHeight),
              math.min(native.$1, native.$2).toDouble(),
            );
      size = Size.square(side);
    }
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // Decode at the painted size, never above the file's own width. Circles
    // crop from the middle, so give them the longer side's worth of pixels.
    final wanted = (size.width * pixelRatio * (circle ? 1.3 : 1)).ceil();
    final cacheWidth = math.min(wanted, native?.$1 ?? wanted);

    final image = SizedBox(
      width: size.width,
      height: size.height,
      child: Image.asset(
        source.imageAsset(file),
        cacheWidth: cacheWidth,
        fit: fit,
        excludeFromSemantics: true,
      ),
    );
    if (circle) return ClipOval(child: image);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

/// Bordered card: hairline gold border, soft corners, no shadow.
class LibraryPanel extends StatelessWidget {
  const LibraryPanel({
    super.key,
    required this.child,
    this.padding = AppSpacing.s16,
  });

  /// Border width plus inner padding, subtracted from the width children get.
  static double inset(double padding) => padding * 2 + 1;

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB316182C),
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.45),
          width: 0.6,
        ),
      ),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}

/// Gold ring with a thin line icon inside.
class LibraryIconBadge extends StatelessWidget {
  const LibraryIconBadge({super.key, required this.icon, this.size = 40});

  final String? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.8),
          width: 0.8,
        ),
      ),
      child: ExcludeSemantics(
        child: Icon(
          libraryIconFor(icon),
          color: AppColors.champagneGold,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class LibraryDotLine extends StatelessWidget {
  const LibraryDotLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(top: 10.5, right: AppSpacing.s12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.champagneGold,
            ),
          ),
          Expanded(child: Text(text, style: LibraryTopicStyles.body)),
        ],
      ),
    );
  }
}

class LibraryCheckLine extends StatelessWidget {
  const LibraryCheckLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: AppSpacing.s12),
            child: ExcludeSemantics(
              child: Icon(
                Icons.check,
                color: AppColors.champagneGold,
                size: 16,
              ),
            ),
          ),
          Expanded(child: Text(text, style: LibraryTopicStyles.body)),
        ],
      ),
    );
  }
}

/// Paragraph that folds to a few lines with a "Read more" toggle when it
/// would run long. The full text stays in the tree either way.
class LibraryExpandableText extends StatefulWidget {
  const LibraryExpandableText({
    super.key,
    required this.text,
    required this.style,
    this.emphasis = const [],
    this.collapsedLines = 4,
  });

  final String text;
  final TextStyle style;
  final List<String> emphasis;
  final int collapsedLines;

  @override
  State<LibraryExpandableText> createState() => _LibraryExpandableTextState();
}

class _LibraryExpandableTextState extends State<LibraryExpandableText> {
  bool _expanded = false;

  TextSpan _span() {
    final style = widget.style;
    if (widget.emphasis.isEmpty) return TextSpan(text: widget.text, style: style);

    final spans = <TextSpan>[];
    var cursor = 0;
    final text = widget.text;
    while (cursor < text.length) {
      var next = -1;
      String? match;
      for (final phrase in widget.emphasis) {
        final index = text.indexOf(phrase, cursor);
        if (index != -1 && (next == -1 || index < next)) {
          next = index;
          match = phrase;
        }
      }
      if (next == -1 || match == null) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }
      if (next > cursor) spans.add(TextSpan(text: text.substring(cursor, next)));
      spans.add(
        TextSpan(
          text: match,
          style: const TextStyle(
            color: AppColors.champagneGold,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
      cursor = next + match.length;
    }
    return TextSpan(style: style, children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final span = _span();

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: span,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: widget.collapsedLines,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Text.rich(
                span,
                maxLines: overflows && !_expanded ? widget.collapsedLines : null,
                overflow: TextOverflow.fade,
              ),
            ),
            if (overflows)
              Semantics(
                button: true,
                expanded: _expanded,
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: libraryTouchTarget,
                      minWidth: libraryTouchTarget,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _expanded ? l10n.libraryReadLess : l10n.libraryReadMore,
                        style: LibraryTopicStyles.link,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

/// Draws one [LibrarySection]. [width] is the width available to it.
class LibrarySectionView extends StatelessWidget {
  const LibrarySectionView({
    super.key,
    required this.section,
    required this.source,
    required this.width,
    this.onCta,
    this.cardAction,
  });

  final LibrarySection section;
  final LibraryTopicSource source;
  final double width;
  final ValueChanged<LibraryCta>? onCta;

  /// Returns what a tapped card does, or null when the card is static.
  final VoidCallback? Function(LibraryCard card)? cardAction;

  @override
  Widget build(BuildContext context) {
    final s = section;
    return switch (s) {
      LibraryHeading() => _HeadingView(section: s),
      LibraryParagraph() => LibraryExpandableText(
        text: s.text,
        emphasis: s.emphasis,
        style: LibraryTopicStyles.body.copyWith(
          fontStyle: s.italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      LibraryImage() => Center(
        child: LibraryPhoto(
          source: source,
          file: s.asset,
          maxWidth: width,
          maxHeight: s.small ? 240 : 320,
        ),
      ),
      LibraryCard() => _CardView(
        section: s,
        source: source,
        width: width,
        action: cardAction?.call(s),
      ),
      LibraryCards() => _CardsView(section: s, source: source, width: width),
      LibraryRows() => _RowsView(section: s, source: source, width: width),
      LibraryNumbered() =>
        s.circular
            ? _BreathRing(items: s.items)
            : _NumberedView(section: s),
      LibraryChecklist() => LibraryPanel(
        child: Column(
          children: [for (final item in s.items) LibraryCheckLine(item)],
        ),
      ),
      LibraryBullets() => Column(
        children: [for (final item in s.items) LibraryDotLine(item)],
      ),
      LibraryCta() => _CtaView(section: s, onPressed: () => onCta?.call(s)),
    };
  }
}

class _HeadingView extends StatelessWidget {
  const _HeadingView({required this.section});

  final LibraryHeading section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.text,
          style: LibraryTopicStyles.sectionHeading,
        ),
        const SizedBox(height: AppSpacing.s10),
        Container(
          width: AppSpacing.s40,
          height: 0.8,
          color: AppColors.champagneGold.withValues(alpha: 0.7),
        ),
        if (section.sub != null) ...[
          const SizedBox(height: AppSpacing.s10),
          Text(section.sub!, style: LibraryTopicStyles.subtitle),
        ],
      ],
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({
    required this.section,
    required this.source,
    required this.width,
    required this.action,
  });

  /// Photos at or under this width sit beside the heading; larger ones go
  /// under it.
  static const double _sideLimit = 140;
  static const double _sideBox = 72;

  final LibraryCard section;
  final LibraryTopicSource source;
  final double width;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final asset = section.asset;
    final native = asset == null
        ? null
        : libraryImageSizes[source.sizeKey(asset)];
    final isSide = native != null && native.$1 <= _sideLimit;
    final inner = width - LibraryPanel.inset(AppSpacing.s20);

    // "5 MIN VIDEO\nBreath, ..." style text: first line is a short label.
    final textLines = section.text?.split('\n');
    final hasKeyword = textLines != null && textLines.length > 1;

    final card = LibraryPanel(
      padding: AppSpacing.s20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.icon != null) ...[
                LibraryIconBadge(icon: section.icon),
                const SizedBox(width: AppSpacing.s14),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Text(
                    section.heading,
                    style: LibraryTopicStyles.sectionHeading,
                  ),
                ),
              ),
              if (asset != null && isSide) ...[
                const SizedBox(width: AppSpacing.s14),
                LibraryPhoto(
                  source: source,
                  file: asset,
                  maxWidth: _sideBox,
                  maxHeight: _sideBox,
                  fit: BoxFit.contain,
                  radius: AppRadii.r8,
                ),
              ],
              if (action != null) ...[
                const SizedBox(width: AppSpacing.s8),
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.s4),
                  child: ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.champagneGold,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (asset != null && !isSide) ...[
            const SizedBox(height: AppSpacing.s16),
            Center(
              child: LibraryPhoto(
                source: source,
                file: asset,
                maxWidth: inner,
                maxHeight: 240,
              ),
            ),
          ],
          if (textLines != null) ...[
            const SizedBox(height: AppSpacing.s14),
            if (hasKeyword) ...[
              Text(textLines.first, style: LibraryTopicStyles.cardKeyword),
              const SizedBox(height: AppSpacing.s6),
              LibraryExpandableText(
                text: textLines.skip(1).join('\n'),
                style: LibraryTopicStyles.body,
              ),
            ] else
              LibraryExpandableText(
                text: section.text!,
                style: LibraryTopicStyles.body,
              ),
          ],
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s14),
            for (final bullet in section.bullets) LibraryDotLine(bullet),
          ],
          if (section.checks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s14),
            for (final check in section.checks) LibraryCheckLine(check),
          ],
        ],
      ),
    );

    if (action == null) return card;
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: action, child: card),
      ),
    );
  }
}

class _CardsView extends StatelessWidget {
  const _CardsView({
    required this.section,
    required this.source,
    required this.width,
  });

  static const double _gap = AppSpacing.s12;
  static const double _scrollItemWidth = 148;

  final LibraryCards section;
  final LibraryTopicSource source;
  final double width;

  @override
  Widget build(BuildContext context) {
    final items = section.items;

    if (section.layout == LibraryCardsLayout.hscroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, item) in items.indexed) ...[
                if (index > 0) const SizedBox(width: _gap),
                SizedBox(
                  width: _scrollItemWidth,
                  child: _ItemCard(
                    item: item,
                    source: source,
                    width: _scrollItemWidth,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Two columns. A leftover last card is centered, not left with a gap.
    final itemWidth = (width - _gap) / 2;
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final pair = i + 1 < items.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : _gap),
          child: pair
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _ItemCard(
                          item: items[i],
                          source: source,
                          width: itemWidth,
                        ),
                      ),
                      const SizedBox(width: _gap),
                      SizedBox(
                        width: itemWidth,
                        child: _ItemCard(
                          item: items[i + 1],
                          source: source,
                          width: itemWidth,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: SizedBox(
                    width: itemWidth,
                    child: _ItemCard(
                      item: items[i],
                      source: source,
                      width: itemWidth,
                    ),
                  ),
                ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.source,
    required this.width,
  });

  final LibraryItem item;
  final LibraryTopicSource source;
  final double width;

  @override
  Widget build(BuildContext context) {
    final asset = item.asset;
    final inner = width - LibraryPanel.inset(AppSpacing.s14);
    final lines = item.desc.split('\n');
    final hasKeyword = lines.length > 1;

    return LibraryPanel(
      padding: AppSpacing.s14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (asset != null)
            Center(child: _ItemPhoto(source: source, file: asset, width: inner))
          else
            LibraryIconBadge(icon: item.icon),
          const SizedBox(height: AppSpacing.s12),
          Text(item.label, style: LibraryTopicStyles.cardLabel),
          if (item.desc.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s6),
            if (hasKeyword) ...[
              Text(lines.first, style: LibraryTopicStyles.cardKeyword),
              const SizedBox(height: AppSpacing.s4),
              Text(
                lines.skip(1).join('\n'),
                style: LibraryTopicStyles.cardDesc,
              ),
            ] else
              Text(item.desc, style: LibraryTopicStyles.cardDesc),
          ],
          for (final bullet in item.bullets) ...[
            const SizedBox(height: AppSpacing.s4),
            Text('· $bullet', style: LibraryTopicStyles.cardDesc),
          ],
        ],
      ),
    );
  }
}

/// Roughly square crops (hands, stones) are shown as circles; wide strips
/// keep their shape.
class _ItemPhoto extends StatelessWidget {
  const _ItemPhoto({
    required this.source,
    required this.file,
    required this.width,
  });

  final LibraryTopicSource source;
  final String file;
  final double width;

  @override
  Widget build(BuildContext context) {
    final native = libraryImageSizes[source.sizeKey(file)];
    final ratio = native == null ? 1.0 : native.$1 / native.$2;
    final round = ratio > 0.8 && ratio < 1.25;
    return LibraryPhoto(
      source: source,
      file: file,
      maxWidth: round ? math.min(width, 84) : width,
      maxHeight: round ? 84 : 110,
      radius: AppRadii.r8,
      circle: round,
    );
  }
}

class _RowsView extends StatelessWidget {
  const _RowsView({
    required this.section,
    required this.source,
    required this.width,
  });

  static const double _thumb = 90;

  final LibraryRows section;
  final LibraryTopicSource source;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, item) in section.items.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.s12),
          LibraryPanel(
            padding: AppSpacing.s14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: item.asset != null ? _thumb : 48,
                  child: Center(
                    child: item.asset != null
                        ? LibraryPhoto(
                            source: source,
                            file: item.asset!,
                            maxWidth: _thumb,
                            maxHeight: _thumb,
                            radius: AppRadii.r8,
                          )
                        : LibraryIconBadge(icon: item.icon, size: 44),
                  ),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: LibraryTopicStyles.cardLabel),
                      if (item.desc.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(item.desc, style: LibraryTopicStyles.cardDesc),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _NumberedView extends StatelessWidget {
  const _NumberedView({required this.section});

  final LibraryNumbered section;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, item) in section.items.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.s16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.champagneGold,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: LibraryTopicStyles.cardLabel.copyWith(
                    letterSpacing: 0,
                    fontSize: AppFontSizes.s13,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: LibraryTopicStyles.body.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      if (item.desc.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s2),
                        Text(item.desc, style: LibraryTopicStyles.cardDesc),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The breath steps (inhale, hold, exhale) as numbered gold rings joined by a
/// thin line, read top to bottom. Wraps cleanly at any text size.
class _BreathRing extends StatelessWidget {
  const _BreathRing({required this.items});

  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    return LibraryPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, item) in items.indexed)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.champagneGold,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.headline.copyWith(
                        color: AppColors.champagneGold,
                        fontSize: AppFontSizes.s20,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: LibraryTopicStyles.cardLabel,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    item.desc,
                    textAlign: TextAlign.center,
                    style: LibraryTopicStyles.cardKeyword,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CtaView extends StatelessWidget {
  const _CtaView({required this.section, required this.onPressed});

  final LibraryCta section;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: section.text,
      excludeSemantics: true,
      child: Material(
        color: AppColors.transparent,
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.champagneGold, width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.s52),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s12,
              ),
              child: Center(
                child: Text(
                  section.text,
                  textAlign: TextAlign.center,
                  style: AppTypography.pillLabel.copyWith(
                    color: AppColors.champagneGold,
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
