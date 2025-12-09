import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/environmental_data.dart';
import '../../../settings/common/model/device_config.dart';
import '../repository/environmental_repository.dart';
import '../../../settings/common/repository/device_repository.dart';

// Events
sealed class EnvironmentalHourlyEvent extends Equatable {
  const EnvironmentalHourlyEvent();

  @override
  List<Object?> get props => [];
}

class EnvironmentalHourlyLoadDateRange extends EnvironmentalHourlyEvent {
  final DateTime startDate;
  final DateTime endDate;

  const EnvironmentalHourlyLoadDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

// State
class EnvironmentalHourlyState extends Equatable {
  const EnvironmentalHourlyState({
    required this.data,
    required this.isLoading,
    required this.config,
    required this.startDate,
    required this.endDate,
    this.errorMessage,
  });

  factory EnvironmentalHourlyState.initial() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return EnvironmentalHourlyState(
      data: const [],
      isLoading: true,
      config: const DeviceConfig(),
      startDate: yesterday,
      endDate: now,
      errorMessage: null,
    );
  }

  final List<EnvironmentalData> data;
  final bool isLoading;
  final DeviceConfig config;
  final DateTime startDate;
  final DateTime endDate;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get hasData => data.isNotEmpty;

  double? get minTemperature =>
      hasData ? data.map((e) => e.temperature).reduce((a, b) => a < b ? a : b) : null;

  double? get maxTemperature =>
      hasData ? data.map((e) => e.temperature).reduce((a, b) => a > b ? a : b) : null;

  double? get avgTemperature =>
      hasData ? data.map((e) => e.temperature).reduce((a, b) => a + b) / data.length : null;

  double? get minHumidity =>
      hasData ? data.map((e) => e.humidity).reduce((a, b) => a < b ? a : b) : null;

  double? get maxHumidity =>
      hasData ? data.map((e) => e.humidity).reduce((a, b) => a > b ? a : b) : null;

  double? get avgHumidity =>
      hasData ? data.map((e) => e.humidity).reduce((a, b) => a + b) / data.length : null;

  EnvironmentalHourlyState copyWith({
    List<EnvironmentalData>? data,
    bool? isLoading,
    DeviceConfig? config,
    DateTime? startDate,
    DateTime? endDate,
    String? errorMessage,
  }) {
    return EnvironmentalHourlyState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      errorMessage: errorMessage,
    );
  }

  EnvironmentalHourlyState loading() => copyWith(isLoading: true, errorMessage: null);

  EnvironmentalHourlyState loaded({
    required List<EnvironmentalData> data,
    required DeviceConfig config,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      copyWith(
        data: data,
        config: config,
        isLoading: false,
        errorMessage: null,
        startDate: startDate,
        endDate: endDate,
      );

  EnvironmentalHourlyState error(String message) =>
      copyWith(isLoading: false, errorMessage: message);

  @override
  List<Object?> get props => [data, isLoading, config, startDate, endDate, errorMessage];
}

// Bloc
class EnvironmentalHourlyBloc
    extends Bloc<EnvironmentalHourlyEvent, EnvironmentalHourlyState> {
  EnvironmentalHourlyBloc({
    required EnvironmentalRepository environmentalRepository,
    required DeviceRepository deviceRepository,
  }) : _environmentalRepository = environmentalRepository,
       _deviceRepository = deviceRepository,
       super(EnvironmentalHourlyState.initial()) {
    on<EnvironmentalHourlyLoadDateRange>(_onLoadDateRange);

    // Load initial data (last 24 hours)
    add(EnvironmentalHourlyLoadDateRange(
      startDate: state.startDate,
      endDate: state.endDate,
    ));
  }

  final EnvironmentalRepository _environmentalRepository;
  final DeviceRepository _deviceRepository;

  Future<void> _onLoadDateRange(
    EnvironmentalHourlyLoadDateRange event,
    Emitter<EnvironmentalHourlyState> emit,
  ) async {
    emit(state.loading());

    try {
      final startTimestamp = event.startDate.copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
      );
      final endTimestamp = event.endDate.copyWith(
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999,
      );

      final data = await _environmentalRepository.getHourlyData(
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
      );

      final config = await _deviceRepository.getConfig();

      emit(state.loaded(
        data: data,
        config: config,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(state.error(e.toString()));
    }
  }
}

