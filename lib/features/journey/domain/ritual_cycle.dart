import '../../crystals/domain/crystal.dart';
import '../../crystals/domain/crystal_code.dart';
import 'journey_progress.dart';

const int ritualCycleLength = 30;

/// Calendar day without a time, in the device's local zone.
DateTime dateOnly(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// The four steps of the daily ritual, in the order they are done.
enum RitualStep { merkaba, facial, body, crystal }

/// What the member has finished today: Merkaba, the facial and body rituals,
/// and the crystal with its frequency.
class DailyRitualFlags {
  const DailyRitualFlags({
    this.merkaba = false,
    this.facial = false,
    this.body = false,
    this.frequency = false,
  });

  static const DailyRitualFlags none = DailyRitualFlags();

  final bool merkaba;
  final bool facial;
  final bool body;
  final bool frequency;

  /// Both massages, the single flag older backends and app versions know.
  bool get massage => facial && body;

  /// The frequency opens once the body has been prepared.
  bool get frequencyUnlocked => merkaba && massage;

  bool get completed => merkaba && facial && body && frequency;

  /// Nothing done at all.
  bool get isEmpty => !merkaba && !facial && !body && !frequency;

  bool isDone(RitualStep step) => switch (step) {
    RitualStep.merkaba => merkaba,
    RitualStep.facial => facial,
    RitualStep.body => body,
    RitualStep.crystal => frequency,
  };

  /// Steps still waiting today, in ritual order.
  List<RitualStep> get pending => [
    for (final step in RitualStep.values)
      if (!isDone(step)) step,
  ];

  int get doneCount => RitualStep.values.length - pending.length;

  DailyRitualFlags copyWith({
    bool? merkaba,
    bool? facial,
    bool? body,
    bool? frequency,
  }) => DailyRitualFlags(
    merkaba: merkaba ?? this.merkaba,
    facial: facial ?? this.facial,
    body: body ?? this.body,
    frequency: frequency ?? this.frequency,
  );

  /// Either side done counts as done.
  DailyRitualFlags union(DailyRitualFlags other) => DailyRitualFlags(
    merkaba: merkaba || other.merkaba,
    facial: facial || other.facial,
    body: body || other.body,
    frequency: frequency || other.frequency,
  );

  Map<String, Object?> toJson() => {
    'merkaba': merkaba,
    'facial': facial,
    'body': body,
    'massage': massage,
    'frequency': frequency,
  };

  @override
  bool operator ==(Object other) =>
      other is DailyRitualFlags &&
      other.merkaba == merkaba &&
      other.facial == facial &&
      other.body == body &&
      other.frequency == frequency;

  @override
  int get hashCode => Object.hash(merkaba, facial, body, frequency);

  /// Reads the device copy. Copies saved before facial and body were split
  /// only have `massage`, which meant both were done.
  static DailyRitualFlags fromJson(Object? json) {
    if (json is! Map) return none;
    final legacyMassage = json['massage'] == true;
    return DailyRitualFlags(
      merkaba: json['merkaba'] == true,
      facial: json.containsKey('facial')
          ? json['facial'] == true
          : legacyMassage,
      body: json.containsKey('body') ? json['body'] == true : legacyMassage,
      frequency: json['frequency'] == true,
    );
  }

  /// Reads a backend `DailyRitual` row. Rows written before the split have
  /// no facial or body value; their `isMassageDone` meant both were done.
  static DailyRitualFlags fromRow(Map<String, dynamic> row) {
    final legacyMassage = row['isMassageDone'] == true;
    final facial = row['isFacialDone'];
    final body = row['isBodyDone'];
    return DailyRitualFlags(
      merkaba: row['isMerkabahDone'] == true,
      facial: facial is bool ? facial : legacyMassage,
      body: body is bool ? body : legacyMassage,
      frequency: row['isFrequencyDone'] == true,
    );
  }
}

/// What was done on one day of a cycle.
class RitualDay {
  const RitualDay({
    required this.dayNumber,
    required this.date,
    required this.flags,
  });

  final int dayNumber;
  final DateTime date;
  final DailyRitualFlags flags;
}

/// One 30-day journey with a crystal.
class RitualCycle {
  const RitualCycle({
    required this.id,
    required this.startDate,
    required this.crystal,
    required this.isActive,
    required this.streak,
    this.lastCompletedDate,
    this.completedAt,
    this.completedDays,
  });

  final String id;
  final DateTime startDate;
  final Crystal crystal;
  final bool isActive;

  /// Consecutive days with the full ritual done, ending on
  /// [lastCompletedDate].
  final int streak;
  final DateTime? lastCompletedDate;

  /// When the member closed the cycle by choosing what comes next.
  final DateTime? completedAt;

  /// Days with the full ritual done, saved when the cycle was closed.
  final int? completedDays;

  /// Streak after completing [today]: continues from yesterday, else restarts.
  int streakAfterCompleting(DateTime today) {
    final last = lastCompletedDate;
    if (last == null) return 1;
    final gap = dateOnly(today).difference(last).inDays;
    if (gap == 0) return streak;
    return gap == 1 ? streak + 1 : 1;
  }

  /// The streak as it stands on [today]. A day missed since the last full
  /// ritual breaks it, even before the next completion recalculates it.
  int streakOn(DateTime today) {
    final last = lastCompletedDate;
    if (last == null) return 0;
    final gap = dateOnly(today).difference(last).inDays;
    return gap <= 1 ? streak : 0;
  }

  /// The 30 days are over, or the last day's ritual is done, and the member
  /// has not yet chosen how to continue.
  bool awaitingClosureOn(DateTime today, {required bool todayCompleted}) {
    if (!isActive) return false;
    final date = dateOnly(today);
    if (date.isAfter(endDate)) return true;
    return date == endDate && todayCompleted;
  }

  DateTime get endDate =>
      startDate.add(const Duration(days: ritualCycleLength - 1));

  /// 1-based day for [today], clamped to the cycle.
  int dayNumber(DateTime today) {
    final days = dateOnly(today).difference(startDate).inDays + 1;
    return days.clamp(1, ritualCycleLength);
  }

  /// Still running on [today]: active and the 30 days are not over.
  bool isOpenOn(DateTime today) =>
      isActive && !dateOnly(today).isAfter(endDate);

  RitualCycle copyWith({
    Crystal? crystal,
    bool? isActive,
    int? streak,
    DateTime? lastCompletedDate,
    DateTime? completedAt,
    int? completedDays,
  }) => RitualCycle(
    id: id,
    startDate: startDate,
    crystal: crystal ?? this.crystal,
    isActive: isActive ?? this.isActive,
    streak: streak ?? this.streak,
    lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    completedAt: completedAt ?? this.completedAt,
    completedDays: completedDays ?? this.completedDays,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'startDate': isoDate(startDate),
    'crystal': crystal.backendCode,
    'isActive': isActive,
    'streak': streak,
    'lastCompletedDate': lastCompletedDate == null
        ? null
        : isoDate(lastCompletedDate!),
    'completedAt': completedAt?.toUtc().toIso8601String(),
    'completedDays': completedDays,
  };

  static RitualCycle? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final start = DateTime.tryParse('${json['startDate']}');
    final crystal = CrystalCode.fromBackendCode(json['crystal'] as String?);
    if (id is! String || start == null || crystal == null) return null;
    final streak = json['streak'];
    final lastCompleted = DateTime.tryParse('${json['lastCompletedDate']}');
    final completedDays = json['completedDays'];
    return RitualCycle(
      id: id,
      startDate: dateOnly(start),
      crystal: crystal,
      isActive: json['isActive'] == true,
      streak: streak is int ? streak : 0,
      lastCompletedDate: lastCompleted == null ? null : dateOnly(lastCompleted),
      completedAt: DateTime.tryParse('${json['completedAt']}'),
      completedDays: completedDays is int ? completedDays : null,
    );
  }
}

