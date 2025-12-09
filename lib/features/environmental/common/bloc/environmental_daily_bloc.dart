import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/environmental_data.dart';
import '../../../settings/common/model/device_config.dart';
import '../repository/environmental_repository.dart';
import '../../../settings/common/repository/device_repository.dart';

// Events
sealed class EnvironmentalDailyEvent extends Equatable {
  const EnvironmentalDailyEvent();

  @override
  List<Object?> get props => [];
}

class EnvironmentalDailyLoadDateRange extends EnvironmentalDailyEvent {
  final DateTime startDate;
  final DateTime endDate;

  const EnvironmentalDailyLoadDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

// State
class EnvironmentalDailyState extends Equatable {
  const EnvironmentalDailyState({
    required this.data,
    required this.isLoading,
    required this.config,
    required this.startDate,
    required this.endDate,
    this.errorMessage,
  });

  factory EnvironmentalDailyState.initial() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return EnvironmentalDailyState(
      data: const [],
      isLoading: true,
      config: const DeviceConfig(),
      startDate: weekAgo,
      endDate: now,
      errorMessage: null,
    );
  }

  final List<DailyEnvironmentalData> data;
  final bool isLoading;
  final DeviceConfig config;
  final DateTime startDate;
  final DateTime endDate;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get hasData => data.isNotEmpty;

  double? get minTemperature =>
      hasData ? data.map((e) => e.tempMin).reduce((a, b) => a < b ? a : b) : null;

  double? get maxTemperature =>
      hasData ? data.map((e) => e.tempMax).reduce((a, b) => a > b ? a : b) : null;

  double? get avgTemperature =>
      hasData ? data.map((e) => e.tempAvg).reduce((a, b) => a + b) / data.length : null;

  double? get minHumidity =>
      hasData ? data.map((e) => e.humidityMin).reduce((a, b) => a < b ? a : b) : null;

  double? get maxHumidity =>
      hasData ? data.map((e) => e.humidityMax).reduce((a, b) => a > b ? a : b) : null;

  double? get avgHumidity =>
      hasData ? data.map((e) => e.humidityAvg).reduce((a, b) => a + b) / data.length : null;

  EnvironmentalDailyState copyWith({
    List<DailyEnvironmentalData>? data,
    bool? isLoading,
    DeviceConfig? config,
    DateTime? startDate,
    DateTime? endDate,
    String? errorMessage,
  }) {
    return EnvironmentalDailyState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      errorMessage: errorMessage,
    );
  }

  EnvironmentalDailyState loading() => copyWith(isLoading: true, errorMessage: null);

  EnvironmentalDailyState loaded({
    required List<DailyEnvironmentalData> data,
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

  EnvironmentalDailyState error(String message) =>
      copyWith(isLoading: false, errorMessage: message);

  @override
  List<Object?> get props => [data, isLoading, config, startDate, endDate, errorMessage];
}

// Bloc
class EnvironmentalDailyBloc
    extends Bloc<EnvironmentalDailyEvent, EnvironmentalDailyState> {
  EnvironmentalDailyBloc({
    required EnvironmentalRepository environmentalRepository,
    required DeviceRepository deviceRepository,
  }) : _environmentalRepository = environmentalRepository,
       _deviceRepository = deviceRepository,
       super(EnvironmentalDailyState.initial()) {
    on<EnvironmentalDailyLoadDateRange>(_onLoadDateRange);

    // Load initial data (last 7 days)
    add(EnvironmentalDailyLoadDateRange(
      startDate: state.startDate,
      endDate: state.endDate,
    ));
  }

  final EnvironmentalRepository _environmentalRepository;
  final DeviceRepository _deviceRepository;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _onLoadDateRange(
    EnvironmentalDailyLoadDateRange event,
    Emitter<EnvironmentalDailyState> emit,
  ) async {
    emit(state.loading());

    try {
      final startDate = _formatDate(event.startDate);
      final endDate = _formatDate(event.endDate);

      final data = await _environmentalRepository.getDailyData(
        startDate: startDate,
        endDate: endDate,
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

