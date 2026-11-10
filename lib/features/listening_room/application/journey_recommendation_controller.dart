import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../crystals/domain/crystal_assignment.dart';
import '../data/journey_recommendation_repository.dart';
import '../data/questionnaire_gateway.dart';
import '../data/quiz_answers_repository.dart';
import '../domain/journey_recommendation.dart';
import '../domain/quiz_answers.dart';

part 'journey_recommendation_controller.g.dart';

/// Crystal and protocol revealed after the Listening Room.
///
/// A local copy answers immediately for the account that is signed in. It is
/// deleted on sign-out and when another account signs in, so that account
/// cannot skip the questionnaire. When the device has none, this account's
/// backend answers rebuild it. Whether the reveal was already seen is
/// `User.isRevealedCrystal`, not this cache.
@Riverpod(keepAlive: true)
class JourneyRecommendationController
    extends _$JourneyRecommendationController {
  @override
  Future<JourneyRecommendation?> build() async {
    final local = await ref
        .watch(journeyRecommendationRepositoryProvider)
        .read();
    if (local != null) return local;

    final answers = await ref.read(questionnaireGatewayProvider).fetchAnswers();
    if (answers == null || answers.selections.isEmpty) return null;
    final rebuilt = buildJourneyRecommendation(assignCrystal(answers), answers);
    await ref.read(quizAnswersRepositoryProvider).save(answers);
    await ref.read(journeyRecommendationRepositoryProvider).save(rebuilt);
    return rebuilt;
  }

  /// Saves the revealed recommendation and syncs the answers behind it.
  Future<void> save(
    JourneyRecommendation recommendation, {
    QuizAnswers? answers,
  }) async {
    // Let a pending build land first so it cannot overwrite the save.
    await future;
    await ref
        .read(journeyRecommendationRepositoryProvider)
        .save(recommendation);
    state = AsyncData(recommendation);
    if (answers == null) return;
    await ref.read(questionnaireGatewayProvider).replaceAnswers(answers);
  }
}
