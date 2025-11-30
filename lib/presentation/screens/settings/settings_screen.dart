import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                        Navigator.pushNamed(context, AppRoutes.pinSettings);
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
                        _showRfidTokensDialog(context, config?.rfidTokens ?? {});
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
                        Navigator.pushNamed(context, AppRoutes.thresholdSettings);
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
                        context
                            .read<SettingsBloc>()
                            .add(SettingsToggleBuzzer(value));
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
                        context
                            .read<SettingsBloc>()
                            .add(SettingsTogglePushNotifications(value));
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
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      title: Text(
                        'Sign Out',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                      onTap: () {
                        _confirmSignOut(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Info
              Center(
                child: Text(
                  'Smart Pill Organizer v0.1.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'IoT Project - 6COSC014C',
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

  void _showRfidTokensDialog(BuildContext context, Map<String, String> tokens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RFID Tokens'),
        content: SizedBox(
          width: double.maxFinite,
          child: tokens.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No RFID tokens configured.\nTokens are added from the device.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: tokens.length,
                  itemBuilder: (context, index) {
                    final name = tokens.keys.elementAt(index);
                    return ListTile(
                      leading: const Icon(Icons.nfc),
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.errorColor,
                        onPressed: () {
                          Navigator.pop(context);
                          context
                              .read<SettingsBloc>()
                              .add(SettingsRemoveRfidToken(name));
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
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
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
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

