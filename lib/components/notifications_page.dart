import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/components/custom_app_bar.dart';
import 'package:mfk_guinee_transport/models/notification.dart';
import 'package:mfk_guinee_transport/services/firebase_messaging_service.dart';
import 'package:mfk_guinee_transport/services/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();
  String? _userId;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    print("Initialisation");
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    print("user found $userId");
    setState(() {
      _userId = userId;
    });
  }

  void markAsRead(NotificationModel notification) {
    setState(() {
      notification.status = true;
      NotificationsService().updateNotification(notification);
    });
  }

  // Function to show a popup dialog with notification details

  void _showNotificationDialog(
      BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.context),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              const SizedBox(height: 10),
              Text(
                DateFormat('yyyy-MM-dd – kk:mm').format(notification.dateHeure),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                markAsRead(notification); // Mark as read on button press
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
        appBar: const BaseAppBar(
          title: 'Notification',
          showBackArrow: true,
        ),
        body: StreamBuilder<List<NotificationModel>>(
            stream: NotificationsService()
                .notificationStreamByUserId(_userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 2.5,
                        top: MediaQuery.of(context).size.height / 2.5),
                    child: const CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No Notifications found'));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, int index) {
                  NotificationModel notification = snapshot.data![index];
                  return NotificationTile(
                    context: notification.context,
                    status: notification.status,
                    message: notification.message,
                    dateHeure: notification.dateHeure,
                    onTap: () => _showNotificationDialog(context, notification),
                    idNotification: '',
                    idUser: '',
                  );
                },
              );
            }));
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
      required this.onTap,
      required this.idNotification,
      required this.status,
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
