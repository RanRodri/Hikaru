// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_crystal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedCrystal)
final selectedCrystalProvider = SelectedCrystalProvider._();

final class SelectedCrystalProvider
    extends $AsyncNotifierProvider<SelectedCrystal, Crystal?> {
  SelectedCrystalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCrystalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCrystalHash();

  @$internal
  @override
  SelectedCrystal create() => SelectedCrystal();
}

String _$selectedCrystalHash() => r'fa7f1f180871928c18561837f0d80a31d9283296';

abstract class _$SelectedCrystal extends $AsyncNotifier<Crystal?> {
  FutureOr<Crystal?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Crystal?>, Crystal?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Crystal?>, Crystal?>,
              AsyncValue<Crystal?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
