import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/config/theme.dart';
import 'chart_stat_card.dart';

class EnvironmentalChart extends StatelessWidget {
  const EnvironmentalChart({
    super.key,
    required this.spots,
    required this.color,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.avgValue,
    required this.minThreshold,
    required this.maxThreshold,
    required this.xLabels,
    required this.dataCount,
  });

  final List<FlSpot> spots;
  final Color color;
  final String unit;
  final double minValue;
  final double maxValue;
  final double avgValue;
  final double minThreshold;
  final double maxThreshold;
  final List<String> xLabels;
  final int dataCount;

  @override
  Widget build(BuildContext context) {
    // Determine interval for x-axis labels based on data count
    final labelInterval = _calculateLabelInterval();
    
    // Show dots only when data count is manageable
    final shouldShowDots = dataCount <= 50;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Row
          ChartStatsRow(
            minValue: minValue,
            maxValue: maxValue,
            avgValue: avgValue,
            minThreshold: minThreshold,
            maxThreshold: maxThreshold,
            unit: unit,
            color: color,
          ),
          const SizedBox(height: 16),
          // Data points count indicator
          DataPointsIndicator(dataCount: dataCount, color: color),
          const SizedBox(height: 12),
          // Safe range indicator
          SafeRangeIndicator(
            minThreshold: minThreshold,
            maxThreshold: maxThreshold,
            unit: unit,
          ),
          const SizedBox(height: 16),
          // Chart
          Expanded(
            child: _buildLineChart(context, labelInterval, shouldShowDots),
          ),
        ],
      ),
    );
  }

  double _calculateLabelInterval() {
    if (dataCount <= 10) return 1;
    if (dataCount <= 30) return 5;
    if (dataCount <= 100) return 10;
    return (dataCount / 10).ceil().toDouble();
  }

  Widget _buildLineChart(BuildContext context, double labelInterval, bool shouldShowDots) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppTheme.dividerColor, strokeWidth: 1);
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
              reservedSize: 40,
              interval: labelInterval,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < xLabels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Transform.rotate(
                      angle: dataCount > 20 ? -0.5 : 0,
                      child: Text(
                        xLabels[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 9,
                        ),
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
            curveSmoothness: 0.3,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: shouldShowDots,
              getDotPainter: (spot, percent, barData, index) {
                final value = spot.y;
                final isOutOfRange = value < minThreshold || value > maxThreshold;
                return FlDotCirclePainter(
                  radius: 4,
                  color: isOutOfRange ? AppTheme.errorColor : color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: minThreshold,
              color: AppTheme.warningColor.withValues(alpha: 0.6),
              strokeWidth: 1.5,
              dashArray: [8, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                labelResolver: (_) => 'Min',
              ),
            ),
            HorizontalLine(
              y: maxThreshold,
              color: AppTheme.warningColor.withValues(alpha: 0.6),
              strokeWidth: 1.5,
              dashArray: [8, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                labelResolver: (_) => 'Max',
              ),
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final label = index < xLabels.length ? xLabels[index] : '';
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}$unit\n$label',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          touchSpotThreshold: 20,
        ),
      ),
    );
  }
}

