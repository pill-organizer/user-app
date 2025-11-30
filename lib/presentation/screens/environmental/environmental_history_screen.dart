import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/theme.dart';
import '../../../data/models/environmental_data.dart';
import '../../blocs/environmental/environmental_bloc.dart';

class EnvironmentalHistoryScreen extends StatefulWidget {
  const EnvironmentalHistoryScreen({super.key});

  @override
  State<EnvironmentalHistoryScreen> createState() =>
      _EnvironmentalHistoryScreenState();
}

class _EnvironmentalHistoryScreenState extends State<EnvironmentalHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HistoryPeriod _selectedPeriod = HistoryPeriod.day;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<EnvironmentalBloc>().add(EnvironmentalLoadHistory(_selectedPeriod));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPeriodChanged(HistoryPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    context.read<EnvironmentalBloc>().add(EnvironmentalLoadHistory(period));
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
          // Period Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildPeriodChip('24H', HistoryPeriod.day),
                const SizedBox(width: 8),
                _buildPeriodChip('7D', HistoryPeriod.week),
                const SizedBox(width: 8),
                _buildPeriodChip('30D', HistoryPeriod.month),
              ],
            ),
          ),
          // Charts
          Expanded(
            child: BlocBuilder<EnvironmentalBloc, EnvironmentalState>(
              builder: (context, state) {
                if (state is EnvironmentalLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is EnvironmentalHistoryLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTemperatureChart(state),
                      _buildHumidityChart(state),
                    ],
                  );
                }

                if (state is EnvironmentalError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<EnvironmentalBloc>()
                                .add(EnvironmentalLoadHistory(_selectedPeriod));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('Select a period'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, HistoryPeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onPeriodChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(EnvironmentalHistoryLoaded state) {
    return _buildChartContent(
      state: state,
      title: 'Temperature',
      unit: '°C',
      color: AppTheme.accentColor,
      minThreshold: state.config.tempMin,
      maxThreshold: state.config.tempMax,
      getValueHourly: (data) => data.temperature,
      getMinDaily: (data) => data.tempMin,
      getMaxDaily: (data) => data.tempMax,
      getAvgDaily: (data) => data.tempAvg,
    );
  }

  Widget _buildHumidityChart(EnvironmentalHistoryLoaded state) {
    return _buildChartContent(
      state: state,
      title: 'Humidity',
      unit: '%',
      color: AppTheme.secondaryColor,
      minThreshold: state.config.humidityMin,
      maxThreshold: state.config.humidityMax,
      getValueHourly: (data) => data.humidity,
      getMinDaily: (data) => data.humidityMin,
      getMaxDaily: (data) => data.humidityMax,
      getAvgDaily: (data) => data.humidityAvg,
    );
  }

  Widget _buildChartContent({
    required EnvironmentalHistoryLoaded state,
    required String title,
    required String unit,
    required Color color,
    required double minThreshold,
    required double maxThreshold,
    required double Function(EnvironmentalData) getValueHourly,
    required double Function(DailyEnvironmentalData) getMinDaily,
    required double Function(DailyEnvironmentalData) getMaxDaily,
    required double Function(DailyEnvironmentalData) getAvgDaily,
  }) {
    if (state.period == HistoryPeriod.day) {
      // Hourly data
      if (state.hourlyData.isEmpty) {
        return _buildNoDataWidget();
      }

      final spots = state.hourlyData.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          getValueHourly(entry.value),
        );
      }).toList();

      final values = state.hourlyData.map(getValueHourly).toList();
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final avgValue = values.reduce((a, b) => a + b) / values.length;

      return _buildChartWithStats(
        spots: spots,
        color: color,
        unit: unit,
        minValue: minValue,
        maxValue: maxValue,
        avgValue: avgValue,
        minThreshold: minThreshold,
        maxThreshold: maxThreshold,
        xLabels: _getHourlyLabels(state.hourlyData),
      );
    } else {
      // Daily data
      if (state.dailyData.isEmpty) {
        return _buildNoDataWidget();
      }

      final spots = state.dailyData.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          getAvgDaily(entry.value),
        );
      }).toList();

      final avgValues = state.dailyData.map(getAvgDaily).toList();
      final allMin = state.dailyData.map(getMinDaily).reduce((a, b) => a < b ? a : b);
      final allMax = state.dailyData.map(getMaxDaily).reduce((a, b) => a > b ? a : b);
      final avgValue = avgValues.reduce((a, b) => a + b) / avgValues.length;

      return _buildChartWithStats(
        spots: spots,
        color: color,
        unit: unit,
        minValue: allMin,
        maxValue: allMax,
        avgValue: avgValue,
        minThreshold: minThreshold,
        maxThreshold: maxThreshold,
        xLabels: _getDailyLabels(state.dailyData),
      );
    }
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data available for this period',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartWithStats({
    required List<FlSpot> spots,
    required Color color,
    required String unit,
    required double minValue,
    required double maxValue,
    required double avgValue,
    required double minThreshold,
    required double maxThreshold,
    required List<String> xLabels,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Min',
                  '${minValue.toStringAsFixed(1)}$unit',
                  Icons.arrow_downward,
                  minValue < minThreshold ? AppTheme.errorColor : color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avg',
                  '${avgValue.toStringAsFixed(1)}$unit',
                  Icons.horizontal_rule,
                  color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Max',
                  '${maxValue.toStringAsFixed(1)}$unit',
                  Icons.arrow_upward,
                  maxValue > maxThreshold ? AppTheme.errorColor : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Threshold info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Safe range: ${minThreshold.toStringAsFixed(0)}$unit - ${maxThreshold.toStringAsFixed(0)}$unit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: xLabels.length > 10 ? 4 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              xLabels[index],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                  ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: minThreshold,
                      color: AppTheme.warningColor.withValues(alpha: 0.5),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                    HorizontalLine(
                      y: maxThreshold,
                      color: AppTheme.warningColor.withValues(alpha: 0.5),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}$unit',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getHourlyLabels(List<EnvironmentalData> data) {
    return data.map((e) {
      final dt = e.dateTime;
      return '${dt.hour.toString().padLeft(2, '0')}:00';
    }).toList();
  }

  List<String> _getDailyLabels(List<DailyEnvironmentalData> data) {
    return data.map((e) {
      final parts = e.date.split('-');
      return '${parts[1]}/${parts[2]}';
    }).toList();
  }
}

