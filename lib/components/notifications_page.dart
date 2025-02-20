import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/models/notification.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';
import 'package:mfk_guinee_transport/services/firebase_messaging_service.dart';
import 'package:mfk_guinee_transport/services/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId")!;
    bool isAdmin = prefs.getBool("isProviderAuthenticated")!;
    setState(() {
      _userId = isAdmin ? 'admin' : userId;
    });
  }

  void markAsRead(NotificationModel notification) {
    setState(() {
      notification.status = true;
      NotificationsService().updateNotification(notification);
    });
  }

  void _showNotificationDialog(
      BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  notification.context,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm')
                          .format(notification.dateHeure),
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    markAsRead(notification);
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Mark as Read',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const BaseAppBar(
        title: 'Notifications',
        showBackArrow: true,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream:
            NotificationsService().notificationStreamByUserId(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading notifications...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see your notifications here',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                NotificationModel notification = snapshot.data![index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: NotificationTile(
                        context: notification.context,
                        status: notification.status,
                        message: notification.message,
                        dateHeure: notification.dateHeure,
                        onTap: () =>
                            _showNotificationDialog(context, notification),
                        idNotification: '',
                        idUser: '',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
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

  const NotificationTile({
    super.key,
    required this.context,
    required this.message,
    required this.dateHeure,
    required this.onTap,
    required this.idNotification,
    required this.status,
    required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM, HH:mm').format(dateHeure);
    final bool isNew = !status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isNew ? 2 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNew
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isNew ? Icons.notifications_active : Icons.notifications,
            color: isNew ? Colors.blue : Colors.grey,
          ),
        ),
        title: Text(
          this.context,
          style: TextStyle(
            fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (isNew) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
