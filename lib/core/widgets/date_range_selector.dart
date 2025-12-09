import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

class DateRangeSelector extends StatelessWidget {
  const DateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
    this.label = 'Date Range',
    this.firstDate,
    this.lastDate,
    this.dateFormat,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTimeRange> onDateRangeSelected;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? dateFormat;

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final defaultFirstDate = firstDate ?? now.subtract(const Duration(days: 365));
    final defaultLastDate = lastDate ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: defaultFirstDate,
      lastDate: defaultLastDate,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = dateFormat ?? DateFormat('MMM d, yyyy');
    
    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatter.format(startDate)} – ${formatter.format(endDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

