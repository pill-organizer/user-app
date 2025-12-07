import 'package:flutter/material.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/schedules/form/presentation/schedule_form_screen.dart';
import '../../features/environmental/history/presentation/environmental_history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String scheduleForm = '/schedule-form';
  static const String environmentalHistory = '/environmental-history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case scheduleForm:
        final scheduleId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ScheduleFormScreen(scheduleId: scheduleId),
        );
      case environmentalHistory:
        return MaterialPageRoute(
          builder: (_) => const EnvironmentalHistoryScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
