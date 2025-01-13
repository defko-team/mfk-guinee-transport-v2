import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mfk_guinee_transport/models/notification.dart';
import 'package:http/http.dart' as http;

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> sendNotification(
      String fcmToken, String title, String body) async {
    const url =
        'https://us-central1-defko-mfk-guinee-transport.cloudfunctions.net/sendNotification';
    final headers = {'Content-Type': 'application/json'};
    final bodyData = jsonEncode({
      'fcmToken': fcmToken,
      'title': title,
      'body': body,
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: bodyData);
    if (response.statusCode == 200) {
      print('Notification sent successfully: ${response.body}');
      return true;
    } else {
      print('Failed to send notification: ${response.body}');
      return false;
    }
  }

  Future<List<NotificationModel>> getNotificationsByIdUser(
      String idUser) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Notifications')
          .where('idUser', isEqualTo: idUser)
          .orderBy('dateHeure', descending: true)
          .get();
      List<NotificationModel> notifications = querySnapshot.docs
          .map((doc) =>
              NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return notifications;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notifications: $e');
      }
      return [];
    }
  }

  Stream<int> getUnreadNotificationCountStream(String   idUser) {
    return _firestore
        .collection('Notification')
        .where('idUser', isEqualTo: idUser)
        .where('status', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<List<NotificationModel>> notificationStreamByUserId(String idUser) {
    print("id user from servervice ${idUser}");
    return _firestore
        .collection('Notification')
        .where('id_user', isEqualTo: idUser)
        .orderBy('dateHeure', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot notificationQuerySnapshot) async {
        List<NotificationModel> notifications = [];

        for (QueryDocumentSnapshot notificationDoc in notificationQuerySnapshot.docs) {
          NotificationModel notification = NotificationModel.fromMap(
            notificationDoc.data() as Map<String, dynamic>);
          notification.idNotification = notificationDoc.reference.id;
          notifications.add(notification);
        }
        return notifications;
    });
  }
  // Function to create a new notification
  Future<void> createNotification({
    required String idUser,
    required String context,
    required String message,
    required bool status,
    required DateTime dateHeure,
  }) async {
    try {
      // Create a new document in 'notifications' collection
      await _firestore.collection('Notification').add({
        'id_user': idUser,
        'context': context,
        'message': message,
        'status': status,
        'dateHeure': dateHeure,
      });
      if (kDebugMode) {
        print('Notification created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification: $e');
      }
    }
  }

  Future<void> updateNotification(NotificationModel notification) async {
    await _firestore
        .collection('Notification')
        .doc(notification.idNotification!)
        .update(notification.toMap());
  }

  /* Future<void> deleteNotification(String idNotification) async {
    try {
      await _firestore.collection('notifications').doc(idNotification).delete();
      if (kDebugMode) {
        print('Notification deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
    }
  }*/
}
