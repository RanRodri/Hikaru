import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../l10n/app_localizations.dart';
import 'journey_cards.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  static const double _cardGap = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return HikaruScrollPage(
      active: HikaruDestination.journey,
      backgroundAsset: HikaruShell.sunsetGarden,
      children: [
        HikaruPageIntro(
          title: l10n.journeyTitle,
          subtitle: l10n.journeySubtitle,
          caption: l10n.journeyCaption,
        ),
        const SizedBox(height: AppSpacing.s18),
        const ActiveCrystalCard(),
        const SizedBox(height: _cardGap),
        const DailyStreakCard(),
        const SizedBox(height: _cardGap),
        const ProgressPhotosCard(),
        const SizedBox(height: _cardGap),
        const JourneyContinuesCard(),
      ],
    );
  }
}
