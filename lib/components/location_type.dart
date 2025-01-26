import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class LocationType extends StatefulWidget {
  final ValueChanged<int> onTypeSelected;
  final int selectedType;

  const LocationType(
      {super.key, required this.onTypeSelected, this.selectedType = 0});

  @override
  State<LocationType> createState() => _LocationTypeState();
}

class _LocationTypeState extends State<LocationType> {
  late int selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;
  }

  @override
  void didUpdateWidget(covariant LocationType oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure the state is updated if the selectedType prop changes.
    if (widget.selectedType != oldWidget.selectedType) {
      setState(() {
        selectedType = widget.selectedType;
      });
    }
  }

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
                  selectedType = 0;
                  widget.onTypeSelected(
                      selectedType); // Notify the parent about the change
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color:
                      selectedType == 0 ? Colors.green.shade50 : Colors.white,
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
                    Icon(Icons.local_taxi, color: AppColors.yellow, size: 40),
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
                  selectedType = 1;
                  widget.onTypeSelected(
                      selectedType); // Notify the parent about the change
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color:
                      selectedType == 1 ? Colors.green.shade50 : Colors.white,
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
