import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_pill_organizer_app/features/schedules/common/model/schedule.dart';
import '../../../core/config/routes.dart';
import '../../../core/config/theme.dart';
import '../../schedules/common/bloc/schedule_list_bloc.dart';
import '../../environmental/common/bloc/environmental_bloc.dart';
import 'widget/environmental_card.dart';
import '../../schedules/common/presentation/widget/schedule_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnvironmentalBloc(
        environmentalRepository: context.read(),
        deviceRepository: context.read(),
      )..add(EnvironmentalLoadLatest()),
      child: Builder(
        builder: (context) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ScheduleListBloc>().add(ScheduleListLoadRequested());
              context.read<EnvironmentalBloc>().add(EnvironmentalLoadLatest());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  _buildGreeting(context),
                  const SizedBox(height: 24),

                  // Environmental Data
                  BlocBuilder<EnvironmentalBloc, EnvironmentalState>(
                    builder: (context, state) {
                      if (state is EnvironmentalLatestLoaded) {
                        return EnvironmentalCard(
                          data: state.latestData,
                          config: state.config,
                          isTemperatureAlert: state.isTemperatureAlert,
                          isHumidityAlert: state.isHumidityAlert,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.environmentalHistory);
                          },
                        );
                      }
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Today's Schedules
                  _buildTodaySchedules(context),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_cloudy;
    } else {
      greeting = 'Good Evening';
      icon = Icons.nights_stay;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.accentColor, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Stay healthy, take your pills on time',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaySchedules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                // Navigate to schedules tab - handled by parent
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<ScheduleListBloc, ScheduleListState>(
          builder: (context, state) {
            if (state is ScheduleListLoaded) {
              if (state.todaySchedules.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: AppTheme.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No pills scheduled for today',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.scheduleForm);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Schedule'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  if (state.nextSchedule != null) ...[
                    _buildNextPillCard(context, state.nextSchedule!),
                    const SizedBox(height: 12),
                  ],
                  ...state.todaySchedules
                      .where((s) => s.id != state.nextSchedule?.id)
                      .take(3)
                      .map(
                        (schedule) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ScheduleCard(
                            schedule: schedule,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.scheduleForm,
                                arguments: schedule.id,
                              );
                            },
                          ),
                        ),
                      ),
                ],
              );
            }
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNextPillCard(BuildContext context, Schedule schedule) {
    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NEXT',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        schedule.time.format(context),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    schedule.pillName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
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
              child: _buildStatCard(
                context,
                icon: Icons.medication_outlined,
                label: 'Total',
                value: totalSchedules.toString(),
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.check_circle_outline,
                label: 'Active',
                value: activeSchedules.toString(),
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
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

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
