import 'dart:ui' show Locale;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'locale_repository.dart';

part 'locale_controller.g.dart';

/// Holds the active app [Locale] and lets the user change it at runtime.
///
/// A `null` value means the user has not chosen a language, so the app uses
/// [defaultLocale] (English). Selecting a language persists it through
/// [LocaleRepository] so the choice survives restarts.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Future<Locale?> build() => ref.watch(localeRepositoryProvider).read();

  /// Switches the app language and remembers the choice.
  Future<void> setLocale(Locale locale) async {
    await ref.read(localeRepositoryProvider).save(locale);
    state = AsyncData(locale);
  }

  /// Clears the saved preference and goes back to [defaultLocale] (English).
  Future<void> resetToDefault() async {
    await ref.read(localeRepositoryProvider).clear();
    state = const AsyncData(null);
  }
}
