import 'dart:ui' show Locale;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supported_locales.dart';

part 'locale_repository.g.dart';

/// Persists the user's chosen app language.
///
/// Stores the language code (for example `en` or `es`). A missing value means
/// the user has not chosen yet, so the app uses the default locale (English).
class LocaleRepository {
  LocaleRepository(this._preferences);

  static const String storageKey = 'app_locale';

  final SharedPreferencesAsync _preferences;

  Future<Locale?> read() async {
    final code = await _preferences.getString(storageKey);
    return localeForCode(code);
  }

  Future<void> save(Locale locale) =>
      _preferences.setString(storageKey, locale.languageCode);

  Future<void> clear() => _preferences.remove(storageKey);
}

@Riverpod(keepAlive: true)
LocaleRepository localeRepository(Ref ref) =>
    LocaleRepository(SharedPreferencesAsync());
