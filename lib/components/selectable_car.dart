import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class SelectableCarWidget extends StatelessWidget {
  final int index;
  final String carName;
  final String driverName;
  final String departureTime;
  final String price;
  final bool isClimatised;
  final int seats;
  final bool isSelected;
  final Function(bool, int) onSelected;

  const SelectableCarWidget({
    super.key,
    required this.index,
    required this.carName,
    required this.driverName,
    required this.departureTime,
    required this.price,
    required this.isClimatised,
    required this.seats,
    required this.onSelected,
    required this.isSelected,
  });

  void _toggleSelection() {
    onSelected(!isSelected, index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSelection,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                //Create Image component from svg image taxi.svg from assets/images/taxi.svg into component
                // const Icon(Icons.local_taxi, color: Colors.yellow, size: 40),
                // const SizedBox(width: 10),
                Image.asset("assets/images/taxi.jpeg", width: 80, height: 80),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_pin_circle_rounded, color: AppColors.grey),
                      Text(driverName),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.chair_alt, color: AppColors.grey),
                      Text('$seats places'),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(color: AppColors.grey, isClimatised ? Icons.ac_unit: Icons.sunny),
                      Text(isClimatised ? 'Climatisé' : 'Non Climatisé'),
                    ]),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(17)
                  ),
                  child: Text(
                    departureTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
