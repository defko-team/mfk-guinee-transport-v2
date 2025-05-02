import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mfk_guinee_transport/models/notification.dart';
import 'package:http/http.dart' as http;
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService userService = UserService();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<bool> sendNotification(
      String fcmToken, String title, String body) async {
    const url =
        'https://us-central1-defko-mfk-guinee-transport.cloudfunctions.net/sendNotification';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final bodyData = jsonEncode({
      'fcmToken': fcmToken,
      'title': title,
      'body': body,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: bodyData);
      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
        return true;
      } else {
        print('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  Future<bool> _sendNotificationViaHttp(
      String fcmToken, String title, String body) async {
    const url =
        'https://us-central1-defko-mfk-guinee-transport.cloudfunctions.net/sendNotification';
    final headers = {'Content-Type': 'application/json'};
    final bodyData = jsonEncode({
      'fcmToken': fcmToken,
      'title': title,
      'body': body,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: bodyData);
      if (response.statusCode == 200) {
        print('Notification sent successfully via HTTP: ${response.body}');
        return true;
      } else {
        print('Failed to send notification via HTTP: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification via HTTP: $e');
      return false;
    }
  }

  Future<List<NotificationModel>> getNotificationsByIdUser(
      String idUser) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Notification')
          .where('id_user', isEqualTo: idUser)
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

  Stream<int> getUnreadNotificationCountStream(String idUser) {
    print("id user from stream $idUser");
    if (idUser.isEmpty) return Stream.value(0);
    return _firestore
        .collection('Notification')
        .where('id_user', isEqualTo: idUser)
        .where('status', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<List<NotificationModel>> notificationStreamByUserId(String? idUser) {
    if (idUser == null) return Stream.value([]);
    print("id user from service $idUser");
    return _firestore
        .collection('Notification')
        .where('id_user', isEqualTo: idUser)
        .orderBy('dateHeure', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot notificationQuerySnapshot) async {
      List<NotificationModel> notifications = [];

      for (QueryDocumentSnapshot notificationDoc
          in notificationQuerySnapshot.docs) {
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

  void sendAndCreateNotificationForReservation(ReservationModel res) async {
    try {
      // First refresh admin tokens to ensure they're valid
      await refreshAdminTokens();
      
      // Get fresh admin token
      String? adminFcmToken = await AuthService().getAdminFcmToken();
      
      if (adminFcmToken != null && adminFcmToken.isNotEmpty) {
        UserModel? client = await userService.getUserById(res.userId);
        if (client != null) {
          String clientFullName = "${client.prenom} ${client.nom}";
          String notificationTitle = "Nouvelle Réservation";
          String notificationMessage = "Numéro: ${res.id}\n"
              "Client: $clientFullName\n"
              "Départ: ${res.departureLocation}\n"
              "Arrivée: ${res.arrivalLocation}\n"
              "Statut: ${ReservationModel.getLabelFromStatus(res.status)}\n";

          final notificationStatus = await sendNotification(
              adminFcmToken, notificationTitle, notificationMessage);

          if (notificationStatus) {
            await createNotification(
                idUser: 'admin',
                context: notificationTitle,
                message: notificationMessage,
                status: false,
                dateHeure: DateTime.now());
          } else {
            print("Failed to send notification to admin");
            // Token might be invalid, trigger refresh
            await refreshAdminTokens();
          }
        }
      } else {
        print("No valid admin FCM token found");
        await refreshAdminTokens();
      }
    } catch (e) {
      print("Error in sendAndCreateNotificationForReservation: $e");
    }
  }

  /// Updates the FCM token for a user in the database
  Future<void> updateUserFcmToken(String userId) async {
    try {
      // Get the current FCM token
      String? token = await _messaging.getToken();
      
      if (token == null || token.isEmpty) {
        print("Failed to get FCM token");
        return;
      }
      
      // Update the token in the database
      await _firestore.collection('Users').doc(userId).update({
        'fcmToken': token,
        'tokenLastUpdated': FieldValue.serverTimestamp(),
      });
      
      print("FCM token updated for user $userId: $token");
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }
  
  /// Refreshes all admin FCM tokens
  Future<void> refreshAdminTokens() async {
    try {
      // Query for all admin users
      QuerySnapshot adminUsers = await _firestore
          .collection('Users')
          .where('role', isEqualTo: UserRole.Admin.name)
          .get();
      
      for (var adminDoc in adminUsers.docs) {
        String adminId = adminDoc.id;
        
        // Request a new token from Firebase
        String? newToken = await _messaging.getToken();
        
        if (newToken != null && newToken.isNotEmpty) {
          await _firestore.collection('Users').doc(adminId).update({
            'fcmToken': newToken,
            'tokenLastUpdated': FieldValue.serverTimestamp(),
          });
          
          print("Admin $adminId token refreshed: $newToken");
        }
      }
    } catch (e) {
      print("Error refreshing admin tokens: $e");
    }
  }
  
  /// Handles a failed notification by marking the token as invalid
  Future<void> handleFailedNotification(String token, String error) async {
    if (error.contains("registration-token-not-registered")) {
      try {
        // Find the user with this invalid token
        QuerySnapshot userDocs = await _firestore
            .collection('Users')
            .where('fcmToken', isEqualTo: token)
            .get();
        
        if (userDocs.docs.isNotEmpty) {
          String userId = userDocs.docs.first.id;
          
          // Mark the token as invalid
          await _firestore.collection('Users').doc(userId).update({
            'fcmToken': '',
            'tokenInvalid': true,
            'tokenInvalidReason': error,
            'tokenInvalidTime': FieldValue.serverTimestamp(),
          });
          
          print("Marked token as invalid for user $userId");
        }
      } catch (e) {
        print("Error handling failed notification: $e");
      }
    }
  }
  
  /// Improved sendNotification method with error handling
  Future<bool> sendFcmNotification(String token, String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY', // Replace with your actual server key
        },
        body: jsonEncode({
          'notification': {
            'title': title,
            'body': body,
          },
          'to': token,
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check for failures in the response
        if (responseData['failure'] > 0) {
          List<dynamic> results = responseData['results'];
          for (var result in results) {
            if (result.containsKey('error')) {
              print("FCM Error: ${result['error']}");
              await handleFailedNotification(token, result['error']);
              return false;
            }
          }
        }
        
        return true;
      } else {
        print("FCM request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error sending notification: $e");
      return false;
    }
  }
}
