import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers that the first Home visit already showed the tour.
class HomeTourStore {
  HomeTourStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String seenKey = 'hikaru_home_tour_seen';

  final SharedPreferencesAsync _preferences;

  Future<bool> seen() async => await _preferences.getBool(seenKey) ?? false;

  Future<void> markSeen() => _preferences.setBool(seenKey, true);
}

final homeTourStoreProvider = Provider<HomeTourStore>((ref) => HomeTourStore());
