import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/config/theme.dart';
import '../../common/bloc/schedule_list_bloc.dart';
import '../../common/presentation/widget/schedule_card.dart';

class SchedulesTab extends StatelessWidget {
  const SchedulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleListBloc, ScheduleListState>(
      listener: (context, state) {
        if (state is ScheduleListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
          );
        }
      },
      builder: (context, state) {
        if (state is ScheduleListLoaded) {
          if (state.schedules.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: state.schedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final schedule = state.schedules[index];

              return ScheduleListTile(
                schedule: schedule,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.scheduleForm, arguments: schedule.id);
                },
                onToggle: (enabled) {
                  context.read<ScheduleListBloc>().add(
                    ScheduleListToggleRequested(id: schedule.id!, enabled: enabled),
                  );
                },
                onDelete: () {
                  context.read<ScheduleListBloc>().add(ScheduleListDeleteRequested(schedule.id!));
                },
              );
            },
          );
        }

        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                size: 60,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Schedules Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first pill schedule to get\nreminders for your medications',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.scheduleForm);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
