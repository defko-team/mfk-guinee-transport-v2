import 'package:flutter/material.dart';

class TripDetailCard extends StatelessWidget {
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String origin;
  final String destination;
  final String distance;
  final String time;
  final String price;
  final VoidCallback onCancel;

  TripDetailCard({
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.time,
    required this.price,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      NetworkImage(userAvatarUrl), // Load user's avatar
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(rating.toString(), style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.message_outlined),
                      onPressed: () {}, // Handle message action
                    ),
                    IconButton(
                      icon: Icon(Icons.phone),
                      onPressed: () {}, // Handle call action
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.radio_button_checked, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(origin,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.black54),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(destination),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey[300],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TripInfoItem(label: 'DISTANCE', value: distance),
                TripInfoItem(label: 'TEMPS', value: time),
                TripInfoItem(label: 'PRICE', value: price),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Center(
                child:
                    Text('Annuler Reservation', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TripInfoItem extends StatelessWidget {
  final String label;
  final String value;

  TripInfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
