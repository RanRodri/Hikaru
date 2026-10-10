import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import 'journey_cards.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  static const double _cardGap = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    return const HikaruScrollPage(
      active: HikaruDestination.journey,
      dimBackground: true,
      children: [
        HikaruPageIntro(
          title: 'JOURNEY',
          subtitle: 'Your 30-day evolution',
          caption: 'Small daily rituals. Profound transformation.',
        ),
        SizedBox(height: AppSpacing.s18),
        ActiveCrystalCard(),
        SizedBox(height: _cardGap),
        DailyStreakCard(),
        SizedBox(height: _cardGap),
        ProgressPhotosCard(),
        SizedBox(height: _cardGap),
        JourneyContinuesCard(),
      ],
    );
  }
}
