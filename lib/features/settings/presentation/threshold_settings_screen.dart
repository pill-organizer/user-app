import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/theme.dart';
import '../common/bloc/settings_bloc.dart';

class ThresholdSettingsScreen extends StatefulWidget {
  const ThresholdSettingsScreen({super.key});

  @override
  State<ThresholdSettingsScreen> createState() =>
      _ThresholdSettingsScreenState();
}

class _ThresholdSettingsScreenState extends State<ThresholdSettingsScreen> {
  double _tempMin = 15;
  double _tempMax = 25;
  double _humidityMin = 30;
  double _humidityMax = 60;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) {
      setState(() {
        _tempMin = state.config.tempMin;
        _tempMax = state.config.tempMax;
        _humidityMin = state.config.humidityMin;
        _humidityMax = state.config.humidityMax;
        _isLoading = false;
      });
    } else if (state is SettingsOperationSuccess) {
      setState(() {
        _tempMin = state.config.tempMin;
        _tempMax = state.config.tempMax;
        _humidityMin = state.config.humidityMin;
        _humidityMax = state.config.humidityMax;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _saveSettings() {
    context.read<SettingsBloc>().add(
          SettingsUpdateTemperatureThresholds(min: _tempMin, max: _tempMax),
        );
    context.read<SettingsBloc>().add(
          SettingsUpdateHumidityThresholds(
            min: _humidityMin,
            max: _humidityMax,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Thresholds'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Set the safe temperature and humidity ranges for storing your medications. '
                              'You\'ll receive alerts when values go outside these ranges.',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Temperature Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.thermostat,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Temperature Range',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildValueDisplay(
                                context,
                                'Minimum',
                                '${_tempMin.toInt()}°C',
                                AppTheme.secondaryColor,
                              ),
                              _buildValueDisplay(
                                context,
                                'Maximum',
                                '${_tempMax.toInt()}°C',
                                AppTheme.accentColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RangeSlider(
                            values: RangeValues(_tempMin, _tempMax),
                            min: -20,
                            max: 50,
                            divisions: 70,
                            labels: RangeLabels(
                              '${_tempMin.toInt()}°C',
                              '${_tempMax.toInt()}°C',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _tempMin = values.start;
                                _tempMax = values.end;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '-20°C',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              Text(
                                '50°C',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Humidity Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Humidity Range',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildValueDisplay(
                                context,
                                'Minimum',
                                '${_humidityMin.toInt()}%',
                                AppTheme.secondaryColor,
                              ),
                              _buildValueDisplay(
                                context,
                                'Maximum',
                                '${_humidityMax.toInt()}%',
                                AppTheme.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RangeSlider(
                            values: RangeValues(_humidityMin, _humidityMax),
                            min: 0,
                            max: 100,
                            divisions: 100,
                            labels: RangeLabels(
                              '${_humidityMin.toInt()}%',
                              '${_humidityMax.toInt()}%',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _humidityMin = values.start;
                                _humidityMax = values.end;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              Text(
                                '100%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recommended Values
                  Card(
                    color: AppTheme.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended Values',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Temperature: 15°C - 25°C (59°F - 77°F)\n'
                            '• Humidity: 30% - 60%\n\n'
                            'Most medications should be stored at room temperature, '
                            'away from excessive heat and moisture.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Thresholds'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildValueDisplay(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

