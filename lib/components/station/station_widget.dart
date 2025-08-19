import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:url_launcher/url_launcher.dart';

class StationItemWidget extends StatelessWidget {
  final StationModel station;

  const StationItemWidget({super.key, required this.station});

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _openInGoogleMaps(BuildContext context) async {
    try {
      double lat;
      double lng;

      // Check if station has valid coordinates
      if (station.latitude != null &&
          station.longitude != null &&
          station.latitude != 0.0 &&
          station.longitude != 0.0) {
        lat = station.latitude!;
        lng = station.longitude!;
      } else {
        // Use current location as fallback
        final Position position = await _getCurrentPosition();
        lat = position.latitude;
        lng = position.longitude;
      }

      // Create map URL for different platforms
      String url;
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        url = 'comgooglemaps://?q=$lat,$lng';
      } else {
        url = 'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(station.name)})';
      }

      final Uri uri = Uri.parse(url);
      try {
        if (!await launchUrl(uri)) {
          // If native maps app fails, try web URL
          final webUrl = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
          );
          if (!await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
            throw 'Could not launch maps';
          }
        }
      } catch (e) {
        print('Error launching URL: $e');
        // Final fallback to web URL
        final webUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );
        if (!await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch maps';
        }
      }
    } catch (e) {
      if (context.mounted) {
        print('Error opening Google Maps: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.white,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Station image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                "assets/images/gare.png",
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Station details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    station.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.location_on, size: 20),
                    label: const Text(
                      'Voir sur Maps',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => _openInGoogleMaps(context),
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
