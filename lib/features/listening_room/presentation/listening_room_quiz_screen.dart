import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/media/remote_image.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal_assignment.dart';
import '../application/journey_recommendation_controller.dart';
import '../data/quiz_answers_repository.dart';
import '../domain/discovery_quiz.dart';
import '../domain/journey_recommendation.dart';
import '../domain/quiz_answers.dart';
import '../../../l10n/app_localizations.dart';
import 'quiz_texts.dart';

const List<Shadow> _textShadow = [
  Shadow(color: AppColors.scrim70, offset: Offset(0, 2), blurRadius: 8),
];

/// Wide-tracked white caps used for the two header lines.
final TextStyle _headerStyle = AppTypography.subheadline.copyWith(
  color: AppColors.white,
  shadows: _textShadow,
);

class ListeningRoomQuizScreen extends ConsumerStatefulWidget {
  const ListeningRoomQuizScreen({super.key});

  @override
  ConsumerState<ListeningRoomQuizScreen> createState() =>
      _ListeningRoomQuizScreenState();
}

class _ListeningRoomQuizScreenState
    extends ConsumerState<ListeningRoomQuizScreen> {
  static const String _backgroundAsset = RemoteImages.listeningRoomQuiz;

  /// Distance from the top to the progress bar in the design.
  static const double _contentTop = 16;
  static const double _topInsetGap = AppSpacing.s8;
  static const double _footerBottom = 28;
  static const double _minInsetGap = AppSpacing.s12;

  /// Below this screen height the title uses a smaller size.
  static const double _compactHeight = 700;
  static const double _optionsPanelWidth = 280;
  static const double _optionsPanelMaxHeight = 270;

  QuizAnswers _answers = const QuizAnswers();
  int _index = 0;
  bool _showChoiceError = false;
  bool _busy = false;
  final ScrollController _optionsController = ScrollController();

  DiscoveryQuestion get _question => discoveryQuiz[_index];

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _optionsController.dispose();
    super.dispose();
  }

  void _showQuestion(int index) {
    setState(() {
      _index = index;
      _showChoiceError = false;
    });
    if (_optionsController.hasClients) _optionsController.jumpTo(0);
  }

  Future<void> _restore() async {
    final repository = ref.read(quizAnswersRepositoryProvider);
    final saved = await repository.read();
    final step = await repository.readStep();
    if (!mounted) return;
    setState(() {
      _answers = saved;
      _index = step;
    });
  }

  Future<void> _save({required bool completed}) async {
    final repository = ref.read(quizAnswersRepositoryProvider);
    await repository.save(_answers);
    if (completed) {
      await repository.clearStep();
      return;
    }
    await repository.saveStep(_index);
  }

  void _handleSelect(String optionId) {
    final question = _question;
    final selected = _answers.selectedIds(question.number).toSet();
    final exclusiveId = question.exclusiveOptionId;

    if (question.selection == QuizSelection.multiple) {
      if (exclusiveId != null && optionId == exclusiveId) {
        if (selected.contains(exclusiveId) && selected.length == 1) {
          selected.clear();
        } else {
          selected
            ..clear()
            ..add(exclusiveId);
        }
      } else {
        if (exclusiveId != null) selected.remove(exclusiveId);
        if (!selected.add(optionId)) selected.remove(optionId);
      }
    } else {
      selected
        ..clear()
        ..add(optionId);
    }

    setState(() {
      _answers = _answers.withSelection(question.number, selected);
      _showChoiceError = false;
    });
  }

  Future<void> _handleBack() async {
    if (_busy) return;
    if (_index > 0) {
      _showQuestion(_index - 1);
      await _save(completed: false);
      return;
    }
    if (context.canPop()) context.pop();
  }

  Future<void> _handleNext() async {
    if (_busy) return;
    if (!_answers.hasSelection(_question.number)) {
      setState(() => _showChoiceError = true);
      return;
    }

    setState(() => _busy = true);
    try {
      final completed = _index >= discoveryQuiz.length - 1;
      if (!completed) _showQuestion(_index + 1);
      await _save(completed: completed);
      if (!mounted) return;

      if (!completed) return;

      final crystal = assignCrystal(_answers);
      await ref.read(selectedCrystalProvider.notifier).select(crystal);
      await ref
          .read(journeyRecommendationControllerProvider.notifier)
          .save(
            buildJourneyRecommendation(crystal, _answers),
            answers: _answers,
          );
      if (!mounted) return;
      context.push(AppRoutes.ritualReady);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final topSpace = math.max(_contentTop, insets.top + _topInsetGap);
    final bottomSpace = math.max(_footerBottom, insets.bottom + _minInsetGap);
    final screenSize = MediaQuery.sizeOf(context);
    final compact = screenSize.height < _compactHeight;
    final question = _question;
    final instruction = l10n.quizInstruction(question);
    final progress = question.number / discoveryQuiz.length;
    final progressLabel =
        '${question.number.toString().padLeft(2, '0')} / ${discoveryQuiz.length}';

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.darkIndigoBlue,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const RemoteImage(
              fileName: _backgroundAsset,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkIndigoBlue.withValues(alpha: 0.45),
                    AppColors.darkIndigoBlue.withValues(alpha: 0.3),
                    AppColors.darkIndigoBlue.withValues(alpha: 0.12),
                    AppColors.darkIndigoBlue.withValues(alpha: 0),
                    AppColors.darkIndigoBlue.withValues(alpha: 0.1),
                    AppColors.darkIndigoBlue.withValues(alpha: 0.4),
                    AppColors.darkIndigoBlue.withValues(alpha: 0.65),
                  ],
                  stops: const [0, 0.2, 0.4, 0.55, 0.7, 0.85, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s32,
                topSpace,
                AppSpacing.s32,
                bottomSpace,
              ),
              child: Column(
                children: [
                  _Progress(
                    value: progress,
                    label: l10n.quizProgressSemantics(
                      question.number,
                      discoveryQuiz.length,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    progressLabel,
                    style: AppTypography.body.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s9,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.9,
                      height: 1.2,
                      shadows: _textShadow,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  Container(
                    width: 40,
                    height: 1.5,
                    color: AppColors.champagneGold,
                  ),
                  const SizedBox(height: AppSpacing.s14),
                  Text(
                    l10n.quizHeader,
                    textAlign: TextAlign.center,
                    style: _headerStyle,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    l10n.quizTagline,
                    textAlign: TextAlign.center,
                    style: _headerStyle,
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  Text(
                    l10n.quizPrompt(question),
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(
                      color: AppColors.white,
                      fontSize: compact ? AppFontSizes.s22 : AppFontSizes.s30,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      shadows: _textShadow,
                    ),
                  ),
                  if (instruction != null) ...[
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      instruction,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.fog,
                        fontSize: AppFontSizes.s12,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                        letterSpacing: 0.5,
                        shadows: _textShadow,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _optionsPanelWidth,
                          maxHeight: _optionsPanelMaxHeight,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.scrim60,
                            borderRadius: BorderRadius.circular(AppRadii.r16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.r16),
                            child: ListView.separated(
                              controller: _optionsController,
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s12,
                                vertical: AppSpacing.s8,
                              ),
                              itemCount: question.options.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final option = question.options[index];
                                return _QuizOptionTile(
                                  title: l10n.quizOptionLabel(option),
                                  detail: option.detail,
                                  selected: _answers.isSelected(
                                    question.number,
                                    option.id,
                                  ),
                                  onPressed: () => _handleSelect(option.id),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showChoiceError)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s8),
                      child: Text(
                        l10n.quizSelectOption,
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s12,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: _busy ? null : _handleBack,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.champagneGold.withValues(
                        alpha: 0.6,
                      ),
                      minimumSize: const Size(44, 36),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s10,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.commonBack,
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.champagneGold.withValues(alpha: 0.6),
                        fontSize: AppFontSizes.s11,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  HikaruPillButton(
                    label: l10n.commonNext,
                    busy: _busy,
                    onPressed: _handleNext,
                  ),
                  const SizedBox(height: AppSpacing.s14),
                  Text(
                    l10n.radiantFooter,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s8,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                      height: 1.2,
                      shadows: _textShadow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: label,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.r2),
        child: SizedBox(
          height: AppSpacing.s3,
          width: double.infinity,
          child: ColoredBox(
            color: AppColors.white,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: const ColoredBox(color: AppColors.champagneGold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.title,
    required this.detail,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String? detail;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final optionDetail = detail;

    return Semantics(
      button: true,
      checked: selected,
      label: optionDetail == null ? title : '$title. $optionDetail',
      child: Material(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
            child: Row(
              children: [
                _ChoiceMark(selected: selected),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.subheadline.copyWith(
                          color: selected
                              ? AppColors.champagneGold
                              : AppColors.white,
                          fontSize: AppFontSizes.s12,
                          letterSpacing: 0,
                          height: 1.2,
                        ),
                      ),
                      if (optionDetail != null) ...[
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          optionDetail,
                          style: AppTypography.body.copyWith(
                            color: AppColors.fog,
                            fontWeight: FontWeight.w400,
                            fontSize: AppFontSizes.s12,
                            height: 1.3,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceMark extends StatelessWidget {
  const _ChoiceMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.champagneGold, width: 1.5),
      ),
      child: selected
          ? Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold,
              ),
            )
          : null,
    );
  }
}
