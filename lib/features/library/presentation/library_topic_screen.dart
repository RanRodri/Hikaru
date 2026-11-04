import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_header.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/library_topic_content.dart';
import 'library_screen.dart';
import 'library_topic_styles.dart';
import 'library_topic_widgets.dart';

/// Heading of the Merkaba card that opens the guided session.
const String libraryGuidedActivationHeading = 'GUIDED MERKABA ACTIVATION';

/// Image shown full screen by "EXPLORE THE MERIDIANS MAP".
const String libraryMeridiansMapFile = 'face_points_map.webp';

/// Tab of a multi-page topic: short label and a round thumbnail.
class LibraryTopicTab {
  const LibraryTopicTab({required this.label, required this.thumbnail});

  final String label;
  final String thumbnail;
}

/// One or more infographic topics as scrolling mobile pages.
///
/// With several [pages] (The Hikaru Ritual and its method chapters), the
/// reader swipes sideways between them or picks one from the tab strip; each
/// page keeps its own vertical scroll. Pages are built on slivers, so only
/// the sections near the viewport exist, and nothing calls `setState` on
/// scroll: the compact title, the hero drift and the section reveals each
/// listen to the scroll position on their own.
class LibraryTopicScreen extends StatefulWidget {
  LibraryTopicScreen({super.key, required LibraryTopicContent content})
    : pages = [content],
      tabs = const [],
      initialPage = 0;

  const LibraryTopicScreen.paged({
    super.key,
    required this.pages,
    required this.tabs,
    this.initialPage = 0,
  }) : assert(pages.length == tabs.length);

  final List<LibraryTopicContent> pages;
  final List<LibraryTopicTab> tabs;
  final int initialPage;

  @override
  State<LibraryTopicScreen> createState() => _LibraryTopicScreenState();
}

class _LibraryTopicScreenState extends State<LibraryTopicScreen> {
  /// Scroll distance over which the title moves up into the bar.
  static const double _collapseDistance = 140;
  static const Duration _pageDuration = Duration(milliseconds: 420);

  late final PageController _pageController = PageController(
    initialPage: widget.initialPage,
  );
  late final List<ScrollController> _scrollControllers = [
    for (final _ in widget.pages) ScrollController(),
  ];
  late final ValueNotifier<int> _page = ValueNotifier(widget.initialPage);
  final ValueNotifier<double> _collapse = ValueNotifier(0);

  bool get _paged => widget.pages.length > 1;

  @override
  void initState() {
    super.initState();
    for (final (index, controller) in _scrollControllers.indexed) {
      controller.addListener(() => _handleScroll(index));
    }
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    _page.dispose();
    _collapse.dispose();
    super.dispose();
  }

  void _handleScroll(int index) {
    if (index != _page.value) return;
    final controller = _scrollControllers[index];
    // ValueNotifier ignores equal values, so the bar only rebuilds while the
    // title is actually fading.
    _collapse.value = (controller.offset / _collapseDistance).clamp(0.0, 1.0);
  }

  void _handlePageChanged(int index) {
    _page.value = index;
    final controller = _scrollControllers[index];
    _collapse.value = controller.hasClients
        ? (controller.offset / _collapseDistance).clamp(0.0, 1.0)
        : 0;
  }

