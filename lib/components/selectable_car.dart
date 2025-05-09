import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/travel.dart';

class SelectableCarWidget extends StatelessWidget {
  final TravelModel travel;
  final bool isSelected;
  final int index;
  final Function(int index) onToggled;

  const SelectableCarWidget(
      {super.key,
      required this.travel,
      required this.onToggled,
      required this.isSelected,
      required this.index});

  void _toggleSelection() {
    onToggled(index);
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
                      travel.carName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_pin_circle_rounded,
                          color: AppColors.grey),
                      Text(travel.driverName!),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.chair_alt, color: AppColors.grey),
                      Text('${travel.remainingSeats} places'),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(
                          color: AppColors.grey,
                          travel.airConditioned! ? Icons.ac_unit : Icons.sunny),
                      Text(travel.airConditioned!
                          ? 'Climatisé'
                          : 'Non Climatisé'),
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
                      borderRadius: BorderRadius.circular(17)),
                  child: Text(
                    DateFormat('HH\'h\' mm').format(travel.startTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${travel.ticketPrice} F CFA',
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
