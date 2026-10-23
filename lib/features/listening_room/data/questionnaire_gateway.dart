import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/amplify_graphql.dart';
import '../domain/discovery_quiz.dart';
import '../domain/quiz_answers.dart';

/// Stores the Listening Room answers as backend `QuestionnaireResponse` rows.
///
/// Each selected option becomes one row (`userId` + `questionOptionId`). The
/// option ids in the backend are the same ids the app uses, so a device can
/// rebuild the recommendation from these rows alone.
abstract class QuestionnaireGateway {
  /// Replaces every stored answer of the signed-in member.
  Future<void> replaceAnswers(QuizAnswers answers);

  /// Answers stored for the signed-in member, `null` without a session.
  Future<QuizAnswers?> fetchAnswers();
}

final questionnaireGatewayProvider = Provider<QuestionnaireGateway>(
  (ref) => AmplifyQuestionnaireGateway(),
);

class AmplifyQuestionnaireGateway implements QuestionnaireGateway {
  static const AmplifyGraphQL _api = AmplifyGraphQL('questionnaire');

  static const String _list =
      r'query ListResponses($userId: ID!, $nextToken: String) { '
      r'listQuestionnaireResponses('
      r'filter: {userId: {eq: $userId}}, limit: 500, nextToken: $nextToken'
      ') { items { id questionOptionId } nextToken } }';

  static const String _create =
      r'mutation CreateResponse($input: CreateQuestionnaireResponseInput!) { '
      r'createQuestionnaireResponse(input: $input) { id } }';

  static const String _delete =
      r'mutation DeleteResponse($input: DeleteQuestionnaireResponseInput!) { '
      r'deleteQuestionnaireResponse(input: $input) { id } }';

  @override
  Future<void> replaceAnswers(QuizAnswers answers) async {
    final userId = await _api.currentUserId();
    if (userId == null) return;

    for (final row in await _rows(userId)) {
      await _api.mutate(_delete, {
        'input': {'id': row['id']},
      });
    }
    for (final optionId in answers.selections.values.expand((ids) => ids)) {
      await _api.mutate(_create, {
        'input': {'userId': userId, 'questionOptionId': optionId},
      });
    }
  }

  @override
  Future<QuizAnswers?> fetchAnswers() async {
    final userId = await _api.currentUserId();
    if (userId == null) return null;
    final rows = await _rows(userId);
    return answersFromOptionIds(
      rows.map((row) => row['questionOptionId']).whereType<String>(),
    );
  }

  Future<List<Map<String, dynamic>>> _rows(String userId) => listAllPages(
    _api,
    _list,
    'listQuestionnaireResponses',
    {'userId': userId},
  );
}

/// Rebuilds [QuizAnswers] from option ids, using the quiz to find each
/// option's question. Unknown ids are ignored.
QuizAnswers answersFromOptionIds(Iterable<String> optionIds) {
  final questionByOption = <String, int>{
    for (final question in discoveryQuiz)
      for (final option in question.options) option.id: question.number,
  };
  final grouped = <int, Set<String>>{};
  for (final optionId in optionIds) {
    final question = questionByOption[optionId];
    if (question == null) continue;
    grouped.putIfAbsent(question, () => <String>{}).add(optionId);
  }
  var answers = const QuizAnswers();
  for (final entry in grouped.entries) {
    answers = answers.withSelection(entry.key, entry.value);
  }
  return answers;
}
