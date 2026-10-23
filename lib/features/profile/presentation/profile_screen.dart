import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../l10n/app_localizations.dart';
import 'profile_cards.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const double _cardGap = AppSpacing.s14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return HikaruScrollPage(
      active: HikaruDestination.settings,
      backgroundAsset: HikaruShell.sunsetGarden,
      children: [
        HikaruPageIntro(
          title: l10n.profileTitle,
          subtitle: l10n.profileSubtitle,
        ),
        const SizedBox(height: AppSpacing.s18),
        const MemberCard(),
        const SizedBox(height: _cardGap),
        const RitualRemindersCard(),
        const SizedBox(height: _cardGap),
        const DataPrivacyCard(),
        const SizedBox(height: _cardGap),
        const LanguageCard(),
        const SizedBox(height: _cardGap),
        const CycleCard(),
      ],
    );
  }
}
