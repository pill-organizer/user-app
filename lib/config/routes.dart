import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/schedules/schedule_form_screen.dart';
import '../presentation/screens/environmental/environmental_history_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/pin_settings_screen.dart';
import '../presentation/screens/settings/threshold_settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String scheduleForm = '/schedule-form';
  static const String environmentalHistory = '/environmental-history';
  static const String settings = '/settings';
  static const String pinSettings = '/pin-settings';
  static const String thresholdSettings = '/threshold-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
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
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case pinSettings:
        return MaterialPageRoute(
          builder: (_) => const PinSettingsScreen(),
        );
      case thresholdSettings:
        return MaterialPageRoute(
          builder: (_) => const ThresholdSettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

