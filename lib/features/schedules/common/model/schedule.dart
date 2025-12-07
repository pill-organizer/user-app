import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum WeekDay {
  mon(1),
  tue(2),
  wed(3),
  thu(4),
  fri(5),
  sat(6),
  sun(7);

  const WeekDay(this.dayIndex);

  String get name {
    switch (this) {
      case WeekDay.mon:
        return 'Monday';
      case WeekDay.tue:
        return 'Tuesday';
      case WeekDay.wed:
        return 'Wednesday';
      case WeekDay.thu:
        return 'Thursday';
      case WeekDay.fri:
        return 'Friday';
      case WeekDay.sat:
        return 'Saturday';
      case WeekDay.sun:
        return 'Sunday';
    }
  }

  String get shortName {
    switch (this) {
      case WeekDay.mon:
        return 'Mon';
      case WeekDay.tue:
        return 'Tue';
      case WeekDay.wed:
        return 'Wed';
      case WeekDay.thu:
        return 'Thu';
      case WeekDay.fri:
        return 'Fri';
      case WeekDay.sat:
        return 'Sat';
      case WeekDay.sun:
        return 'Sun';
    }
  }

  factory WeekDay.fromInt(int dayIndex) =>
      WeekDay.values.firstWhere((day) => day.dayIndex == dayIndex);

  factory WeekDay.fromDateTime(DateTime dateTime) =>
      WeekDay.values.firstWhere((day) => day.dayIndex == dateTime.weekday);

  final int dayIndex;

  int daysUntill(DateTime now) {
    final diff = dayIndex - now.weekday;
    return diff >= 0 ? diff : 7 + diff;
  }

  /// return closes date time within one week
  DateTime get closestDateTime {
    final now = DateTime.now();
    final daysUntil = daysUntill(now);
    return now.add(Duration(days: daysUntil));
  }

  static String getReadableDays(Set<WeekDay> days) {
    if (days.isEmpty) return 'Never';
    if (days.length == 7) return 'Every day';
    if (days.length == 5 &&
        days.contains(WeekDay.mon) &&
        days.contains(WeekDay.tue) &&
        days.contains(WeekDay.wed) &&
        days.contains(WeekDay.thu) &&
        days.contains(WeekDay.fri)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(WeekDay.sat) && days.contains(WeekDay.sun)) {
      return 'Weekends';
    }
    return days.map((d) => d.shortName).join(', ');
  }

  static List<WeekDay> get weekDaysSortedFromToday {
    final now = DateTime.now();
    final sortedDays = List<WeekDay>.from(
      WeekDay.values,
    ).sorted((a, b) => a.daysUntill(now).compareTo(b.daysUntill(now)));
    return sortedDays;
  }
}

class Schedule extends Equatable {
  final String? id;
  final String pillName;
  final TimeOfDay time; // Format: HH:mm
  final Set<WeekDay> days; // Format: "1,2,3,4,5" (weekdays 1-7)
  final bool enabled;

  const Schedule({
    this.id,
    required this.pillName,
    required this.time,
    required this.days,
    this.enabled = true,
  });

  factory Schedule.fromJson(String id, Map<dynamic, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return Schedule(
      id: id,
      pillName: json['pillName'] as String,
      time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      days: (json['days'] as String).split(',').map((e) => WeekDay.fromInt(int.parse(e))).toSet(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pillName': pillName,
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'days': days.map((d) => d.dayIndex).join(','),
      'enabled': enabled,
    };
  }

  Schedule copyWith({
    String? id,
    String? pillName,
    TimeOfDay? time,
    Set<WeekDay>? days,
    bool? enabled,
  }) {
    return Schedule(
      id: id ?? this.id,
      pillName: pillName ?? this.pillName,
      time: time ?? this.time,
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [id, pillName, time, days, enabled];
}
