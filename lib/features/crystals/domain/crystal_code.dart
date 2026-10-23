import 'crystal.dart';

/// Backend identifiers for the four crystals.
///
/// The AppSync `Crystal.code` key uses these values. The app enum keeps its
/// own names, so every translation goes through here.
extension CrystalCode on Crystal {
  String get backendCode => switch (this) {
    Crystal.jade => 'JADE',
    Crystal.whiteQuartz => 'WHITE_QUARTZ',
    Crystal.redJasper => 'RED_JASPER',
    Crystal.obsidian => 'OBSIDIAN',
  };

  /// Readable name stored next to the code.
  String get catalogName => switch (this) {
    Crystal.jade => 'Jade',
    Crystal.whiteQuartz => 'White Quartz',
    Crystal.redJasper => 'Red Jasper',
    Crystal.obsidian => 'Obsidian',
  };

  /// Meridians as the backend stores them: one entry per meridian.
  List<String> get meridianList =>
      meridians.split('·').map((part) => part.trim()).toList();

  static Crystal? fromBackendCode(String? code) {
    if (code == null) return null;
    for (final crystal in Crystal.values) {
      if (crystal.backendCode == code) return crystal;
    }
    return null;
  }
}

/// Backend `Question.id` for a quiz question number (`q1` … `q10`).
String quizQuestionBackendId(int number) => 'q$number';
