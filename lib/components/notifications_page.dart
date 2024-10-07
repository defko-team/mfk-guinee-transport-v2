import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/services/firebase_messaging_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();
  final List<Map<String, dynamic>> notifications = [
    {
      "idNotifications": "notif001",
      "id_user": "user001",
      "dateHeure": DateTime.now().subtract(const Duration(minutes: 15)),
      "context": "Ride Request",
      "message": "You have a new ride request from downtown.",
      "status": false
    },
    {
      "idNotifications": "notif002",
      "id_user": "user002",
      "dateHeure": DateTime.now().subtract(const Duration(hours: 1)),
      "context": "Ride Completed",
      "message": "Your recent ride from the airport has been completed.",
      "status": false
    },
    {
      "idNotifications": "notif003",
      "id_user": "user003",
      "dateHeure": DateTime.now().subtract(const Duration(minutes: 30)),
      "context": "Payment Received",
      "message": "Payment of \$15.75 received for your last ride.",
      "status": false
    },
    {
      "idNotifications": "notif004",
      "id_user": "user004",
      "dateHeure": DateTime.now().subtract(const Duration(minutes: 10)),
      "context": "Ride Request",
      "message": "You have a new ride request from the central station.",
      "status": false
    },
    {
      "idNotifications": "notif005",
      "id_user": "user005",
      "dateHeure": DateTime.now().subtract(const Duration(hours: 2)),
      "context": "Ride Canceled",
      "message": "Your scheduled ride to the city center has been canceled.",
      "status": false
    },
    {
      "idNotifications": "notif006",
      "id_user": "user006",
      "dateHeure": DateTime.now().subtract(const Duration(minutes: 5)),
      "context": "Ride Request",
      "message": "You have a new ride request from uptown.",
      "status": false
    },
    {
      "idNotifications": "notif007",
      "id_user": "user007",
      "dateHeure": DateTime.now().subtract(const Duration(minutes: 45)),
      "context": "Driver Feedback",
      "message": "New feedback received for your recent ride. Rating: 5 stars.",
      "status": false
    },
    {
      "idNotifications": "notif008",
      "id_user": "user008",
      "dateHeure": DateTime.now().subtract(const Duration(minutes: 20)),
      "context": "Ride Completed",
      "message": "Your ride to the hotel has been completed successfully.",
      "status": false
    },
    {
      "idNotifications": "notif009",
      "id_user": "user009",
      "dateHeure": DateTime.now().subtract(const Duration(minutes: 12)),
      "context": "Ride Request",
      "message": "You have a new ride request from the business district.",
      "status": false
    },
    {
      "idNotifications": "notif010",
      "id_user": "user010",
      "dateHeure": DateTime.now().subtract(const Duration(days: 1)),
      "context": "Promotion",
      "message": "You have received a 10% discount on your next ride.",
      "status": false
    }
  ];

  @override
  void initState() {
    super.initState();
    _firebaseMessagingService.initialize();
  }

  void markAsRead(int index) {
    setState(() {
      notifications[index]["status"] = true;
    });
  }

  // Function to show a popup dialog with notification details
  void _showNotificationDialog(
      BuildContext context, Map<String, dynamic> notification) {
    markAsRead(notifications.indexOf(notification));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification['context']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification['message']!),
              const SizedBox(height: 10),
              Text(
                DateFormat('yyyy-MM-dd – kk:mm')
                    .format(notification['dateHeure']!),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                //markAsRead(notifications.indexOf(notification)); // Mark as read on button press
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications',
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        ),
        body: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationTile(
              context: notification["context"]!,
              message: notification["message"]!,
              dateHeure: notification["dateHeure"]!,
              status: notification["status"]!,
              onTap: () => _showNotificationDialog(context, notification),
              idNotification: '',
              idUser: '',
            );
          },
        ));
  }
}

class NotificationTile extends StatelessWidget {
  final String idNotification;
  final String idUser;
  final String context;
  final String message;
  final DateTime dateHeure;
  final bool status;
  final VoidCallback onTap;

  const NotificationTile(
      {super.key,
      required this.context,
      required this.message,
      required this.dateHeure,
      required this.status,
      required this.onTap,
      required this.idNotification,
      required this.idUser});
  @override
  Widget build(BuildContext buildContext) {
    // Format the date and time using intl package
    final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateHeure);
    final bool isNew = !status;
    final Color contextColor = isNew ? Colors.grey[850]! : Colors.grey[300]!;
    final String displayedBody =
        !status ? '${message.substring(0, message.length ~/ 3)}...' : message;
    return Card(
      color: !isNew ? Colors.grey[400] : Colors.grey[80],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.notifications,
            color: isNew ? Colors.blue : Colors.green),
        title:
            Text(context, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayedBody),
            const SizedBox(height: 4),
            Text(formattedDate, style: TextStyle(color: Colors.grey[600]))
          ],
        ),
      ),
    );
  }
}
