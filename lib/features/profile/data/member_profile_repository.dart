import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberProfile {
  const MemberProfile({required this.name, this.photo});

  /// Neutral stand-in until the member has a name.
  static const String defaultName = 'Hikaru Member';

  /// Placeholder of earlier versions, still saved on some phones. It is not
  /// anyone's real name, so it is read as "no name yet".
  static const String _legacyDefaultName = 'María González';

  /// A placeholder, not a name the member gave.
  static bool isPlaceholder(String name) =>
      name == defaultName || name == _legacyDefaultName;

  final String name;
  final Uint8List? photo;
}

class MemberProfileRepository {
  MemberProfileRepository(this._preferences);

  static const String _nameKey = 'member_profile_name';
  static const String _photoFileName = 'member_portrait.jpg';

  final SharedPreferencesAsync _preferences;

  Future<MemberProfile> read() async {
    final storedName = (await _preferences.getString(_nameKey))?.trim();
    final name =
        storedName == null ||
            storedName.isEmpty ||
            MemberProfile.isPlaceholder(storedName)
        ? MemberProfile.defaultName
        : storedName;
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

  /// Forgets the name and portrait kept on this device.
  Future<void> clear() async {
    await _preferences.remove(_nameKey);
    final file = await _photoFile();
    if (await file.exists()) await file.delete();
  }

  Future<File> _photoFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_photoFileName');
  }
}
