import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/notification_bell.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

import '../services/notifications_service.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackArrow;
  final String title;
  final List<Widget> actions;
  const BaseAppBar(
      {super.key,
      required this.title,
      this.showBackArrow = true,
      this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.green,
      leading: showBackArrow
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
