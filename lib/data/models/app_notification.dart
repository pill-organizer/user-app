import 'package:equatable/equatable.dart';

enum NotificationType {
  pillReminder,
  temperatureAlert,
  humidityAlert,
  accessAlert,
  system,
}

class AppNotification extends Equatable {
  final String? id;
  final NotificationType type;
  final String message;
  final int timestamp;
  final bool delivered;

  const AppNotification({
    this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.delivered = false,
  });

  factory AppNotification.fromJson(String id, Map<dynamic, dynamic> json) {
    return AppNotification(
      id: id,
      type: _parseNotificationType(json['type'] as String),
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as int,
      delivered: json['delivered'] as bool? ?? false,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'pill_reminder':
        return NotificationType.pillReminder;
      case 'temperature_alert':
        return NotificationType.temperatureAlert;
      case 'humidity_alert':
        return NotificationType.humidityAlert;
      case 'access_alert':
        return NotificationType.accessAlert;
      default:
        return NotificationType.system;
    }
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.pillReminder:
        return 'pill_reminder';
      case NotificationType.temperatureAlert:
        return 'temperature_alert';
      case NotificationType.humidityAlert:
        return 'humidity_alert';
      case NotificationType.accessAlert:
        return 'access_alert';
      case NotificationType.system:
        return 'system';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _notificationTypeToString(type),
      'message': message,
      'timestamp': timestamp,
      'delivered': delivered,
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  String get typeDisplayName {
    switch (type) {
      case NotificationType.pillReminder:
        return 'Pill Reminder';
      case NotificationType.temperatureAlert:
        return 'Temperature Alert';
      case NotificationType.humidityAlert:
        return 'Humidity Alert';
      case NotificationType.accessAlert:
        return 'Access Alert';
      case NotificationType.system:
        return 'System';
    }
  }

  @override
  List<Object?> get props => [id, type, message, timestamp, delivered];
}

