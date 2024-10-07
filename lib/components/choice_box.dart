import 'package:flutter/material.dart';

class ChoiceBox extends StatelessWidget {
  final String boxTitle;
  final Icon boxIcon;

  const ChoiceBox({super.key, required this.boxTitle, required this.boxIcon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Handle Taxi bokko selection
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              boxIcon,
              const SizedBox(height: 10),
              Text(
                boxTitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
