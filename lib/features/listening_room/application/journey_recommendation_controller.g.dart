// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_recommendation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JourneyRecommendationController)
final journeyRecommendationControllerProvider =
    JourneyRecommendationControllerProvider._();

final class JourneyRecommendationControllerProvider
    extends
        $AsyncNotifierProvider<
          JourneyRecommendationController,
          JourneyRecommendation?
        > {
  JourneyRecommendationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'journeyRecommendationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$journeyRecommendationControllerHash();

  @$internal
  @override
  JourneyRecommendationController create() => JourneyRecommendationController();
}

String _$journeyRecommendationControllerHash() =>
    r'd50889acafd4a3aa9170d05c3c6dc8d29e3c67c7';

abstract class _$JourneyRecommendationController
    extends $AsyncNotifier<JourneyRecommendation?> {
  FutureOr<JourneyRecommendation?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<JourneyRecommendation?>, JourneyRecommendation?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<JourneyRecommendation?>,
                JourneyRecommendation?
              >,
              AsyncValue<JourneyRecommendation?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
