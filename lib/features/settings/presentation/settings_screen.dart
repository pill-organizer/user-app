import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_pill_organizer_app/features/settings/common/repository/device_repository.dart';
import '../../../core/config/theme.dart';
import '../../auth/common/bloc/auth_bloc.dart';
import '../common/bloc/settings_bloc.dart';
import 'pin_settings_screen.dart';
import 'threshold_settings_screen.dart';

/// Route names for settings nested navigation
class SettingsRoutes {
  static const String main = '/';
  static const String pinSettings = '/pin-settings';
  static const String thresholdSettings = '/threshold-settings';
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) =>
          SettingsBloc(repository: context.read<DeviceRepository>())
            ..add(SettingsLoadRequested()),
      child: _SettingsNavigator(),
    );
  }
}

class _SettingsNavigator extends StatefulWidget {
  @override
  State<_SettingsNavigator> createState() => _SettingsNavigatorState();
}

class _SettingsNavigatorState extends State<_SettingsNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_navigatorKey.currentState?.canPop() ?? false) {
          _navigatorKey.currentState?.pop();
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
      child: Navigator(
        key: _navigatorKey,
        initialRoute: SettingsRoutes.main,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case SettingsRoutes.pinSettings:
              return MaterialPageRoute(
                builder: (_) => const PinSettingsScreen(),
              );
            case SettingsRoutes.thresholdSettings:
              return MaterialPageRoute(
                builder: (_) => const ThresholdSettingsScreen(),
              );
            case SettingsRoutes.main:
            default:
              return MaterialPageRoute(
                builder: (_) => const _SettingsMainScreen(),
              );
          }
        },
      ),
    );
  }
}

class _SettingsMainScreen extends StatelessWidget {
  const _SettingsMainScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final config = state is SettingsLoaded
              ? state.config
              : state is SettingsOperationSuccess
              ? state.config
              : state is SettingsError
              ? state.config
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Device Section
              _buildSectionHeader(context, 'Device'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.pin_outlined,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: const Text('PIN Settings'),
                      subtitle: Text(
                        config?.pinHash != null
                            ? 'PIN is configured'
                            : 'No PIN set',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          SettingsRoutes.pinSettings,
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.nfc,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      title: const Text('RFID Tokens'),
                      subtitle: Text(
                        '${config?.rfidTokens.length ?? 0} tokens configured',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showRfidTokensDialog(
                          context,
                          config?.rfidTokens ?? [],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Environment Section
              _buildSectionHeader(context, 'Environment Thresholds'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.thermostat,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      title: const Text('Temperature & Humidity'),
                      subtitle: Text(
                        'Temp: ${config?.tempMin.toInt() ?? 15}°C - ${config?.tempMax.toInt() ?? 25}°C\n'
                        'Humidity: ${config?.humidityMin.toInt() ?? 30}% - ${config?.humidityMax.toInt() ?? 60}%',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          SettingsRoutes.thresholdSettings,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionHeader(context, 'Notifications'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: AppTheme.warningColor,
                        ),
                      ),
                      title: const Text('Buzzer'),
                      subtitle: const Text('Device buzzer for pill reminders'),
                      value: config?.buzzerEnabled ?? true,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                          SettingsToggleBuzzer(value),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Receive alerts on your phone'),
                      value: config?.pushNotificationsEnabled ?? true,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                          SettingsTogglePushNotifications(value),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              _buildSectionHeader(context, 'Account'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      title: const Text('Account'),
                      subtitle: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          if (authState is AuthAuthenticated) {
                            return Text(authState.user.email ?? 'No email');
                          }
                          return const Text('Not signed in');
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ColorScheme.of(
                            context,
                          ).error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.logout,
                          color: ColorScheme.of(context).error,
                        ),
                      ),
                      title: Text(
                        'Sign Out',
                        style: TextStyle(color: ColorScheme.of(context).error),
                      ),
                      onTap: () => _confirmSignOut(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Info
              Center(
                child: Text(
                  'Smart Pill Organizer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Device last synced - ${DateFormat.MMMEd().add_jms().format(config?.lastSync ?? DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showRfidTokensDialog(
    BuildContext context,
    List<String> tokenHashes,
  ) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('RFID Tokens'),
      content: SizedBox(
        width: double.maxFinite,
        child: tokenHashes.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No RFID tokens configured.\nTokens are added from the device.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: tokenHashes.length,
                itemBuilder: (context, index) {
                  final hash = tokenHashes[index];
                  // Show truncated hash for display
                  final displayHash =
                      '${hash.substring(0, 8)}...${hash.substring(hash.length - 8)}';
                  return ListTile(
                    leading: const Icon(Icons.nfc),
                    title: Text('Token ${index + 1}'),
                    subtitle: Text(
                      displayHash,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppTheme.errorColor,
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<SettingsBloc>().add(
                          SettingsRemoveRfidToken(hash),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _confirmSignOut(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}
