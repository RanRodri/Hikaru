import 'package:shared_preferences/shared_preferences.dart';

/// How many times the headphones note has been confirmed.
///
/// The crystal screen shows it on Play for the first [showLimit] times only.
class CymaticHeadphonesPrompts {
  const CymaticHeadphonesPrompts(this._preferences);

  static const String storageKey = 'cymatic_headphones_prompt_count';
  static const int showLimit = 3;

  final SharedPreferencesAsync _preferences;

  Future<int> readCount() async => await _preferences.getInt(storageKey) ?? 0;

  Future<bool> shouldShow() async => await readCount() < showLimit;

  Future<void> recordShown() async {
    final count = await readCount();
    await _preferences.setInt(storageKey, count + 1);
  }
}
