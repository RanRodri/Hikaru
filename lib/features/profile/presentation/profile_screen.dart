import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import 'profile_cards.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const double _cardGap = AppSpacing.s10;

  @override
  Widget build(BuildContext context) {
    return const HikaruScrollPage(
      active: HikaruDestination.settings,
      backgroundAsset: HikaruShell.journalLandscape,
      children: [
        HikaruPageIntro(
          title: 'SANCTUARY PROFILE',
          subtitle:
              'Personal details, daily ritual reminders & progress privacy',
        ),
        SizedBox(height: AppSpacing.s18),
        MemberCard(),
        SizedBox(height: _cardGap),
        RitualRemindersCard(),
        SizedBox(height: _cardGap),
        DataPrivacyCard(),
        SizedBox(height: _cardGap),
        CycleCard(),
      ],
    );
  }
}
