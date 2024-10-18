import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class TripDetailCard extends StatelessWidget {
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String origin;
  final String destination;
  final String distance;
  final String time;
  final String price;
  final String status;
  final VoidCallback onCancel;

  const TripDetailCard(
      {super.key,
      required this.userName,
      required this.userAvatarUrl,
      required this.rating,
      required this.origin,
      required this.destination,
      required this.distance,
      required this.time,
      required this.price,
      required this.onCancel,
      required this.status});

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        NetworkImage(userAvatarUrl), // Load user's avatar
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(rating.toString(),
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.message_outlined),
                        onPressed: () {}, // Handle message action
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () {}, // Handle call action
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.radio_button_checked, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(origin,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_pin, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(destination),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TripInfoItem(label: 'DISTANCE', value: distance),
                  TripInfoItem(label: 'TEMPS', value: time),
                  TripInfoItem(label: 'PRICE', value: price),
                ],
              ),
              const SizedBox(height: 20),
            ]),
            if (status != "completed")
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomElevatedButton(
                    onSearch: onCancel,
                    backgroundColor: AppColors.green,
                    text: "Annuler Reservation",
                  )),
          ],
        ),
      ),
    );
  }
}

class TripInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const TripInfoItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
