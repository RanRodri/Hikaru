import 'dart:ui' show Locale;

/// The languages Hikaru ships. English is the default and template locale.
const List<Locale> supportedLocales = [Locale('en'), Locale('es')];

/// Language used until the user picks another one in Profile. The device
/// language is intentionally ignored.
const Locale defaultLocale = Locale('en');

/// Resolves a stored/selected language code to a supported [Locale].
///
/// Returns `null` when [code] is null or not among [supportedLocales], which
/// means the user has not chosen a language and [defaultLocale] applies.
Locale? localeForCode(String? code) {
  if (code == null) return null;
  for (final locale in supportedLocales) {
    if (locale.languageCode == code) return locale;
  }
  return null;
}
