import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/device_repository.dart';
import '../data/repositories/schedule_repository.dart';
import '../data/repositories/environmental_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/schedule/schedule_bloc.dart';
import '../presentation/blocs/environmental/environmental_bloc.dart';
import '../presentation/blocs/settings/settings_bloc.dart';

class SmartPillOrganizerApp extends StatelessWidget {
  const SmartPillOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<DeviceRepository>(
          create: (_) => DeviceRepository(),
        ),
        RepositoryProvider<ScheduleRepository>(
          create: (_) => ScheduleRepository(),
        ),
        RepositoryProvider<EnvironmentalRepository>(
          create: (_) => EnvironmentalRepository(),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => NotificationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<ScheduleBloc>(
            create: (context) => ScheduleBloc(
              repository: context.read<ScheduleRepository>(),
            ),
          ),
          BlocProvider<EnvironmentalBloc>(
            create: (context) => EnvironmentalBloc(
              environmentalRepository: context.read<EnvironmentalRepository>(),
              deviceRepository: context.read<DeviceRepository>(),
            ),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              repository: context.read<DeviceRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Smart Pill Organizer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: AppRoutes.splash,
        ),
      ),
    );
  }
}

