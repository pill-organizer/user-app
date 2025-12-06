import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final String? id;
  final String pillName;
  final String time; // Format: HH:mm
  final String days; // Format: "1,2,3,4,5" (weekdays 1-7)
  final bool enabled;

  const Schedule({
    this.id,
    required this.pillName,
    required this.time,
    required this.days,
    this.enabled = true,
  });

  factory Schedule.fromJson(String id, Map<dynamic, dynamic> json) {
    return Schedule(
      id: id,
      pillName: json['pillName'] as String,
      time: json['time'] as String,
      days: json['days'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pillName': pillName,
      'time': time,
      'days': days,
      'enabled': enabled,
    };
  }

  Schedule copyWith({
    String? id,
    String? pillName,
    String? time,
    String? days,
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

