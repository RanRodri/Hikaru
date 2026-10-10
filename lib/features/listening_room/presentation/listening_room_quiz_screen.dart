import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';

const List<Shadow> _textShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.7),
    offset: Offset(0, 2),
    blurRadius: 8,
  ),
];

class ListeningRoomQuizScreen extends StatefulWidget {
  const ListeningRoomQuizScreen({super.key});

  @override
  State<ListeningRoomQuizScreen> createState() =>
      _ListeningRoomQuizScreenState();
}

class _ListeningRoomQuizScreenState extends State<ListeningRoomQuizScreen> {
  static const String _backgroundAsset =
      'assets/images/listening_room_quiz.png';
  static const List<({String title, String detail})> _options = [
    (title: 'Calm and balanced', detail: 'I feel centered and steady.'),
    (
      title: 'Good, but could be higher',
      detail: 'I have energy, but not at my best.',
    ),
    (title: 'Tired or low', detail: 'I feel drained or unmotivated.'),
    (title: 'Anxious or overwhelmed', detail: 'I feel stressed or restless.'),
  ];

  final Set<int> _selectedIndexes = {};
  bool _showChoiceError = false;

  void _handleSelect(int index) {
    setState(() {
      if (!_selectedIndexes.add(index)) {
        _selectedIndexes.remove(index);
      }
      _showChoiceError = false;
    });
  }

  void _handleNext() {
    if (_selectedIndexes.isEmpty) {
      setState(() => _showChoiceError = true);
      return;
    }
    context.push(AppRoutes.ritualReady);
  }

  static const double _contentTop = 60;
  static const double _footerBottom = 50;
  static const double _minInsetGap = 16;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final topSpace = math.max(_contentTop, insets.top + _minInsetGap);
    final bottomSpace = math.max(_footerBottom, insets.bottom + _minInsetGap);

    return Scaffold(
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
                _Progress(value: 0.1),
                const SizedBox(height: 8),
                Text(
                  '01 / 10',
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'How is your energy\nfeeling today?',
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(
                      color: AppColors.white,
                      fontSize: 38,
                      height: 1.05,
                      shadows: _textShadow,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tune into your body and choose\nwhat feels closest.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog,
                    fontSize: 12,
                    shadows: _textShadow,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      return _EnergyOption(
                        title: option.title,
                        detail: option.detail,
                        selected: _selectedIndexes.contains(index),
                        onPressed: () => _handleSelect(index),
                      );
                    },
                  ),
                ),
                if (_showChoiceError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Choose what feels closest.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.champagneGold,
                        fontSize: 12,
                        letterSpacing: 0,
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
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Question 1 of 10',
      value: '${(value * 10).round()} of 10',
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

class _EnergyOption extends StatelessWidget {
  const _EnergyOption({
    required this.title,
    required this.detail,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String detail;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: selected,
      label: '$title. $detail',
      child: Material(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0),
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(76, 8, 8, 8),
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
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          style: AppTypography.body.copyWith(
                            color: AppColors.fog,
                            fontSize: 12,
                            letterSpacing: 0.2,
                            shadows: _textShadow,
                          ),
                        ),
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
