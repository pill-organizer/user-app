import 'package:flutter/material.dart';
import '../../common/model/schedule.dart';

class ScheduleFormNotifier extends ChangeNotifier {
  ScheduleFormNotifier({String? scheduleId})
      : _schedule = Schedule(
          id: scheduleId,
          pillName: '',
          time: TimeOfDay.now(),
          days: WeekDay.values.toSet(),
          enabled: true,
        );

  Schedule _schedule;

  Schedule get schedule => _schedule;
  String? get id => _schedule.id;
  String get pillName => _schedule.pillName;
  TimeOfDay get time => _schedule.time;
  Set<WeekDay> get days => _schedule.days;
  bool get enabled => _schedule.enabled;
  bool get isEditing => _schedule.id != null;

  void loadSchedule(Schedule schedule) {
    _schedule = schedule;
    notifyListeners();
  }

  void setPillName(String value) {
    _schedule = _schedule.copyWith(pillName: value);
    notifyListeners();
  }

  void setTime(TimeOfDay value) {
    _schedule = _schedule.copyWith(time: value);
    notifyListeners();
  }

  void setEnabled(bool value) {
    _schedule = _schedule.copyWith(enabled: value);
    notifyListeners();
  }

  void toggleDay(WeekDay day) {
    final newDays = Set<WeekDay>.from(_schedule.days);
    if (newDays.contains(day)) {
      if (newDays.length > 1) {
        newDays.remove(day);
      }
    } else {
      newDays.add(day);
    }
    _schedule = _schedule.copyWith(days: newDays);
    notifyListeners();
  }

  void selectAllDays() {
    _schedule = _schedule.copyWith(days: WeekDay.values.toSet());
    notifyListeners();
  }

  void selectWeekdays() {
    _schedule = _schedule.copyWith(
      days: {WeekDay.mon, WeekDay.tue, WeekDay.wed, WeekDay.thu, WeekDay.fri},
    );
    notifyListeners();
  }

  void selectWeekends() {
    _schedule = _schedule.copyWith(days: {WeekDay.sat, WeekDay.sun});
    notifyListeners();
  }

  bool validate() {
    return pillName.trim().isNotEmpty && days.isNotEmpty;
  }
}

class ScheduleFormProvider extends InheritedNotifier<ScheduleFormNotifier> {
  const ScheduleFormProvider({
    super.key,
    required ScheduleFormNotifier super.notifier,
    required super.child,
  });

  static ScheduleFormNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ScheduleFormProvider>();
    assert(provider != null, 'No ScheduleFormProvider found in context');
    return provider!.notifier!;
  }

  static ScheduleFormNotifier? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ScheduleFormProvider>();
    return provider?.notifier;
  }
}

