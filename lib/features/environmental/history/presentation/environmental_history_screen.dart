import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_pill_organizer_app/features/environmental/common/repository/environmental_repository.dart';
import 'package:smart_pill_organizer_app/features/settings/common/repository/device_repository.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/widgets/date_range_selector.dart';
import '../../common/model/environmental_data.dart';
import '../../common/bloc/environmental_hourly_bloc.dart';
import '../../common/bloc/environmental_daily_bloc.dart';
import 'widget/view_type_selector.dart';
import 'widget/chart_state_widgets.dart';
import 'widget/environmental_chart.dart';

class EnvironmentalHistoryScreen extends StatelessWidget {
  const EnvironmentalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EnvironmentalHourlyBloc>(
          create: (context) => EnvironmentalHourlyBloc(
            environmentalRepository: context.read<EnvironmentalRepository>(),
            deviceRepository: context.read<DeviceRepository>(),
          ),
        ),
        BlocProvider<EnvironmentalDailyBloc>(
          create: (context) => EnvironmentalDailyBloc(
            environmentalRepository: context.read<EnvironmentalRepository>(),
            deviceRepository: context.read<DeviceRepository>(),
          ),
        ),
      ],
      child: const _EnvironmentalHistoryScreenContent(),
    );
  }
}

class _EnvironmentalHistoryScreenContent extends StatefulWidget {
  const _EnvironmentalHistoryScreenContent();

  @override
  State<_EnvironmentalHistoryScreenContent> createState() =>
      _EnvironmentalHistoryScreenContentState();
}

class _EnvironmentalHistoryScreenContentState extends State<_EnvironmentalHistoryScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HistoryViewType _selectedViewType = HistoryViewType.hourly;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onViewTypeChanged(HistoryViewType viewType) {
    setState(() {
      _selectedViewType = viewType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environmental History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Temperature'),
            Tab(text: 'Humidity'),
          ],
        ),
      ),
      body: Column(
        children: [
          // View Type Selector & Date Range
          Padding(
            padding: const EdgeInsets.all(16),
            child: ViewTypeSelector(
              selectedViewType: _selectedViewType,
              onViewTypeChanged: _onViewTypeChanged,
            ),
          ),
          // Charts
          Expanded(
            child: _selectedViewType == HistoryViewType.hourly
                ? const _HourlyChartsView()
                : const _DailyChartsView(),
          ),
        ],
      ),
    );
  }
}

// Hourly Charts View
class _HourlyChartsView extends StatelessWidget {
  const _HourlyChartsView();

  void _onHourlyDateRangeSelected(BuildContext context, DateTimeRange range) {
    context.read<EnvironmentalHourlyBloc>().add(
      EnvironmentalHourlyLoadDateRange(startDate: range.start, endDate: range.end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnvironmentalHourlyBloc, EnvironmentalHourlyState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const ChartLoadingWidget();
        }

        if (state.hasError) {
          return ChartErrorWidget(
            message: state.errorMessage!,
            onRetry: () => context.read<EnvironmentalHourlyBloc>().add(
              EnvironmentalHourlyLoadDateRange(startDate: state.startDate, endDate: state.endDate),
            ),
          );
        }

        if (!state.hasData) {
          return const ChartNoDataWidget();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DateRangeSelector(
                startDate: state.startDate,
                endDate: state.endDate,
                onDateRangeSelected: (range) => _onHourlyDateRangeSelected(context, range),
                label: 'Hourly Data Range',
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: context
                    .findAncestorStateOfType<_EnvironmentalHistoryScreenContentState>()
                    ?._tabController,
                children: [
                  _HourlyTemperatureChart(state: state),
                  _HourlyHumidityChart(state: state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HourlyTemperatureChart extends StatelessWidget {
  const _HourlyTemperatureChart({required this.state});

  final EnvironmentalHourlyState state;

  @override
  Widget build(BuildContext context) {
    final spots = state.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperature);
    }).toList();

    return EnvironmentalChart(
      spots: spots,
      color: AppTheme.accentColor,
      unit: '°C',
      minValue: state.minTemperature!,
      maxValue: state.maxTemperature!,
      avgValue: state.avgTemperature!,
      minThreshold: state.config.tempMin,
      maxThreshold: state.config.tempMax,
      xLabels: _getHourlyLabels(state.data),
      dataCount: state.data.length,
    );
  }

  List<String> _getHourlyLabels(List<EnvironmentalData> data) {
    if (data.isEmpty) return [];

    final firstDay = data.first.dateTime.day;
    final lastDay = data.last.dateTime.day;
    final isMultipleDays = firstDay != lastDay;

    if (isMultipleDays) {
      return data.map((e) {
        final dt = e.dateTime;
        return '${dt.month}/${dt.day}\n${dt.hour.toString().padLeft(2, '0')}:00';
      }).toList();
    } else {
      return data.map((e) {
        final dt = e.dateTime;
        return '${dt.hour.toString().padLeft(2, '0')}:00';
      }).toList();
    }
  }
}

class _HourlyHumidityChart extends StatelessWidget {
  const _HourlyHumidityChart({required this.state});

  final EnvironmentalHourlyState state;

  @override
  Widget build(BuildContext context) {
    final spots = state.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.humidity);
    }).toList();

    return EnvironmentalChart(
      spots: spots,
      color: AppTheme.secondaryColor,
      unit: '%',
      minValue: state.minHumidity!,
      maxValue: state.maxHumidity!,
      avgValue: state.avgHumidity!,
      minThreshold: state.config.humidityMin,
      maxThreshold: state.config.humidityMax,
      xLabels: _getHourlyLabels(state.data),
      dataCount: state.data.length,
    );
  }

  List<String> _getHourlyLabels(List<EnvironmentalData> data) {
    if (data.isEmpty) return [];

    final firstDay = data.first.dateTime.day;
    final lastDay = data.last.dateTime.day;
    final isMultipleDays = firstDay != lastDay;

    if (isMultipleDays) {
      return data.map((e) {
        final dt = e.dateTime;
        return '${dt.month}/${dt.day}\n${dt.hour.toString().padLeft(2, '0')}:00';
      }).toList();
    } else {
      return data.map((e) {
        final dt = e.dateTime;
        return '${dt.hour.toString().padLeft(2, '0')}:00';
      }).toList();
    }
  }
}

// Daily Charts View
class _DailyChartsView extends StatelessWidget {
  const _DailyChartsView();

