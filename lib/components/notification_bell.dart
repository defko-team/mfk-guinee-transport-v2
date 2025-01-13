import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/notifications_page.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class NotificationBell extends StatelessWidget {
  final Stream<int> unReadNotificationCount;
  const NotificationBell({
    super.key, required this.unReadNotificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.white,
      ),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.black,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationsPage()),
              );
            },
          ),
          Positioned(
            top: 4,
            right: 4,
              child: StreamBuilder<int>(
                  stream: unReadNotificationCount,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data! > 0) {
                      print("test ${snapshot.data!}");
                      return Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          snapshot.data!.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  })
            ),
        ],
      ),
    );
  }
}
