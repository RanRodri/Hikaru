import 'dart:typed_data';

/// One face photo of a 30-day cycle.
///
/// [storageKey] is the private S3 path (`reflection-photos/{identityId}/…`).
/// It is empty until the upload succeeds. The signed URL is never stored.
class ReflectionEntry {
  const ReflectionEntry({
    required this.id,
    required this.cycleId,
    required this.dayNumber,
    this.storageKey,
    this.pendingUpload = true,
  });

  final String id;
  final String cycleId;
  final int dayNumber;
  final String? storageKey;
  final bool pendingUpload;

  ReflectionEntry copyWith({
    String? id,
    String? storageKey,
    bool? pendingUpload,
  }) => ReflectionEntry(
    id: id ?? this.id,
    cycleId: cycleId,
    dayNumber: dayNumber,
    storageKey: storageKey ?? this.storageKey,
    pendingUpload: pendingUpload ?? this.pendingUpload,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'cycleId': cycleId,
    'dayNumber': dayNumber,
    'storageKey': storageKey,
    'pendingUpload': pendingUpload,
  };

  static ReflectionEntry? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final cycleId = json['cycleId'];
    final dayNumber = json['dayNumber'];
    if (id is! String || cycleId is! String || dayNumber is! int) return null;
    final storageKey = json['storageKey'];
    return ReflectionEntry(
      id: id,
      cycleId: cycleId,
      dayNumber: dayNumber,
      storageKey: storageKey is String && storageKey.isNotEmpty
          ? storageKey
          : null,
      pendingUpload: json['pendingUpload'] == true,
    );
  }
}

/// One saved face photo, ready to show.
class ReflectionShot {
  const ReflectionShot({required this.dayNumber, required this.bytes});

  final int dayNumber;
  final Uint8List bytes;
}

/// Photos the journey card can show.
class ReflectionGallery {
  const ReflectionGallery({
    this.before,
    this.later,
    this.canCapture = true,
    this.shots = const [],
  });

  static const ReflectionGallery empty = ReflectionGallery(canCapture: true);

  /// Day 1. Stays as taken.
  final Uint8List? before;

  /// The newest photo after day 1.
  final Uint8List? later;

  /// Today's photo can still be taken. Day 1 cannot be replaced.
  final bool canCapture;

  /// Every photo of the open cycle, from day 1 onward.
  final List<ReflectionShot> shots;

  /// Newest day after day 1. The gallery marks that photo as current.
  int? get currentDayNumber {
    int? latest;
    for (final shot in shots) {
      if (shot.dayNumber <= 1) continue;
      final known = latest;
      if (known == null || shot.dayNumber > known) latest = shot.dayNumber;
    }
    return latest;
  }
}

/// Day 1 is kept. Any later day can be taken or replaced.
bool canCaptureReflectionDay(Iterable<ReflectionEntry> entries, int day) {
  if (day == 1) return !entries.any((entry) => entry.dayNumber == 1);
  return true;
}

ReflectionEntry? reflectionOnDay(Iterable<ReflectionEntry> entries, int day) {
  for (final entry in entries) {
    if (entry.dayNumber == day) return entry;
  }
  return null;
}

/// Newest photo after day 1.
ReflectionEntry? latestLaterReflection(Iterable<ReflectionEntry> entries) {
  ReflectionEntry? latest;
  for (final entry in entries) {
    if (entry.dayNumber <= 1) continue;
    final current = latest;
    if (current == null || entry.dayNumber > current.dayNumber) latest = entry;
  }
  return latest;
}

/// `reflection-photos/{identityId}/{cycleId}/day-1.jpg`
String reflectionObjectName(String cycleId, int dayNumber, List<int> bytes) {
  final extension = _isPng(bytes) ? 'png' : 'jpg';
  return '$cycleId/day-$dayNumber.$extension';
}

String reflectionContentType(List<int> bytes) =>
    _isPng(bytes) ? 'image/png' : 'image/jpeg';

bool _isPng(List<int> bytes) =>
    bytes.length >= 8 &&
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x4E &&
    bytes[3] == 0x47;
