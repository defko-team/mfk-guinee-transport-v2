import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    // Get and save the Device token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', token);
      
      // Save to user document if userId exists
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await _firestore.collection('Users').doc(userId).update({
          'fcmToken': token,
        });
      }
      
      print('Device FCM Token saved: $token');
    }

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((String newToken) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', newToken);
      
      // Update token in user document if userId exists
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await _firestore.collection('Users').doc(userId).update({
          'fcmToken': newToken,
        });
      }
      
      print('FCM Token refreshed: $newToken');
    });

    // Handle messages while the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in foreground: ${message.notification?.title}');
      if (message.notification != null) {
        // Show local notification
        _showLocalNotification(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _showLocalNotification(RemoteMessage message) {
    // TODO: Implement local notification display
    // You can use flutter_local_notifications package here
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    // TODO: Handle background message
  }

  Future<void> sendMessage(String fcmToken, String title, String body) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable("sendNotification");
      final response = await callable.call(
          <String, dynamic>{'token': fcmToken, 'title': title, 'body': body});

      if (response.data['success']) {
        print('Message sent successfully: ${response.data['response']}');
      } else {
        print('Error sending message: ${response.data['error']}');
      }
    } catch (e) {
      print('Error calling Cloud Function: $e');
    }
  }
}
