import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/device_config.dart';
import '../../../data/repositories/device_repository.dart';

// Events
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class SettingsUpdatePin extends SettingsEvent {
  final String newPin;

  const SettingsUpdatePin(this.newPin);

  @override
  List<Object> get props => [newPin];
}

class SettingsAddRfidToken extends SettingsEvent {
  final String name;
  final String token;

  const SettingsAddRfidToken({
    required this.name,
    required this.token,
  });

  @override
  List<Object> get props => [name, token];
}

class SettingsRemoveRfidToken extends SettingsEvent {
  final String name;

  const SettingsRemoveRfidToken(this.name);

  @override
  List<Object> get props => [name];
}

class SettingsUpdateTemperatureThresholds extends SettingsEvent {
  final double min;
  final double max;

  const SettingsUpdateTemperatureThresholds({
    required this.min,
    required this.max,
  });

  @override
  List<Object> get props => [min, max];
}

class SettingsUpdateHumidityThresholds extends SettingsEvent {
  final double min;
  final double max;

  const SettingsUpdateHumidityThresholds({
    required this.min,
    required this.max,
  });

  @override
  List<Object> get props => [min, max];
}

class SettingsToggleBuzzer extends SettingsEvent {
  final bool enabled;

  const SettingsToggleBuzzer(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class SettingsTogglePushNotifications extends SettingsEvent {
  final bool enabled;

  const SettingsTogglePushNotifications(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class _ConfigUpdated extends SettingsEvent {
  final DeviceConfig config;

  const _ConfigUpdated(this.config);

  @override
  List<Object> get props => [config];
}

// States
sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final DeviceConfig config;

  const SettingsLoaded(this.config);

  @override
  List<Object> get props => [config];
}

class SettingsOperationSuccess extends SettingsState {
  final String message;
  final DeviceConfig config;

  const SettingsOperationSuccess({
    required this.message,
    required this.config,
  });

  @override
  List<Object> get props => [message, config];
}

class SettingsError extends SettingsState {
  final String message;
  final DeviceConfig? config;

  const SettingsError(this.message, {this.config});

  @override
  List<Object?> get props => [message, config];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final DeviceRepository _repository;
  StreamSubscription<DeviceConfig>? _configSubscription;
  DeviceConfig _currentConfig = const DeviceConfig();

  SettingsBloc({required DeviceRepository repository})
      : _repository = repository,
        super(SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsUpdatePin>(_onUpdatePin);
    on<SettingsAddRfidToken>(_onAddRfidToken);
    on<SettingsRemoveRfidToken>(_onRemoveRfidToken);
    on<SettingsUpdateTemperatureThresholds>(_onUpdateTemperatureThresholds);
    on<SettingsUpdateHumidityThresholds>(_onUpdateHumidityThresholds);
    on<SettingsToggleBuzzer>(_onToggleBuzzer);
    on<SettingsTogglePushNotifications>(_onTogglePushNotifications);
    on<_ConfigUpdated>(_onConfigUpdated);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    
    _configSubscription?.cancel();
    _configSubscription = _repository.configStream.listen(
      (config) => add(_ConfigUpdated(config)),
    );
  }

  void _onConfigUpdated(
    _ConfigUpdated event,
    Emitter<SettingsState> emit,
  ) {
    _currentConfig = event.config;
    emit(SettingsLoaded(event.config));
  }

  Future<void> _onUpdatePin(
    SettingsUpdatePin event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.updatePin(event.newPin);
      emit(SettingsOperationSuccess(
        message: 'PIN updated successfully',
        config: _currentConfig,
      ));
    } catch (e) {
      emit(SettingsError(e.toString(), config: _currentConfig));
    }
  }

  Future<void> _onAddRfidToken(
    SettingsAddRfidToken event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.addRfidToken(event.name, event.token);
      emit(SettingsOperationSuccess(
        message: 'RFID token added successfully',
        config: _currentConfig,
      ));
    } catch (e) {
      emit(SettingsError(e.toString(), config: _currentConfig));
    }
  }

  Future<void> _onRemoveRfidToken(
    SettingsRemoveRfidToken event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.removeRfidToken(event.name);
      emit(SettingsOperationSuccess(
        message: 'RFID token removed successfully',
        config: _currentConfig,
      ));
    } catch (e) {
      emit(SettingsError(e.toString(), config: _currentConfig));
    }
  }

  Future<void> _onUpdateTemperatureThresholds(
    SettingsUpdateTemperatureThresholds event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.updateTemperatureThresholds(
        min: event.min,
        max: event.max,
      );
      emit(SettingsOperationSuccess(
        message: 'Temperature thresholds updated',
        config: _currentConfig,
      ));
    } catch (e) {
      emit(SettingsError(e.toString(), config: _currentConfig));
    }
  }

  Future<void> _onUpdateHumidityThresholds(
    SettingsUpdateHumidityThresholds event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.updateHumidityThresholds(
        min: event.min,
        max: event.max,
      );
      emit(SettingsOperationSuccess(
        message: 'Humidity thresholds updated',
        config: _currentConfig,
      ));
    } catch (e) {
      emit(SettingsError(e.toString(), config: _currentConfig));
    }
  }

  Future<void> _onToggleBuzzer(
    SettingsToggleBuzzer event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.setBuzzerEnabled(event.enabled);
    } catch (e) {
      emit(SettingsError(e.toString(), config: _currentConfig));
    }
  }

  Future<void> _onTogglePushNotifications(
    SettingsTogglePushNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.setPushNotificationsEnabled(event.enabled);
    } catch (e) {
      emit(SettingsError(e.toString(), config: _currentConfig));
    }
  }

  @override
  Future<void> close() {
    _configSubscription?.cancel();
    return super.close();
  }
}

