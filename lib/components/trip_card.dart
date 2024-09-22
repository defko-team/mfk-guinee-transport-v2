import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class TripCard extends StatelessWidget {
  final String origin;
  final String destination;
  final String vehicleName;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  TripCard({
    required this.origin,
    required this.destination,
    required this.vehicleName,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Ensure vertical alignment
                children: [
                  Icon(Icons.radio_button_checked, color: AppColors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(origin,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.black54),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(destination),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey[300], // Full-width horizontal line
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_car, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(vehicleName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 5), // Space between badge and arrow
                            Icon(Icons.arrow_forward_ios,
                                size: 18, color: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
