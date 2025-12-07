import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_pill_organizer_app/core/config/theme.dart';
import 'package:smart_pill_organizer_app/features/dashboard/presentation/widget/stat_card.dart';
import 'package:smart_pill_organizer_app/features/schedules/common/bloc/schedule_list_bloc.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleListBloc, ScheduleListState>(
      builder: (context, state) {
        int totalSchedules = 0;
        int activeSchedules = 0;
        int todayCount = 0;

        if (state is ScheduleListLoaded) {
          totalSchedules = state.schedules.length;
          activeSchedules = state.schedules.where((s) => s.enabled).length;
          todayCount = state.todaySchedules.length;
        }

        return Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.medication_outlined,
                label: 'Total',
                value: totalSchedules.toString(),
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.check_circle_outline,
                label: 'Active',
                value: activeSchedules.toString(),
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.today_outlined,
                label: 'Today',
                value: todayCount.toString(),
                color: AppTheme.accentColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
