import 'package:flutter/material.dart';

class LocationType extends StatefulWidget {
  final ValueChanged<int> onTypeSelected;

  const LocationType({super.key, required this.onTypeSelected});

  @override
  State<LocationType> createState() => _LocationTypeState();
}

class _LocationTypeState extends State<LocationType> {
  int selectedType = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedType = selectedType == 0 ? -1 : 0;
                  widget.onTypeSelected(selectedType); // Notify the parent about the change
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: selectedType == 0 ? Colors.green.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedType == 0 ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_taxi, color: Colors.yellow, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Taxi groupé',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedType = selectedType == 1 ? -1 : 1;
                  widget.onTypeSelected(selectedType); // Notify the parent about the change
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: selectedType == 1 ? Colors.green.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedType == 1 ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car, color: Colors.blue, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'VTC',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
