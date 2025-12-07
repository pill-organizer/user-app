import 'package:equatable/equatable.dart';

enum NotificationType { pillReminder, environmentAlert, system }

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
      type: _parseNotificationType(json['type'] as String?),
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as int,
      delivered: json['delivered'] as bool? ?? false,
    );
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'pill_reminder':
        return NotificationType.pillReminder;
      case 'environment_alert':
        return NotificationType.environmentAlert;
      default:
        return NotificationType.system;
    }
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.pillReminder:
        return 'pill_reminder';
      case NotificationType.environmentAlert:
        return 'environment_alert';
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
      case NotificationType.environmentAlert:
        return 'Environment Alert';
      case NotificationType.system:
        return 'System';
    }
  }

  @override
  List<Object?> get props => [id, type, message, timestamp, delivered];
}
