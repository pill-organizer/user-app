import 'package:flutter/material.dart';
import '../../../../../core/config/theme.dart';

class ChartStatCard extends StatelessWidget {
  const ChartStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
}

class ChartStatsRow extends StatelessWidget {
  const ChartStatsRow({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.avgValue,
    required this.minThreshold,
    required this.maxThreshold,
    required this.unit,
    required this.color,
  });

  final double minValue;
  final double maxValue;
  final double avgValue;
  final double minThreshold;
  final double maxThreshold;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChartStatCard(
            label: 'Min',
            value: '${minValue.toStringAsFixed(1)}$unit',
            icon: Icons.arrow_downward,
            color: minValue < minThreshold ? AppTheme.errorColor : color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChartStatCard(
            label: 'Avg',
            value: '${avgValue.toStringAsFixed(1)}$unit',
            icon: Icons.horizontal_rule,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChartStatCard(
            label: 'Max',
            value: '${maxValue.toStringAsFixed(1)}$unit',
            icon: Icons.arrow_upward,
            color: maxValue > maxThreshold ? AppTheme.errorColor : color,
          ),
        ),
      ],
    );
  }
}

class DataPointsIndicator extends StatelessWidget {
  const DataPointsIndicator({
    super.key,
    required this.dataCount,
    required this.color,
  });

  final int dataCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$dataCount data points',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SafeRangeIndicator extends StatelessWidget {
  const SafeRangeIndicator({
    super.key,
    required this.minThreshold,
    required this.maxThreshold,
    required this.unit,
  });

  final double minThreshold;
  final double maxThreshold;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Safe range: ${minThreshold.toStringAsFixed(0)}$unit - ${maxThreshold.toStringAsFixed(0)}$unit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

