import '../../crystals/domain/crystal.dart';
import '../../crystals/domain/crystal_code.dart';
import 'journey_progress.dart';

const int ritualCycleLength = 30;

/// Calendar day without a time, in the device's local zone.
DateTime dateOnly(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// What the member has finished today: Merkaba, massage, and the frequency.
class DailyRitualFlags {
  const DailyRitualFlags({
    this.merkaba = false,
    this.massage = false,
    this.frequency = false,
  });

  static const DailyRitualFlags none = DailyRitualFlags();

  final bool merkaba;
  final bool massage;
  final bool frequency;

  /// The frequency opens once the body has been prepared.
  bool get frequencyUnlocked => merkaba && massage;

  bool get completed => merkaba && massage && frequency;

  DailyRitualFlags copyWith({bool? merkaba, bool? massage, bool? frequency}) =>
      DailyRitualFlags(
        merkaba: merkaba ?? this.merkaba,
        massage: massage ?? this.massage,
        frequency: frequency ?? this.frequency,
      );

  Map<String, Object?> toJson() => {
    'merkaba': merkaba,
    'massage': massage,
    'frequency': frequency,
  };

  @override
  bool operator ==(Object other) =>
      other is DailyRitualFlags &&
      other.merkaba == merkaba &&
      other.massage == massage &&
      other.frequency == frequency;

  @override
  int get hashCode => Object.hash(merkaba, massage, frequency);

  static DailyRitualFlags fromJson(Object? json) {
    if (json is! Map) return none;
    return DailyRitualFlags(
      merkaba: json['merkaba'] == true,
      massage: json['massage'] == true,
      frequency: json['frequency'] == true,
    );
  }
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
  });

  final String id;
  final DateTime startDate;
  final Crystal crystal;
  final bool isActive;

  /// Consecutive days with the three rituals done, ending on
  /// [lastCompletedDate].
  final int streak;
  final DateTime? lastCompletedDate;

  /// Streak after completing [today]: continues from yesterday, else restarts.
  int streakAfterCompleting(DateTime today) {
    final last = lastCompletedDate;
    if (last == null) return 1;
    final gap = dateOnly(today).difference(last).inDays;
    if (gap == 0) return streak;
    return gap == 1 ? streak + 1 : 1;
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
    bool? isActive,
    int? streak,
    DateTime? lastCompletedDate,
  }) => RitualCycle(
    id: id,
    startDate: startDate,
    crystal: crystal,
    isActive: isActive ?? this.isActive,
    streak: streak ?? this.streak,
    lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
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
  };

  static RitualCycle? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final start = DateTime.tryParse('${json['startDate']}');
    final crystal = CrystalCode.fromBackendCode(json['crystal'] as String?);
    if (id is! String || start == null || crystal == null) return null;
    final streak = json['streak'];
    final lastCompleted = DateTime.tryParse('${json['lastCompletedDate']}');
    return RitualCycle(
      id: id,
      startDate: dateOnly(start),
      crystal: crystal,
      isActive: json['isActive'] == true,
      streak: streak is int ? streak : 0,
      lastCompletedDate: lastCompleted == null ? null : dateOnly(lastCompleted),
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
      streak: open.streak,
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
