import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberProfile {
  const MemberProfile({required this.name, this.photo});

  static const String defaultName = 'María González';

  final String name;
  final Uint8List? photo;
}

class MemberProfileRepository {
  MemberProfileRepository(this._preferences);

  static const String _nameKey = 'member_profile_name';
  static const String _photoFileName = 'member_portrait.jpg';

  final SharedPreferencesAsync _preferences;

  Future<MemberProfile> read() async {
    final storedName = await _preferences.getString(_nameKey);
    final name = storedName == null || storedName.trim().isEmpty
        ? MemberProfile.defaultName
        : storedName.trim();
    final file = await _photoFile();
    final photo = await file.exists() ? await file.readAsBytes() : null;
    return MemberProfile(name: name, photo: photo);
  }

  Future<void> save({required String name, Uint8List? photo}) async {
    final trimmed = name.trim();
    await _preferences.setString(
      _nameKey,
      trimmed.isEmpty ? MemberProfile.defaultName : trimmed,
    );
    if (photo == null) return;
    final file = await _photoFile();
    await file.writeAsBytes(photo, flush: true);
  }

  Future<File> _photoFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_photoFileName');
  }
}