/// `YYYY-MM-DD`, the format AppSync `AWSDate` expects.
String isoDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

/// The active cycle plus today's flags, as the screens consume them.
class CycleProgress {
  const CycleProgress({
    required this.cycle,
    required this.date,
    required this.today,
  });

  static const CycleProgress empty = CycleProgress(
    cycle: null,
    date: null,
    today: DailyRitualFlags.none,
  );

  final RitualCycle? cycle;

  /// Day the [today] flags belong to.
  final DateTime? date;
  final DailyRitualFlags today;

  /// Flags for [now], cleared when the cached ones belong to another day.
  DailyRitualFlags flagsOn(DateTime now) {
    final flagDate = date;
    if (flagDate == null || dateOnly(now) != dateOnly(flagDate)) {
      return DailyRitualFlags.none;
    }
    return today;
  }

  /// Journey progress for [now], or `null` when no cycle is open.
  JourneyProgress? journeyOn(DateTime now) {
    final open = cycle;
    if (open == null || !open.isOpenOn(now)) return null;
    return JourneyProgress(
      currentDay: open.dayNumber(now),
      cycleLength: ritualCycleLength,
      streak: open.streakOn(now),
    );
  }

  Map<String, Object?> toJson() => {
    'cycle': cycle?.toJson(),
    'date': date == null ? null : isoDate(date!),
    'today': today.toJson(),
  };

  static CycleProgress fromJson(Object? json) {
    if (json is! Map) return empty;
    final date = DateTime.tryParse('${json['date']}');
    return CycleProgress(
      cycle: RitualCycle.fromJson(json['cycle']),
      date: date == null ? null : dateOnly(date),
      today: DailyRitualFlags.fromJson(json['today']),
    );
  }
}
