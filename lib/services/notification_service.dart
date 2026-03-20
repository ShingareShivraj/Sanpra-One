import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission();

    _messaging.onTokenRefresh.listen((newToken) {
      print("New Token: $newToken");
      _sendToBackend(newToken); // auto update
    });

    FirebaseMessaging.onMessage.listen((message) {
      print("Foreground: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Notification clicked");
    });
  }

  // 🔥 MAIN FUNCTION (only this is called from login)
  Future<void> handleAfterLogin() async {
    try {
      // 1. Get token
      String? token = await _messaging.getToken();
      if (token == null) return;



      // 3. Send to backend
      await _sendToBackend(token);
    } catch (e) {
      print("Error: $e");
    }
  }

  //  Get device ID (you implement your logic here)
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("my_device_id") ?? "Unknown";
  }

  //  Send to backend
  Future<void> _sendToBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();

    String? url = prefs.getString("url");
    String? apiKey = prefs.getString("api_key");
    String? apiSecret = prefs.getString("api_secret");

    if (url == null || apiKey == null || apiSecret == null) return;

    String deviceId = await _getDeviceId();
    if (deviceId == "Unknown") return;

    Map<String, dynamic> headers = {
      "Authorization": "token $apiKey:$apiSecret"
    };

    await Dio().post(
      "$url/api/method/save_fcm_token",
      options: Options(headers: headers),
      data: {
        "token": token,
        "device_id": deviceId,
      },
    );

    print("Token sent to backend");
  }
}