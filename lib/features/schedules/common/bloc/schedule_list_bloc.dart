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

class ScheduleListLoadRequested extends ScheduleListEvent {}

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

// States
sealed class ScheduleListState extends Equatable {
  const ScheduleListState();

  @override
  List<Object?> get props => [];
}

class ScheduleListInitial extends ScheduleListState {}

class ScheduleListLoading extends ScheduleListState {}

class ScheduleListLoaded extends ScheduleListState {
  final List<Schedule> schedules;
  final List<Schedule> todaySchedules;
  final Schedule? nextSchedule;

  const ScheduleListLoaded({
    required this.schedules,
    required this.todaySchedules,
    this.nextSchedule,
  });

  @override
  List<Object?> get props => [schedules, todaySchedules, nextSchedule];
}

class ScheduleListError extends ScheduleListState {
  final String message;

  const ScheduleListError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ScheduleListBloc extends Bloc<ScheduleListEvent, ScheduleListState> {
  final ScheduleRepository _repository;
  StreamSubscription<List<Schedule>>? _schedulesSubscription;

  ScheduleListBloc({required ScheduleRepository repository})
    : _repository = repository,
      super(ScheduleListInitial()) {
    on<ScheduleListLoadRequested>(_onLoadRequested);
    on<ScheduleListToggleRequested>(_onToggleRequested);
    on<ScheduleListDeleteRequested>(_onDeleteRequested);
    on<_ScheduleListUpdated>(_onSchedulesUpdated);
  }

  Future<void> _onLoadRequested(
    ScheduleListLoadRequested event,
    Emitter<ScheduleListState> emit,
  ) async {
    emit(ScheduleListLoading());

    _schedulesSubscription?.cancel();
    _schedulesSubscription = _repository.schedulesStream.listen(
      (schedules) => add(_ScheduleListUpdated(schedules)),
      onError: (error) => emit(ScheduleListError(error.toString())),
    );
  }

  void _onSchedulesUpdated(_ScheduleListUpdated event, Emitter<ScheduleListState> emit) {
    final now = DateTime.now();
    final currentWeekday = WeekDay.fromInt(now.weekday);
    final currentTime = TimeOfDay.now();

    // Filter today's schedules
    final todaySchedules = event.schedules.where((s) {
      if (!s.enabled) return false;
      return s.days.contains(currentWeekday);
    }).toList();

    // Sort by time
    todaySchedules.sort((a, b) => a.time.compareTo(b.time));

    // Find next schedule
    Schedule? nextSchedule;
    for (final schedule in todaySchedules) {
      if (schedule.time.compareTo(currentTime) > 0) {
        nextSchedule = schedule;
        break;
      }
    }

    emit(
      ScheduleListLoaded(
        schedules: event.schedules,
        todaySchedules: todaySchedules,
        nextSchedule: nextSchedule,
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

  @override
  Future<void> close() {
    _schedulesSubscription?.cancel();
    return super.close();
  }
}
