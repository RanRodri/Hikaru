import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/quiz_answers.dart';

part 'quiz_answers_repository.g.dart';

class QuizAnswersRepository {
  QuizAnswersRepository(this._preferences);

  static const String storageKey = 'discovery_quiz_answers';

  final SharedPreferencesAsync _preferences;

  Future<QuizAnswers> read() async {
    final raw = await _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return const QuizAnswers();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const QuizAnswers();
      return QuizAnswers.fromJson(Map<String, dynamic>.from(decoded));
    } on FormatException {
      return const QuizAnswers();
    }
  }

  Future<void> save(QuizAnswers answers) =>
      _preferences.setString(storageKey, jsonEncode(answers.toJson()));
}

@Riverpod(keepAlive: true)
QuizAnswersRepository quizAnswersRepository(Ref ref) =>
    QuizAnswersRepository(SharedPreferencesAsync());
