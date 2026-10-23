// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merkaba_progress_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(merkabaProgressRepository)
final merkabaProgressRepositoryProvider = MerkabaProgressRepositoryProvider._();

final class MerkabaProgressRepositoryProvider
    extends
        $FunctionalProvider<
          MerkabaProgressRepository,
          MerkabaProgressRepository,
          MerkabaProgressRepository
        >
    with $Provider<MerkabaProgressRepository> {
  MerkabaProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'merkabaProgressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$merkabaProgressRepositoryHash();

  @$internal
  @override
  $ProviderElement<MerkabaProgressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MerkabaProgressRepository create(Ref ref) {
    return merkabaProgressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MerkabaProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MerkabaProgressRepository>(value),
    );
  }
}

String _$merkabaProgressRepositoryHash() =>
    r'e4eff010585382d4807fdb289d6727ce2a5673b4';
