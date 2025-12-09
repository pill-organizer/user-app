import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/schedule.dart';
import '../repository/schedule_repository.dart';

// Events
sealed class ScheduleListEvent extends Equatable {
  const ScheduleListEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleListToggleRequested extends ScheduleListEvent {
  final String id;
  final bool enabled;

  const ScheduleListToggleRequested({required this.id, required this.enabled});

  @override
  List<Object> get props => [id, enabled];
}

class ScheduleListDeleteRequested extends ScheduleListEvent {
  final String id;

  const ScheduleListDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class _ScheduleListUpdated extends ScheduleListEvent {
  final List<Schedule> schedules;

  const _ScheduleListUpdated(this.schedules);

  @override
  List<Object> get props => [schedules];
}

class _ScheduleListError extends ScheduleListEvent {
  final String message;

  const _ScheduleListError(this.message);

  @override
  List<Object> get props => [message];
}

// States
sealed class ScheduleListState extends Equatable {
  const ScheduleListState();

  @override
  List<Object?> get props => [];
}

class ScheduleListInitial extends ScheduleListState {}

class ScheduleListLoaded extends ScheduleListState {
  final List<Schedule> schedules;
  final List<Schedule> todaySchedules;
  final List<Schedule> todayFutureSchedules;

  Schedule? get nextSchedule => todayFutureSchedules.firstOrNull;
  int get allTodaySchedulesCount => todaySchedules.length;
  int get todayFutureSchedulesCount => todayFutureSchedules.length;
  int get alreadyTakenSchedulesCount => allTodaySchedulesCount - todayFutureSchedulesCount;

  const ScheduleListLoaded({
    required this.schedules,
    required this.todaySchedules,
    required this.todayFutureSchedules,
  });

  @override
  List<Object?> get props => [schedules, todaySchedules, todayFutureSchedules];
}

class ScheduleListError extends ScheduleListState {
  final String message;

  const ScheduleListError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ScheduleListBloc extends Bloc<ScheduleListEvent, ScheduleListState> {
  ScheduleListBloc({required ScheduleRepository repository})
    : _repository = repository,
      super(ScheduleListInitial()) {
    _schedulesSubscription = _repository.schedulesStream.listen(
      (schedules) => add(_ScheduleListUpdated(schedules)),
      onError: (error) => add(_ScheduleListError(error.toString())),
    );
    on<ScheduleListToggleRequested>(_onToggleRequested);
    on<ScheduleListDeleteRequested>(_onDeleteRequested);
    on<_ScheduleListUpdated>(_onSchedulesUpdated);
    on<_ScheduleListError>(_onScheduleListError);
  }

  final ScheduleRepository _repository;
  late final StreamSubscription<List<Schedule>> _schedulesSubscription;

  @override
  Future<void> close() {
    _schedulesSubscription.cancel();
    return super.close();
  }

  void _onScheduleListError(_ScheduleListError event, Emitter<ScheduleListState> emit) {
    emit(ScheduleListError(event.message));
  }

  void _onSchedulesUpdated(_ScheduleListUpdated event, Emitter<ScheduleListState> emit) {
    final now = DateTime.now();
    final currentWeekday = WeekDay.fromInt(now.weekday);
    final currentTime = TimeOfDay.now();

    // Filter today's schedules (all schedules for today)
    final todaySchedules =
        event.schedules.where((s) => s.enabled && s.days.contains(currentWeekday)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));

    // Filter future schedules (only those after current time)
    final todayFutureSchedules = todaySchedules
        .where((s) => s.time.compareTo(currentTime) > 0)
        .toList();

    emit(
      ScheduleListLoaded(
        schedules: event.schedules,
        todaySchedules: todaySchedules,
        todayFutureSchedules: todayFutureSchedules,
      ),
    );
  }

  Future<void> _onToggleRequested(
    ScheduleListToggleRequested event,
    Emitter<ScheduleListState> emit,
  ) async {
    try {
      await _repository.toggleSchedule(event.id, event.enabled);
    } catch (e) {
      emit(ScheduleListError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    ScheduleListDeleteRequested event,
    Emitter<ScheduleListState> emit,
  ) async {
    try {
      await _repository.deleteSchedule(event.id);
    } catch (e) {
      emit(ScheduleListError(e.toString()));
    }
  }
}
