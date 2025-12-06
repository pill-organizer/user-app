import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/app_notification.dart';
import '../../../../core/constants/firebase_paths.dart';

class NotificationRepository {
  final FirebaseDatabase _database;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  late final DatabaseReference _notificationsRef;

  // FCM Topic - must match cloud function
  static const String fcmTopic = 'smart-pill-organizer';

  NotificationRepository({
    FirebaseDatabase? database,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _database = database ?? FirebaseDatabase.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin() {
    _notificationsRef = _database.ref(FirebasePaths.notifications);
  }

  /// Initialize FCM, request permissions, and subscribe to topic
  Future<void> initialize() async {
    // Request permission for iOS
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      // Subscribe to FCM topic
      await _messaging.subscribeToTopic(fcmTopic);
      
      // Get and save FCM token (for potential direct messages)
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveFcmToken);

      // Initialize local notifications for foreground display
      await _initializeLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'smart_pill_organizer_channel',
      'Smart Pill Organizer',
      description: 'Notifications for pill reminders and environmental alerts',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Smart Pill Organizer',
        body: notification.body ?? '',
        payload: message.data['notificationId'],
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap - navigate to specific screen if needed
    final notificationId = message.data['notificationId'];
    if (notificationId != null) {
      markAsDelivered(notificationId);
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_pill_organizer_channel',
      'Smart Pill Organizer',
      channelDescription: 'Notifications for pill reminders and environmental alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
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

  /// Unsubscribe from topic (e.g., on logout)
  Future<void> unsubscribeFromTopic() async {
    await _messaging.unsubscribeFromTopic(fcmTopic);
  }
}
