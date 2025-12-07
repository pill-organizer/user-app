import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/schedule.dart';
import '../repository/schedule_repository.dart';

// Events
sealed class ScheduleFormEvent extends Equatable {
  const ScheduleFormEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleFormLoadRequested extends ScheduleFormEvent {
  final String id;

  const ScheduleFormLoadRequested(this.id);

  @override
  List<Object> get props => [id];
}

class ScheduleFormCreateRequested extends ScheduleFormEvent {
  final Schedule schedule;

  const ScheduleFormCreateRequested(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class ScheduleFormUpdateRequested extends ScheduleFormEvent {
  final Schedule schedule;

  const ScheduleFormUpdateRequested(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class ScheduleFormDeleteRequested extends ScheduleFormEvent {
  final String id;

  const ScheduleFormDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

// States
sealed class ScheduleFormState extends Equatable {
  const ScheduleFormState();

  @override
  List<Object?> get props => [];
}

class ScheduleFormInitial extends ScheduleFormState {}

class ScheduleFormLoading extends ScheduleFormState {}

class ScheduleFormLoaded extends ScheduleFormState {
  final Schedule schedule;

  const ScheduleFormLoaded(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class ScheduleFormSuccess extends ScheduleFormState {
  final String message;

  const ScheduleFormSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ScheduleFormError extends ScheduleFormState {
  final String message;

  const ScheduleFormError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ScheduleFormBloc extends Bloc<ScheduleFormEvent, ScheduleFormState> {
  final ScheduleRepository _repository;

  ScheduleFormBloc({required ScheduleRepository repository})
    : _repository = repository,
      super(ScheduleFormInitial()) {
    on<ScheduleFormLoadRequested>(_onLoadRequested);
    on<ScheduleFormCreateRequested>(_onCreateRequested);
    on<ScheduleFormUpdateRequested>(_onUpdateRequested);
    on<ScheduleFormDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ScheduleFormLoadRequested event,
    Emitter<ScheduleFormState> emit,
  ) async {
    emit(ScheduleFormLoading());
    try {
      final schedule = await _repository.getSchedule(event.id);
      if (schedule != null) {
        emit(ScheduleFormLoaded(schedule));
      } else {
        emit(const ScheduleFormError('Schedule not found'));
      }
    } catch (e) {
      emit(ScheduleFormError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    ScheduleFormCreateRequested event,
    Emitter<ScheduleFormState> emit,
  ) async {
    emit(ScheduleFormLoading());
    try {
      await _repository.createSchedule(event.schedule);
      emit(const ScheduleFormSuccess('Schedule created successfully'));
    } catch (e) {
      emit(ScheduleFormError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ScheduleFormUpdateRequested event,
    Emitter<ScheduleFormState> emit,
  ) async {
    emit(ScheduleFormLoading());
    try {
      await _repository.updateSchedule(event.schedule);
      emit(const ScheduleFormSuccess('Schedule updated successfully'));
    } catch (e) {
      emit(ScheduleFormError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    ScheduleFormDeleteRequested event,
    Emitter<ScheduleFormState> emit,
  ) async {
    emit(ScheduleFormLoading());
    try {
      await _repository.deleteSchedule(event.id);
      emit(const ScheduleFormSuccess('Schedule deleted successfully'));
    } catch (e) {
      emit(ScheduleFormError(e.toString()));
    }
  }
}
