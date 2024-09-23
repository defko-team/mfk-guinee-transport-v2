import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/notifications_page.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
            );
          },
        ),
        Positioned(
          top: 5,
          right: 7,
          child: Container(
            height: 12,
            width: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsPage()),
              );
            },
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              height: 12,
              width: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          )
        ],
      ),
    );
  }
}