  void _onDailyDateRangeSelected(BuildContext context, DateTimeRange range) {
    context.read<EnvironmentalDailyBloc>().add(
      EnvironmentalDailyLoadDateRange(startDate: range.start, endDate: range.end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnvironmentalDailyBloc, EnvironmentalDailyState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const ChartLoadingWidget();
        }

        if (state.hasError) {
          return ChartErrorWidget(
            message: state.errorMessage!,
            onRetry: () => context.read<EnvironmentalDailyBloc>().add(
              EnvironmentalDailyLoadDateRange(startDate: state.startDate, endDate: state.endDate),
            ),
          );
        }

        if (!state.hasData) {
          return const ChartNoDataWidget();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DateRangeSelector(
                startDate: state.startDate,
                endDate: state.endDate,
                onDateRangeSelected: (range) => _onDailyDateRangeSelected(context, range),
                label: 'Daily Data Range',
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: context
                    .findAncestorStateOfType<_EnvironmentalHistoryScreenContentState>()
                    ?._tabController,
                children: [
                  _DailyTemperatureChart(state: state),
                  _DailyHumidityChart(state: state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DailyTemperatureChart extends StatelessWidget {
  const _DailyTemperatureChart({required this.state});

  final EnvironmentalDailyState state;

  @override
  Widget build(BuildContext context) {
    final spots = state.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.tempAvg);
    }).toList();

    return EnvironmentalChart(
      spots: spots,
      color: AppTheme.accentColor,
      unit: '°C',
      minValue: state.minTemperature!,
      maxValue: state.maxTemperature!,
      avgValue: state.avgTemperature!,
      minThreshold: state.config.tempMin,
      maxThreshold: state.config.tempMax,
      xLabels: _getDailyLabels(state.data),
      dataCount: state.data.length,
    );
  }

  List<String> _getDailyLabels(List<DailyEnvironmentalData> data) {
    return data.map((e) {
      final parts = e.date.split('-');
      return '${parts[1]}/${parts[2]}';
    }).toList();
  }
}

class _DailyHumidityChart extends StatelessWidget {
  const _DailyHumidityChart({required this.state});

  final EnvironmentalDailyState state;

  @override
  Widget build(BuildContext context) {
    final spots = state.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.humidityAvg);
    }).toList();

    return EnvironmentalChart(
      spots: spots,
      color: AppTheme.secondaryColor,
      unit: '%',
      minValue: state.minHumidity!,
      maxValue: state.maxHumidity!,
      avgValue: state.avgHumidity!,
      minThreshold: state.config.humidityMin,
      maxThreshold: state.config.humidityMax,
      xLabels: _getDailyLabels(state.data),
      dataCount: state.data.length,
    );
  }

  List<String> _getDailyLabels(List<DailyEnvironmentalData> data) {
    return data.map((e) {
      final parts = e.date.split('-');
      return '${parts[1]}/${parts[2]}';
    }).toList();
  }
}
