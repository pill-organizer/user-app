import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_pill_organizer_app/core/config/theme.dart';
import 'package:smart_pill_organizer_app/features/dashboard/presentation/widget/stat_card.dart';
import 'package:smart_pill_organizer_app/features/schedules/common/bloc/schedule_list_bloc.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleListBloc, ScheduleListState>(
      builder: (context, state) {
        int todayTotal = 0;
        int upcoming = 0;
        int taken = 0;

        if (state is ScheduleListLoaded) {
          todayTotal = state.allTodaySchedulesCount;
          upcoming = state.todayFutureSchedulesCount;
          taken = state.alreadyTakenSchedulesCount;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Overview", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle,
                    label: 'Taken',
                    value: taken.toString(),
                    color: AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    icon: Icons.schedule,
                    label: 'Upcoming',
                    value: upcoming.toString(),
                    color: AppTheme.accentColor,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_today,
                    label: 'Today',
                    value: todayTotal.toString(),
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
