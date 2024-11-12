import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class StationItemWidget extends StatelessWidget {
  final StationModel station;

  StationItemWidget({required this.station});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Image de la station
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                "assets/images/gare.png",
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 30),
            // Détails de la station
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(station.address),
                  SizedBox(height: 5),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.green), // Green background
                      foregroundColor: WidgetStateProperty.all<Color>(
                          AppColors.white), // White text and icon
                    ),
                    icon: Icon(Icons.location_on),
                    label: Text('Localiser sur Maps'),
                    onPressed: () {
                      // Logique pour localiser sur maps
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