  void _goToPage(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(index);
      return;
    }
    _pageController.animateToPage(
      index,
      duration: _pageDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.library);
  }

  void _handleCta(LibraryTopicContent content, LibraryCta cta) {
    if (cta.text.startsWith('EXPLORE THE MERIDIANS MAP')) {
      _openMap(content);
    }
  }

  VoidCallback? _cardAction(LibraryCard card) {
    if (card.heading == libraryGuidedActivationHeading) {
      return () => context.push(AppRoutes.merkaba);
    }
    return null;
  }

  void _openMap(LibraryTopicContent content) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
        pageBuilder: (context, animation, secondary) => LibraryMapViewer(
          asset: content.source.imageAsset(libraryMeridiansMapFile),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return HikaruShell(
      active: HikaruDestination.library,
      backgroundAsset: libraryBackgroundAsset,
      builder: (context, scale) {
        final barTop = insets.top + HikaruHeader.height * scale;
        final tabsHeight = _paged ? _TopicTabs.height : 0.0;
        final contentTop =
            barTop + libraryTouchTarget + tabsHeight + AppSpacing.s8;

        Widget pageAt(int index) => _TopicPage(
          key: PageStorageKey('library-page-${widget.pages[index].id}'),
          content: widget.pages[index],
          controller: _scrollControllers[index],
          top: contentTop,
          bottom: HikaruNavigationBar.height + insets.bottom + AppSpacing.s40,
          onCta: (cta) => _handleCta(widget.pages[index], cta),
          cardAction: _cardAction,
          next: _paged && index + 1 < widget.pages.length
              ? widget.tabs[index + 1]
              : null,
          onNext: () => _goToPage(index + 1),
        );

        return Positioned.fill(
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: AppColors.darkIndigoBlue),
              ),
              Positioned.fill(
                child: _paged
                    ? PageView.builder(
                        controller: _pageController,
                        itemCount: widget.pages.length,
                        onPageChanged: _handlePageChanged,
                        itemBuilder: (context, index) => pageAt(index),
                      )
                    : pageAt(0),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: contentTop + AppSpacing.s16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.darkIndigoBlue,
                          AppColors.darkIndigoBlue.withValues(alpha: 0.94),
                          AppColors.darkIndigoBlue.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.78, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: barTop,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<int>(
                  valueListenable: _page,
                  builder: (context, page, _) => _CompactBar(
                    title: widget.pages[page].title,
                    collapse: _collapse,
                    onBack: _handleBack,
                  ),
                ),
              ),
              if (_paged)
                Positioned(
                  top: barTop + libraryTouchTarget,
                  left: 0,
                  right: 0,
                  child: _TopicTabs(
                    tabs: widget.tabs,
                    page: _page,
                    onSelected: _goToPage,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// One page: hero header, then its sections, then a link to the next page.
class _TopicPage extends StatelessWidget {
  const _TopicPage({
    super.key,
    required this.content,
    required this.controller,
    required this.top,
    required this.bottom,
    required this.onCta,
    required this.cardAction,
    required this.next,
    required this.onNext,
  });

  final LibraryTopicContent content;
  final ScrollController controller;
  final double top;
  final double bottom;
  final ValueChanged<LibraryCta> onCta;
  final VoidCallback? Function(LibraryCard card) cardAction;
  final LibraryTopicTab? next;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final sections = content.sections;
    final nextTab = next;

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: top),
          sliver: SliverToBoxAdapter(
            child: _Header(content: content, controller: controller),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s36,
            AppSpacing.s20,
            nextTab == null ? bottom : AppSpacing.s0,
          ),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              return SliverList.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? 0 : libraryGapBefore(sections[index - 1]),
                  ),
                  child: LibraryReveal(
                    child: LibrarySectionView(
                      section: sections[index],
                      source: content.source,
                      width: width,
                      onCta: onCta,
                      cardAction: cardAction,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (nextTab != null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s40,
              AppSpacing.s20,
              bottom,
            ),
            sliver: SliverToBoxAdapter(
              child: _NextPageLink(tab: nextTab, onPressed: onNext),
            ),
          ),
      ],
    );
  }
}

/// Back button on the left; the page title fades in beside it once the large
/// title has scrolled away.
class _CompactBar extends StatelessWidget {
  const _CompactBar({
    required this.title,
    required this.collapse,
    required this.onBack,
  });

