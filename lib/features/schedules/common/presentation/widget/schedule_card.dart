import 'package:flutter/material.dart';
import '../../../../../core/config/theme.dart';
import '../../model/schedule.dart';
import '../../../../../core/utils/date_utils.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool isNext;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.isNext = false,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = schedule.enabled;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: isNext
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                )
              : null,
          child: Row(
            children: [
              // Time Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? (isNext
                          ? AppTheme.accentColor
                          : AppTheme.primaryColor.withValues(alpha: 0.1))
                      : AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      schedule.time.split(':')[0],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isEnabled
                                ? (isNext ? Colors.white : AppTheme.primaryColor)
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      ':${schedule.time.split(':')[1]}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isEnabled
                                ? (isNext
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : AppTheme.primaryColor.withValues(alpha: 0.7))
                                : AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            schedule.pillName,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isEnabled
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isNext)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NEXT',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.getReadableDays(schedule.days),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Toggle Switch
              if (onToggle != null)
                Switch(
                  value: schedule.enabled,
                  onChanged: (_) => onToggle?.call(),
                ),
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
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
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

