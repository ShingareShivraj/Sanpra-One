import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked_services/stacked_services.dart';
import '../router.router.dart'; // adjust path

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 🔹 KEEP THIS
  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // 🔥 ADD THIS
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);

    // 🔥 Foreground
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // 🔥 Background click
    FirebaseMessaging.onMessageOpenedApp.listen(handleNavigation);

    // 🔥 Killed state
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleNavigation(initialMessage);
    }
  }

  void _handleForeground(RemoteMessage message) {
    final data = message.data;

    // 🔥 Extract manually from data
    final title = data['title'] ?? "New Notification";
    final body = data['body'] ?? "You have an update";

    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_notification',
          autoCancel: true,
          styleInformation: BigPictureStyleInformation(
            DrawableResourceAndroidBitmap('big_image'),
            largeIcon: DrawableResourceAndroidBitmap('ic_notification'),
          ),
        ),
      ),
    );
  }

  void handleNavigation(RemoteMessage message) {
    final data = message.data;

    if (data.isEmpty) return;

    String? type = data['type'];

    if (type == null) return;

    switch (type) {
      case "Visit":
        StackedService.navigatorKey?.currentState
            ?.pushNamed(Routes.visitScreen);
        break;

      case "Lead":
        StackedService.navigatorKey?.currentState
            ?.pushNamed(Routes.leadListScreen);
        break;

      default:
        print("Unknown type: $type");
    }
  }
}