import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal_assignment.dart';
import '../data/quiz_answers_repository.dart';
import '../domain/discovery_quiz.dart';
import '../domain/quiz_answers.dart';

const List<Shadow> _textShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.7),
    offset: Offset(0, 2),
    blurRadius: 8,
  ),
];

class ListeningRoomQuizScreen extends ConsumerStatefulWidget {
  const ListeningRoomQuizScreen({super.key});

  @override
  ConsumerState<ListeningRoomQuizScreen> createState() =>
      _ListeningRoomQuizScreenState();
}

class _ListeningRoomQuizScreenState
    extends ConsumerState<ListeningRoomQuizScreen> {
  static const String _backgroundAsset =
      'assets/images/listening_room_quiz.png';
  static const double _contentTop = 60;
  static const double _footerBottom = 50;
  static const double _minInsetGap = 16;

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
    final saved = await ref.read(quizAnswersRepositoryProvider).read();
    if (!mounted) return;
    setState(() => _answers = saved);
  }

  Future<void> _save() =>
      ref.read(quizAnswersRepositoryProvider).save(_answers);

  void _handleSelect(String optionId) {
    final question = _question;
    final selected = _answers.selectedIds(question.number).toSet();
    if (question.selection == QuizSelection.multiple) {
      if (!selected.add(optionId)) selected.remove(optionId);
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
      await _save();
      if (!mounted) return;

      if (_index < discoveryQuiz.length - 1) {
        _showQuestion(_index + 1);
        return;
      }

      await ref
          .read(selectedCrystalProvider.notifier)
          .select(assignCrystal(_answers));
      if (!mounted) return;
      context.push(AppRoutes.ritualReady);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final topSpace = math.max(_contentTop, insets.top + _minInsetGap);
    final bottomSpace = math.max(_footerBottom, insets.bottom + _minInsetGap);
    final question = _question;
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
            const Image(
              image: AssetImage(_backgroundAsset),
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
              padding: EdgeInsets.fromLTRB(32, topSpace, 32, bottomSpace),
              child: Column(
                children: [
                  _Progress(
                    value: progress,
                    label:
                        'Question ${question.number} of ${discoveryQuiz.length}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progressLabel,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.white,
                      fontSize: 9,
                      letterSpacing: 0.9,
                      shadows: _textShadow,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 1.5,
                    color: AppColors.champagneGold,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'THE LISTENING ROOM',
                    textAlign: TextAlign.center,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.white,
                      shadows: _textShadow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A  SPACE  TO  BE  HEARD',
                    textAlign: TextAlign.center,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.white,
                      shadows: _textShadow,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    question.prompt,
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(
                      color: AppColors.white,
                      fontSize: 26,
                      height: 1.15,
                      shadows: _textShadow,
                    ),
                  ),
                  if (question.instruction != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      question.instruction!,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.fog,
                        fontSize: 12,
                        shadows: _textShadow,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      controller: _optionsController,
                      primary: false,
                      padding: EdgeInsets.zero,
                      itemCount: question.options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        return _QuizOptionTile(
                          title: option.label,
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
                  if (_showChoiceError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Select an option.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: 12,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: _busy ? null : _handleBack,
                    child: Text(
                      'BACK',
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.champagneGold,
                        fontSize: 11,
                        letterSpacing: 1.65,
                      ),
                    ),
                  ),
                  HikaruPillButton(label: 'NEXT', onPressed: _handleNext),
                  const SizedBox(height: 14),
                  Text(
                    'A  MORE  RADIANT  YOU  AWAITS',
                    textAlign: TextAlign.center,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1.2,
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
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 3,
          width: double.infinity,
          child: ColoredBox(
            color: AppColors.white.withValues(alpha: 0.15),
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  _ChoiceMark(selected: selected),
                  const SizedBox(width: 14),
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
                            fontSize: 12,
                            letterSpacing: 0.4,
                            shadows: _textShadow,
                          ),
                        ),
                        if (optionDetail != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            optionDetail,
                            style: AppTypography.body.copyWith(
                              color: AppColors.fog,
                              fontSize: 12,
                              letterSpacing: 0.2,
                              shadows: _textShadow,
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
        color: selected
            ? AppColors.champagneGold
            : AppColors.champagneGold.withValues(alpha: 0),
        border: Border.all(color: AppColors.champagneGold, width: 2),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.champagneGold.withValues(alpha: 0.9),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: selected
          ? const Icon(Icons.check, size: 18, color: AppColors.darkIndigoBlue)
          : null,
    );
  }
}
