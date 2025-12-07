import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/routes.dart';
import 'core/config/theme.dart';
import 'features/auth/common/repository/auth_repository.dart';
import 'features/auth/common/bloc/auth_bloc.dart';
import 'features/settings/common/repository/device_repository.dart';
import 'features/schedules/common/repository/schedule_repository.dart';
import 'features/schedules/common/bloc/schedule_list_bloc.dart';
import 'features/environmental/common/repository/environmental_repository.dart';
import 'features/notifications/common/repository/notification_repository.dart';

class SmartPillOrganizerApp extends StatefulWidget {
  const SmartPillOrganizerApp({super.key});

  @override
  State<SmartPillOrganizerApp> createState() => _SmartPillOrganizerAppState();
}

class _SmartPillOrganizerAppState extends State<SmartPillOrganizerApp> {
  late final NotificationRepository _notificationRepository;

  @override
  void initState() {
    super.initState();
    _notificationRepository = NotificationRepository();
    // Initialize notifications (subscribe to topic, request permissions)
    _notificationRepository.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<DeviceRepository>(create: (_) => DeviceRepository()),
        RepositoryProvider<ScheduleRepository>(create: (_) => ScheduleRepository()),
        RepositoryProvider<EnvironmentalRepository>(create: (_) => EnvironmentalRepository()),
        RepositoryProvider<NotificationRepository>.value(value: _notificationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<ScheduleListBloc>(
            create: (context) => ScheduleListBloc(repository: context.read<ScheduleRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Smart Pill Organizer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: AppRoutes.splash,
          builder: (context, child) {
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                }
              },
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