  final String title;
  final ValueListenable<double> collapse;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: libraryTouchTarget,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: l10n.libraryBackSemantics,
              excludeSemantics: true,
              child: Material(
                color: AppColors.darkIndigoBlue.withValues(alpha: 0.6),
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.champagneGold80, width: 0.8),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onBack,
                  child: const SizedBox(
                    width: libraryTouchTarget,
                    height: libraryTouchTarget,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.champagneGold,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: collapse,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 6),
                    child: child,
                  ),
                ),
                child: ExcludeSemantics(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.champagneGold,
                      fontSize: AppFontSizes.s13,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal strip of page tabs: small round thumbnail and short label.
/// The current page is gold with a hairline underline; the strip keeps it in
/// view as the reader swipes.
class _TopicTabs extends StatefulWidget {
  const _TopicTabs({
    required this.tabs,
    required this.page,
    required this.onSelected,
  });

  static const double height = 52;

  final List<LibraryTopicTab> tabs;
  final ValueListenable<int> page;
  final ValueChanged<int> onSelected;

  @override
  State<_TopicTabs> createState() => _TopicTabsState();
}

class _TopicTabsState extends State<_TopicTabs> {
  late final List<GlobalKey> _keys = [
    for (final _ in widget.tabs) GlobalKey(),
  ];

  @override
  void initState() {
    super.initState();
    widget.page.addListener(_reveal);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(jump: true));
  }

  @override
  void dispose() {
    widget.page.removeListener(_reveal);
    super.dispose();
  }

  void _reveal({bool jump = false}) {
    final target = _keys[widget.page.value].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.5,
      duration: jump ? Duration.zero : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _TopicTabs.height,
      child: ValueListenableBuilder<int>(
        valueListenable: widget.page,
        builder: (context, current, _) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          child: Row(
            children: [
              for (final (index, tab) in widget.tabs.indexed)
                _TopicTabButton(
                  key: _keys[index],
                  tab: tab,
                  selected: index == current,
                  onPressed: () => widget.onSelected(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTabButton extends StatelessWidget {
  const _TopicTabButton({
    super.key,
    required this.tab,
    required this.selected,
    required this.onPressed,
  });

  static const double _thumb = 26;

  final LibraryTopicTab tab;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.champagneGold
        : AppColors.fog.withValues(alpha: 0.6);

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: libraryTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: _thumb,
                      height: _thumb,
                      foregroundDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.champagneGold
                              : AppColors.champagneGold.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: ClipOval(
                        child: Opacity(
                          opacity: selected ? 1 : 0.6,
                          child: Image.asset(
                            tab.thumbnail,
                            fit: BoxFit.cover,
                            cacheWidth: 96,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 240),
                      style: AppTypography.subheadline.copyWith(
                        color: color,
                        fontSize: AppFontSizes.s11,
                        letterSpacing: 1.6,
                      ),
                      child: Text(tab.label, maxLines: 1),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  height: 0.8,
                  width: selected ? 28 : 0,
                  color: AppColors.champagneGold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet link at the end of a page to the following one.
class _NextPageLink extends StatelessWidget {
  const _NextPageLink({required this.tab, required this.onPressed});

  final LibraryTopicTab tab;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.libraryNextSemantics(tab.label),
      excludeSemantics: true,
      child: LibraryPanel(
        padding: 0,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      tab.thumbnail,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      cacheWidth: 160,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.libraryNextLabel,
                          style: LibraryTopicStyles.cardKeyword,
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(tab.label, style: LibraryTopicStyles.sectionHeading),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.champagneGold,
                    size: 20,
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

/// Hero photo, then eyebrow, title and tagline. The photo drifts slightly
/// slower than the page, which gives the scroll a little depth.
class _Header extends StatelessWidget {
  const _Header({required this.content, required this.controller});

  final LibraryTopicContent content;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final hero = content.hero;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Column(
        children: [
          if (hero != null)
            LayoutBuilder(
              builder: (context, constraints) => AnimatedBuilder(
                animation: controller,
                child: Center(
                  child: _HeroFrame(
                    child: LibraryPhoto(
                      source: content.source,
                      file: hero.asset,
                      maxWidth: constraints.maxWidth,
                      maxHeight: 320,
                    ),
                  ),
                ),
                builder: (context, child) {
                  final offset =
                      controller.hasClients && controller.positions.length == 1
                      ? controller.offset.clamp(0.0, 400.0)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(0, offset * 0.18),
                    child: child,
                  );
                },
              ),
            ),
          SizedBox(height: hero == null ? 0 : AppSpacing.s32),
          if (content.eyebrow != null) ...[
            Text(
              content.eyebrow!,
              textAlign: TextAlign.center,
              style: LibraryTopicStyles.eyebrow,
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: LibraryTopicStyles.title,
          ),
          if (content.subtitle != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Text(
              content.subtitle!,
              textAlign: TextAlign.center,
              style: LibraryTopicStyles.subtitle,
            ),
          ],
          if (content.tagline != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Text(
              content.tagline!,
              textAlign: TextAlign.center,
              style: LibraryTopicStyles.tagline,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroFrame extends StatelessWidget {
  const _HeroFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.18),
            blurRadius: 28,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.5),
            width: 0.6,
          ),
        ),
        position: DecorationPosition.foreground,
        child: child,
      ),
    );
  }
}

/// Full-screen map with pinch zoom and pan.
class LibraryMapViewer extends StatelessWidget {
  const LibraryMapViewer({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Semantics(
                button: true,
                label: l10n.libraryBackSemantics,
                excludeSemantics: true,
                child: Material(
                  color: AppColors.darkIndigoBlue.withValues(alpha: 0.7),
                  shape: const CircleBorder(
                    side: BorderSide(
                      color: AppColors.champagneGold80,
                      width: 0.8,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: libraryTouchTarget,
                      height: libraryTouchTarget,
                      child: Icon(
                        Icons.close,
                        color: AppColors.champagneGold,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
