import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/journey_recommendation.dart';

part 'journey_recommendation_repository.g.dart';

class JourneyRecommendationRepository {
  JourneyRecommendationRepository(this._preferences);

  static const String storageKey = 'journey_recommendation';

  final SharedPreferencesAsync _preferences;

  Future<JourneyRecommendation?> read() async {
    final raw = await _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return JourneyRecommendation.fromJson(Map<String, dynamic>.from(decoded));
    } on FormatException {
      return null;
    }
  }

  Future<void> save(JourneyRecommendation recommendation) =>
      _preferences.setString(storageKey, jsonEncode(recommendation.toJson()));
}

@Riverpod(keepAlive: true)
JourneyRecommendationRepository journeyRecommendationRepository(Ref ref) =>
    JourneyRecommendationRepository(SharedPreferencesAsync());
