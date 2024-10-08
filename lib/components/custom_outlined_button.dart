import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {

  final VoidCallback onPressed;
  final Color color;
  final String text;

  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(width: 1.0, color: color),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: color),
        ),
      ),
    );
  }
}
