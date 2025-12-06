import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/environmental_data.dart';
import '../../../settings/common/model/device_config.dart';
import '../repository/environmental_repository.dart';
import '../../../settings/common/repository/device_repository.dart';

// Events
sealed class EnvironmentalEvent extends Equatable {
  const EnvironmentalEvent();

  @override
  List<Object?> get props => [];
}

class EnvironmentalLoadLatest extends EnvironmentalEvent {}

class EnvironmentalLoadHistory extends EnvironmentalEvent {
  final HistoryPeriod period;

  const EnvironmentalLoadHistory(this.period);

  @override
  List<Object> get props => [period];
}

class _LatestDataUpdated extends EnvironmentalEvent {
  final EnvironmentalData? data;

  const _LatestDataUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

class _ConfigUpdated extends EnvironmentalEvent {
  final DeviceConfig config;

  const _ConfigUpdated(this.config);

  @override
  List<Object> get props => [config];
}

enum HistoryPeriod { day, week, month }

// States
sealed class EnvironmentalState extends Equatable {
  const EnvironmentalState();

  @override
  List<Object?> get props => [];
}

class EnvironmentalInitial extends EnvironmentalState {}

class EnvironmentalLoading extends EnvironmentalState {}

class EnvironmentalLatestLoaded extends EnvironmentalState {
  final EnvironmentalData? latestData;
  final DeviceConfig config;
  final bool isTemperatureAlert;
  final bool isHumidityAlert;

  const EnvironmentalLatestLoaded({
    this.latestData,
    required this.config,
    this.isTemperatureAlert = false,
    this.isHumidityAlert = false,
  });

  @override
  List<Object?> get props => [latestData, config, isTemperatureAlert, isHumidityAlert];
}

class EnvironmentalHistoryLoaded extends EnvironmentalState {
  final List<EnvironmentalData> hourlyData;
  final List<DailyEnvironmentalData> dailyData;
  final HistoryPeriod period;
  final DeviceConfig config;

  const EnvironmentalHistoryLoaded({
    required this.hourlyData,
    required this.dailyData,
    required this.period,
    required this.config,
  });

  @override
  List<Object> get props => [hourlyData, dailyData, period, config];
}

class EnvironmentalError extends EnvironmentalState {
  final String message;

  const EnvironmentalError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class EnvironmentalBloc extends Bloc<EnvironmentalEvent, EnvironmentalState> {
  EnvironmentalBloc({
    required EnvironmentalRepository environmentalRepository,
    required DeviceRepository deviceRepository,
  }) : _environmentalRepository = environmentalRepository,
       _deviceRepository = deviceRepository,
       super(EnvironmentalInitial()) {
    on<EnvironmentalLoadLatest>(_onLoadLatest);
    on<EnvironmentalLoadHistory>(_onLoadHistory);
    on<_LatestDataUpdated>(_onLatestDataUpdated);
    on<_ConfigUpdated>(_onConfigUpdated);
  }

  final EnvironmentalRepository _environmentalRepository;
  final DeviceRepository _deviceRepository;
  StreamSubscription<EnvironmentalData?>? _dataSubscription;
  StreamSubscription<DeviceConfig>? _configSubscription;

  EnvironmentalData? _latestData;
  DeviceConfig _config = const DeviceConfig();

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    _configSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadLatest(
    EnvironmentalLoadLatest event,
    Emitter<EnvironmentalState> emit,
  ) async {
    emit(EnvironmentalLoading());

    _configSubscription?.cancel();
    _configSubscription = _deviceRepository.configStream.listen(
      (config) => add(_ConfigUpdated(config)),
    );

    _dataSubscription?.cancel();
    _dataSubscription = _environmentalRepository.latestDataStream.listen(
      (data) => add(_LatestDataUpdated(data)),
    );
  }

  void _onLatestDataUpdated(_LatestDataUpdated event, Emitter<EnvironmentalState> emit) {
    _latestData = event.data;
    _emitLatestState(emit);
  }

  void _onConfigUpdated(_ConfigUpdated event, Emitter<EnvironmentalState> emit) {
    _config = event.config;
    _emitLatestState(emit);
  }

  void _emitLatestState(Emitter<EnvironmentalState> emit) {
    bool tempAlert = false;
    bool humidityAlert = false;

    if (_latestData case final data?) {
      tempAlert = data.temperature < _config.tempMin || data.temperature > _config.tempMax;
      humidityAlert = data.humidity < _config.humidityMin || data.humidity > _config.humidityMax;
    }

    emit(
      EnvironmentalLatestLoaded(
        latestData: _latestData,
        config: _config,
        isTemperatureAlert: tempAlert,
        isHumidityAlert: humidityAlert,
      ),
    );
  }

  Future<void> _onLoadHistory(
    EnvironmentalLoadHistory event,
    Emitter<EnvironmentalState> emit,
  ) async {
    emit(EnvironmentalLoading());

    try {
      List<EnvironmentalData> hourlyData = [];
      List<DailyEnvironmentalData> dailyData = [];

      switch (event.period) {
        case HistoryPeriod.day:
          hourlyData = await _environmentalRepository.getLast24HoursData();
          break;
        case HistoryPeriod.week:
          dailyData = await _environmentalRepository.getLast7DaysData();
          break;
        case HistoryPeriod.month:
          dailyData = await _environmentalRepository.getLast30DaysData();
          break;
      }

      final config = await _deviceRepository.getConfig();

      emit(
        EnvironmentalHistoryLoaded(
          hourlyData: hourlyData,
          dailyData: dailyData,
          period: event.period,
          config: config,
        ),
      );
    } catch (e) {
      emit(EnvironmentalError(e.toString()));
    }
  }
}
