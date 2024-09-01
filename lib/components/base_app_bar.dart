import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/notification_bell.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const BaseAppBar({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.green,
      actions: const [NotificationBell()],
      title: Text(title, style: const TextStyle( color: AppColors.white),),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop(); // Retour à l'écran précédent
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
