import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme.dart';
import '../../../environmental/common/model/environmental_data.dart';
import '../../../settings/common/model/device_config.dart';

class EnvironmentalCard extends StatelessWidget {
  final EnvironmentalData? data;
  final DeviceConfig config;
  final bool isTemperatureAlert;
  final bool isHumidityAlert;
  final VoidCallback? onTap;

  const EnvironmentalCard({
    super.key,
    this.data,
    required this.config,
    this.isTemperatureAlert = false,
    this.isHumidityAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Environment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (data == null)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.sensors_off,
                        size: 48,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No sensor data available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            icon: Icons.thermostat,
                            label: 'Temperature',
                            value: '${data!.temperature.toStringAsFixed(1)}°C',
                            isAlert: isTemperatureAlert,
                            range:
                                '${config.tempMin.toInt()}-${config.tempMax.toInt()}°C',
                          ),
                        ),
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '${data!.humidity.toStringAsFixed(1)}%',
                            isAlert: isHumidityAlert,
                            range:
                                '${config.humidityMin.toInt()}-${config.humidityMax.toInt()}%',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Last updated: ${DateFormat.Hm().format(data!.dateTime)}',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isAlert,
    required String range,
  }) {
    final color = isAlert ? AppTheme.errorColor : AppTheme.secondaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isAlert
            ? Border.all(color: AppTheme.errorColor.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              if (isAlert)
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.errorColor,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Range: $range',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
