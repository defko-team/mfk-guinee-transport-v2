import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/notifications_page.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class NotificationBell extends StatelessWidget {
  final Stream<int> unReadNotificationCount;

  const NotificationBell({
    super.key,
    required this.unReadNotificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.black,
              size: 30,
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
              if (result == true) {
                // Handle mark-as-read logic here
              }
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: StreamBuilder<int>(
              stream: unReadNotificationCount,
              initialData: 0,
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                print("Notification count: $count");
                return count > 0
                    ? Badge(count: count)
                    : const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final int count;

  const Badge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
