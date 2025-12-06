import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/schedule.dart';
import '../repository/schedule_repository.dart';

// Events
sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleLoadRequested extends ScheduleEvent {}

class ScheduleCreateRequested extends ScheduleEvent {
  final Schedule schedule;

  const ScheduleCreateRequested(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class ScheduleUpdateRequested extends ScheduleEvent {
  final Schedule schedule;

  const ScheduleUpdateRequested(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class ScheduleDeleteRequested extends ScheduleEvent {
  final String id;

  const ScheduleDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class ScheduleToggleRequested extends ScheduleEvent {
  final String id;
  final bool enabled;

  const ScheduleToggleRequested({
    required this.id,
    required this.enabled,
  });

  @override
  List<Object> get props => [id, enabled];
}

class _SchedulesUpdated extends ScheduleEvent {
  final List<Schedule> schedules;

  const _SchedulesUpdated(this.schedules);

  @override
  List<Object> get props => [schedules];
}

// States
sealed class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<Schedule> schedules;
  final List<Schedule> todaySchedules;
  final Schedule? nextSchedule;

  const ScheduleLoaded({
    required this.schedules,
    required this.todaySchedules,
    this.nextSchedule,
  });

  @override
  List<Object?> get props => [schedules, todaySchedules, nextSchedule];
}

class ScheduleOperationSuccess extends ScheduleState {
  final String message;

  const ScheduleOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _repository;
  StreamSubscription<List<Schedule>>? _schedulesSubscription;

  ScheduleBloc({required ScheduleRepository repository})
      : _repository = repository,
        super(ScheduleInitial()) {
    on<ScheduleLoadRequested>(_onLoadRequested);
    on<ScheduleCreateRequested>(_onCreateRequested);
    on<ScheduleUpdateRequested>(_onUpdateRequested);
    on<ScheduleDeleteRequested>(_onDeleteRequested);
    on<ScheduleToggleRequested>(_onToggleRequested);
    on<_SchedulesUpdated>(_onSchedulesUpdated);
  }

  Future<void> _onLoadRequested(
    ScheduleLoadRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    
    _schedulesSubscription?.cancel();
    _schedulesSubscription = _repository.schedulesStream.listen(
      (schedules) => add(_SchedulesUpdated(schedules)),
    );
  }

  void _onSchedulesUpdated(
    _SchedulesUpdated event,
    Emitter<ScheduleState> emit,
  ) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Filter today's schedules
    final todaySchedules = event.schedules.where((s) {
      if (!s.enabled) return false;
      final days = s.days.split(',').map((d) => int.tryParse(d.trim())).toList();
      return days.contains(currentWeekday);
    }).toList();

    // Find next schedule
    Schedule? nextSchedule;
    for (final schedule in todaySchedules) {
      if (schedule.time.compareTo(currentTime) > 0) {
        nextSchedule = schedule;
        break;
      }
    }

    emit(ScheduleLoaded(
      schedules: event.schedules,
      todaySchedules: todaySchedules,
      nextSchedule: nextSchedule,
    ));
  }

  Future<void> _onCreateRequested(
    ScheduleCreateRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.createSchedule(event.schedule);
      emit(const ScheduleOperationSuccess('Schedule created successfully'));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ScheduleUpdateRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.updateSchedule(event.schedule);
      emit(const ScheduleOperationSuccess('Schedule updated successfully'));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    ScheduleDeleteRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.deleteSchedule(event.id);
      emit(const ScheduleOperationSuccess('Schedule deleted successfully'));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onToggleRequested(
    ScheduleToggleRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.toggleSchedule(event.id, event.enabled);
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _schedulesSubscription?.cancel();
    return super.close();
  }
}

