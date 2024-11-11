import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class CustomElevatedButton extends StatelessWidget {

  final VoidCallback onClick;
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: AppColors.white),
        ),
      ),
    );
  }
}
