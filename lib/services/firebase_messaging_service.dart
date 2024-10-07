import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request Permission on iOS devices
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
          alert: true, badge: true, sound: true);
    }

    if (Platform.isAndroid) {
      await _firebaseMessaging.requestPermission(
          alert: true, badge: true, sound: true);
    }
    // Get the Device token
    String? token = await _firebaseMessaging.getToken();
    print('Device FCM Token: $token');

    // Handle messages while the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received a message while in foreground: ${message.notification!.title}');
      if (message.notification != null) {
        print(
            'Message contains a notifications: ${message.notification!.body}');
      }
    });

    // Handle background messages Requires Firebase Cloud Functions
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }
}
