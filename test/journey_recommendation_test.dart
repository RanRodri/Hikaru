import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/listening_room/data/journey_recommendation_repository.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';
import 'package:hikaru/features/listening_room/domain/journey_recommendation.dart';
import 'package:hikaru/features/listening_room/domain/quiz_answers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

QuizAnswers _answers(Map<int, List<String>> selected) => QuizAnswers({
  for (final entry in selected.entries) entry.key: entry.value.toSet(),
});

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('builds protocol from skin, intention, and duration answers', () {
    final recommendation = buildJourneyRecommendation(
      Crystal.obsidian,
      _answers({
        1: [QuizOptionIds.q1HydrationSoftness],
        7: [QuizOptionIds.q7UnderstandBeneath],
        9: [QuizOptionIds.q9FiveMinutes],
      }),
    );

    expect(recommendation.crystal, Crystal.obsidian);
    expect(recommendation.crystalTitle, 'The Mirror of the Unseen');
    expect(recommendation.intention, 'Self-awareness and reflection');
    expect(recommendation.skinFocus, 'Hydration and gentle facial care');
    expect(recommendation.facialRitual, 'Hydration Protocol');
    expect(recommendation.durationMinutes, 5);
  });

  test('sensitive skin prefers soothing protocol', () {
    final recommendation = buildJourneyRecommendation(
      Crystal.jade,
      _answers({
        1: [QuizOptionIds.q1RadianceVitality],
        2: [QuizOptionIds.q2Sensitive],
        9: [QuizOptionIds.q9ThreeMinutes],
      }),
    );

    expect(recommendation.facialRitual, 'Soothing Comfort Protocol');
    expect(recommendation.durationMinutes, 3);
  });

  test('persists recommendation for profile reuse', () async {
    final repository = JourneyRecommendationRepository(SharedPreferencesAsync());
    final original = buildJourneyRecommendation(
      Crystal.whiteQuartz,
      _answers({
        1: [QuizOptionIds.q1RadianceVitality],
        7: [QuizOptionIds.q7GreaterClarity],
        9: [QuizOptionIds.q9TenMinutes],
      }),
    );

    await repository.save(original);
    final restored = await repository.read();

    expect(restored, isNotNull);
    expect(restored!.crystal, Crystal.whiteQuartz);
    expect(restored.facialRitual, 'Radiance Protocol');
    expect(restored.durationMinutes, 10);
    expect(restored.intention, 'Clarity and inner illumination');
  });
}
