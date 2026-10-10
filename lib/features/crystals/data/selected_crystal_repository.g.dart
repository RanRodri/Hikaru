// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_crystal_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectedCrystalRepository)
final selectedCrystalRepositoryProvider = SelectedCrystalRepositoryProvider._();

final class SelectedCrystalRepositoryProvider
    extends
        $FunctionalProvider<
          SelectedCrystalRepository,
          SelectedCrystalRepository,
          SelectedCrystalRepository
        >
    with $Provider<SelectedCrystalRepository> {
  SelectedCrystalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCrystalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCrystalRepositoryHash();

  @$internal
  @override
  $ProviderElement<SelectedCrystalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelectedCrystalRepository create(Ref ref) {
    return selectedCrystalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedCrystalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedCrystalRepository>(value),
    );
  }
}

String _$selectedCrystalRepositoryHash() =>
    r'033da1c95a7cfc83179d7079e83f345de61acde4';
