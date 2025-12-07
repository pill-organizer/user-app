import 'package:flutter/material.dart';
import '../../../../../core/config/theme.dart';
import '../../model/schedule.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const ScheduleCard({super.key, required this.schedule, this.onTap, this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isEnabled = schedule.enabled;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 16,
            children: [
              // Time Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    schedule.time.format(context),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isEnabled ? AppTheme.primaryColor : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            schedule.pillName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          WeekDay.getReadableDays(schedule.days),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Toggle Switch
              if (onToggle != null)
                Switch(value: schedule.enabled, onChanged: (_) => onToggle?.call()),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleListTile extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const ScheduleListTile({
    super.key,
    required this.schedule,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(schedule.id ?? schedule.pillName),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: Text(
              'Are you sure you want to delete the schedule for "${schedule.pillName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      child: ScheduleCard(
        schedule: schedule,
        onTap: onTap,
        onToggle: onToggle != null ? () => onToggle!(!schedule.enabled) : null,
      ),
    );
  }
}
