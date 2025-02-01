import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/views/home_page.dart';

class CustomSimpleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const CustomSimpleAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.green,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
          // Implement notification action
        },
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Stack(
            children: [
              Icon(Icons.notifications),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
