import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
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

  Future<void> sendMessage(String fcmToken, String title, String body) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable("sendMessage");
      final response = await callable.call(
          <String, dynamic>{'token': fcmToken, 'title': title, 'body': body});

      if (response.data['success']) {
        print('Message envoye avec succes : ${response.data['response']}');
      } else {
        print('Erreur: ${response.data['error']}');
      }
    } catch (e) {
      print('Erreur lors de l appele de la fonction');
    }
  }
}
