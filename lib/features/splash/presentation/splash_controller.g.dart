// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves the route to open once the splash screen finishes.
///
/// Will check the Amplify auth session when authentication is added.

@ProviderFor(splashDestination)
final splashDestinationProvider = SplashDestinationProvider._();

/// Resolves the route to open once the splash screen finishes.
///
/// Will check the Amplify auth session when authentication is added.

final class SplashDestinationProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Resolves the route to open once the splash screen finishes.
  ///
  /// Will check the Amplify auth session when authentication is added.
  SplashDestinationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashDestinationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashDestinationHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return splashDestination(ref);
  }
}

String _$splashDestinationHash() => r'84579be957afa67a58fbb0575240aae292781403';
