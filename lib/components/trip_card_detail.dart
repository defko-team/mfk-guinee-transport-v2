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

  const TripDetailCard({
    super.key,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.time,
    required this.price,
    required this.onCancel,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Driver Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      Uri.encodeFull(userAvatarUrl).replaceAll('%20', '+'),
                    ),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to first letter of name if image fails to load
                      return;
                    },
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.toLowerCase().contains('annul')
                          ? Colors.red[50]
                          : status.toLowerCase().contains('termin')
                              ? Colors.green[50]
                              : status.toLowerCase().contains('confirm')
                                  ? Colors.blue[50]
                                  : Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: status.toLowerCase().contains('annul')
                            ? Colors.red
                            : status.toLowerCase().contains('termin')
                                ? Colors.green
                                : status.toLowerCase().contains('confirm')
                                    ? Colors.blue
                                    : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Trip Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Location Details
                  _buildLocationInfo(
                    icon: Icons.my_location_rounded,
                    title: 'Point de départ',
                    location: origin,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                  ),
                  _buildLocationInfo(
                    icon: Icons.place,
                    title: 'Destination',
                    location: destination,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 24),

                  // Trip Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.access_time,
                          title: 'Heure',
                          value: time,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.route,
                          title: 'Distance',
                          value: distance,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.attach_money,
                          title: 'Prix',
                          value: price,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.message_outlined, size: 20),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Fermer'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required String title,
    required String location,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
