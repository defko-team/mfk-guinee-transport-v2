import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onClick;
  final Color backgroundColor;
  final String text;

  const CustomElevatedButton({
    super.key,
    required this.onClick,
    required this.backgroundColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: onClick != null ? 2 : 0,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: onClick != null ? AppColors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
