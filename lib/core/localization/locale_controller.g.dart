// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the active app [Locale] and lets the user change it at runtime.
///
/// A `null` value means "follow the system locale"; [MaterialApp] then picks
/// the best match from `supportedLocales`. Selecting a language persists it
/// through [LocaleRepository] so the choice survives restarts.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Holds the active app [Locale] and lets the user change it at runtime.
///
/// A `null` value means "follow the system locale"; [MaterialApp] then picks
/// the best match from `supportedLocales`. Selecting a language persists it
/// through [LocaleRepository] so the choice survives restarts.
final class LocaleControllerProvider
    extends $AsyncNotifierProvider<LocaleController, Locale?> {
  /// Holds the active app [Locale] and lets the user change it at runtime.
  ///
  /// A `null` value means "follow the system locale"; [MaterialApp] then picks
  /// the best match from `supportedLocales`. Selecting a language persists it
  /// through [LocaleRepository] so the choice survives restarts.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();
}

String _$localeControllerHash() => r'a69fe4460e76c9eadc553080805ab4cec87ada41';

/// Holds the active app [Locale] and lets the user change it at runtime.
///
/// A `null` value means "follow the system locale"; [MaterialApp] then picks
/// the best match from `supportedLocales`. Selecting a language persists it
/// through [LocaleRepository] so the choice survives restarts.

abstract class _$LocaleController extends $AsyncNotifier<Locale?> {
  FutureOr<Locale?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale?>, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale?>, Locale?>,
              AsyncValue<Locale?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
