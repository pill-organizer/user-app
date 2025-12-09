import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_pill_organizer_app/features/dashboard/presentation/widget/greeting_header.dart';
import 'package:smart_pill_organizer_app/features/dashboard/presentation/widget/next_pill_card.dart';
import 'package:smart_pill_organizer_app/features/dashboard/presentation/widget/quick_stats.dart';
import 'package:smart_pill_organizer_app/features/home/presentation/home_screen.dart';
import '../../../core/config/routes.dart';
import '../../../core/config/theme.dart';
import '../../schedules/common/bloc/schedule_list_bloc.dart';
import '../../environmental/common/bloc/environmental_dashboard_bloc.dart';
import 'widget/environmental_card.dart';
import '../../schedules/common/presentation/widget/schedule_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnvironmentalDashboardBloc(
        environmentalRepository: context.read(),
        deviceRepository: context.read(),
      ),
      child: Builder(
        builder: (context) {
          return ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              // Greeting
              GreetingHeader(context: context),
              const SizedBox(height: 24),

              // Environmental Data
              BlocBuilder<EnvironmentalDashboardBloc, EnvironmentalDashboardState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (state.hasError) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(state.errorMessage ?? 'Error loading environmental data'),
                        ),
                      ),
                    );
                  }
                  return EnvironmentalCard(
                    data: state.latestData,
                    config: state.config,
                    isTemperatureAlert: state.isTemperatureAlert,
                    isHumidityAlert: state.isHumidityAlert,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.environmentalHistory);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Today's Schedules
              _buildTodaySchedules(context),
              const SizedBox(height: 24),

              // Quick Stats
              const QuickStats(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodaySchedules(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                context.findAncestorStateOfType<HomeScreenState>()?.updateIndex(1);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        BlocBuilder<ScheduleListBloc, ScheduleListState>(
          builder: (context, state) {
            if (state is ScheduleListLoaded) {
              if (state.todayFutureSchedules.isEmpty) {
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
                            'No upcoming pills for today',
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
                  if (state.nextSchedule case final schedule?) ...[
                    NextPillCard(schedule),
                    const SizedBox(height: 12),
                  ],
                  ...state.todayFutureSchedules
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
}
