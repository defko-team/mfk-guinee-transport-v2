import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/services/notifications_service.dart';

import 'notification_bell.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String idUser;
  final String avatarUrl;

  const CustomAppBar({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.idUser
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(26, 188, 0, 1),
          ),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 75, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundImage: avatarUrl.startsWith('assets/')
                        ? AssetImage(avatarUrl) as ImageProvider
                        : NetworkImage(avatarUrl),
                    radius: 30,
                  ),
                  const SizedBox(width: 12),
                  // Greeting and name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        "Bonjour 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Notification bell icon
              NotificationBell(unReadNotificationCount: NotificationsService().getUnreadNotificationCountStream(idUser)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(135);
}
