import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/environmental_data.dart';
import '../../../settings/common/model/device_config.dart';
import '../repository/environmental_repository.dart';
import '../../../settings/common/repository/device_repository.dart';

// Events
sealed class EnvironmentalDashboardEvent extends Equatable {
  const EnvironmentalDashboardEvent();

  @override
  List<Object?> get props => [];
}

class _LatestDataUpdated extends EnvironmentalDashboardEvent {
  final EnvironmentalData? data;

  const _LatestDataUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

class _ConfigUpdated extends EnvironmentalDashboardEvent {
  final DeviceConfig config;

  const _ConfigUpdated(this.config);

  @override
  List<Object> get props => [config];
}

// State
class EnvironmentalDashboardState extends Equatable {
  const EnvironmentalDashboardState({
    required this.latestData,
    required this.isLoading,
    required this.config,
    required this.errorMessage,
  });

  const EnvironmentalDashboardState.initial()
    : this(
        latestData: const EnvironmentalData.empty(),
        isLoading: true,
        config: const DeviceConfig(),
        errorMessage: null,
      );

  final EnvironmentalData latestData;
  final bool isLoading;
  final DeviceConfig config;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  EnvironmentalDashboardState error(String errorMessage) => copyWith(errorMessage: errorMessage);

  EnvironmentalDashboardState loading() => copyWith(isLoading: true);

  bool get isTemperatureAlert =>
      latestData.temperature < config.tempMin || latestData.temperature > config.tempMax;

  bool get isHumidityAlert =>
      latestData.humidity < config.humidityMin || latestData.humidity > config.humidityMax;

  EnvironmentalDashboardState loaded({EnvironmentalData? latestData, DeviceConfig? config}) =>
      copyWith(latestData: latestData, config: config, isLoading: false, errorMessage: null);

  EnvironmentalDashboardState copyWith({
    EnvironmentalData? latestData,
    bool? isLoading,
    DeviceConfig? config,
    String? errorMessage,
  }) {
    return EnvironmentalDashboardState(
      latestData: latestData ?? this.latestData,
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    latestData,
    isLoading,
    config,
    isTemperatureAlert,
    isHumidityAlert,
    errorMessage,
  ];
}

// Bloc
class EnvironmentalDashboardBloc
    extends Bloc<EnvironmentalDashboardEvent, EnvironmentalDashboardState> {
  EnvironmentalDashboardBloc({
    required EnvironmentalRepository environmentalRepository,
    required DeviceRepository deviceRepository,
  }) : _environmentalRepository = environmentalRepository,
       _deviceRepository = deviceRepository,
       super(EnvironmentalDashboardState.initial()) {
    _configSubscription = _deviceRepository.configStream.listen(
      (config) => add(_ConfigUpdated(config)),
    );
    _dataSubscription = _environmentalRepository.latestDataStream.listen(
      (data) => add(_LatestDataUpdated(data)),
    );

    on<_LatestDataUpdated>(_onLatestDataUpdated);
    on<_ConfigUpdated>(_onConfigUpdated);
  }

  final EnvironmentalRepository _environmentalRepository;
  final DeviceRepository _deviceRepository;
  late final StreamSubscription<EnvironmentalData?> _dataSubscription;
  late final StreamSubscription<DeviceConfig> _configSubscription;

  @override
  Future<void> close() {
    _dataSubscription.cancel();
    _configSubscription.cancel();
    return super.close();
  }

  void _onLatestDataUpdated(_LatestDataUpdated event, Emitter<EnvironmentalDashboardState> emit) {
    emit(state.loaded(latestData: event.data));
  }

  void _onConfigUpdated(_ConfigUpdated event, Emitter<EnvironmentalDashboardState> emit) {
    emit(state.loaded(config: event.config));
  }
}
