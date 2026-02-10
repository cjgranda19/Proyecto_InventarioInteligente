import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission
    await requestPermission();

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Initialize Firebase Messaging
    await _initializeFirebaseMessaging();
  }

  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    
    if (message.notification != null) {
      showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'Notificación',
        body: message.notification!.body ?? '',
      );
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background message: ${message.notification?.title}');
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.notification?.title}');
  }

  static void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'inventory_channel',
      'Inventory Notifications',
      channelDescription: 'Notificaciones del inventario',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'inventory_channel',
      'Inventory Notifications',
      channelDescription: 'Notificaciones del inventario',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Notification for expiring items
  static Future<void> scheduleExpirationNotification({
    required String itemId,
    required String itemName,
    required DateTime expirationDate,
  }) async {
    final notificationDate = expirationDate.subtract(const Duration(days: 3));
    
    if (notificationDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: itemId.hashCode,
        title: 'Item próximo a vencer',
        body: '$itemName vence el ${expirationDate.day}/${expirationDate.month}',
        scheduledDate: notificationDate,
        payload: 'expiration:$itemId',
      );
    }
  }

  // Notification for maintenance
  static Future<void> scheduleMaintenanceNotification({
    required String itemId,
    required String itemName,
    required DateTime maintenanceDate,
  }) async {
    final notificationDate = maintenanceDate.subtract(const Duration(days: 1));
    
    if (notificationDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: (itemId + '_maintenance').hashCode,
        title: 'Mantenimiento próximo',
        body: '$itemName requiere mantenimiento el ${maintenanceDate.day}/${maintenanceDate.month}',
        scheduledDate: notificationDate,
        payload: 'maintenance:$itemId',
      );
    }
  }
}
