import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/app_notification.dart';
import '../../core/constants/firebase_paths.dart';

class NotificationRepository {
  final FirebaseDatabase _database;
  final FirebaseMessaging _messaging;
  late final DatabaseReference _notificationsRef;

  NotificationRepository({
    FirebaseDatabase? database,
    FirebaseMessaging? messaging,
  })  : _database = database ?? FirebaseDatabase.instance,
        _messaging = messaging ?? FirebaseMessaging.instance {
    _notificationsRef = _database.ref(FirebasePaths.notifications);
  }

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission for iOS
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and save FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _saveFcmToken(String token) async {
    await _database.ref('device/fcmToken').set(token);
  }

  /// Stream of recent notifications
  Stream<List<AppNotification>> get notificationsStream {
    return _notificationsRef
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return <AppNotification>[];
      }
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return AppNotification.fromJson(
          entry.key.toString(),
          entry.value as Map<dynamic, dynamic>,
        );
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  /// Get recent notifications
  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    final snapshot = await _notificationsRef
        .orderByChild('timestamp')
        .limitToLast(limit)
        .get();
    
    if (snapshot.value == null) {
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return AppNotification.fromJson(
        entry.key.toString(),
        entry.value as Map<dynamic, dynamic>,
      );
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Mark notification as delivered
  Future<void> markAsDelivered(String id) async {
    await _notificationsRef.child(id).update({'delivered': true});
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    await _notificationsRef.child(id).remove();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _notificationsRef.remove();
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }
}

