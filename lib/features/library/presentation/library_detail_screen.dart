import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_scroll_page.dart';
import '../domain/library_article.dart';

class LibraryDetailScreen extends StatelessWidget {
  const LibraryDetailScreen({super.key, required this.article});

  final LibraryArticle article;

  @override
  Widget build(BuildContext context) {
    final imageAsset = article.imageAsset;

    return HikaruScrollPage(
      active: HikaruDestination.library,
      dimBackground: true,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'BACK',
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold,
                fontSize: 12,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ),
        if (imageAsset != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Image.asset(
              imageAsset,
              height: 160,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 16),
        Text(
          article.title,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: 22,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        for (final block in article.blocks) ...[
          Text(
            block.heading,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            block.body,
            style: AppTypography.body.copyWith(
              color: AppColors.fog,
              fontSize: 14,
              height: 1.45,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
