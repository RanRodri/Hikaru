// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_recommendation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(journeyRecommendationRepository)
final journeyRecommendationRepositoryProvider =
    JourneyRecommendationRepositoryProvider._();

final class JourneyRecommendationRepositoryProvider
    extends
        $FunctionalProvider<
          JourneyRecommendationRepository,
          JourneyRecommendationRepository,
          JourneyRecommendationRepository
        >
    with $Provider<JourneyRecommendationRepository> {
  JourneyRecommendationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'journeyRecommendationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$journeyRecommendationRepositoryHash();

  @$internal
  @override
  $ProviderElement<JourneyRecommendationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  JourneyRecommendationRepository create(Ref ref) {
    return journeyRecommendationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JourneyRecommendationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JourneyRecommendationRepository>(
        value,
      ),
    );
  }
}

String _$journeyRecommendationRepositoryHash() =>
    r'2755b3554fd98ceea570bb6b7a028ddf9b4dcfca';
