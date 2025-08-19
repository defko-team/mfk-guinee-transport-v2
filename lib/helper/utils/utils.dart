import 'dart:io';
import 'dart:math';

Future<bool> isConnectedToInternet() async {
  try {
    final result = await InternetAddress.lookup('www.google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
  return false;
}

String calculateDuration(DateTime departureDateTime, DateTime arrivalDateTime) {
  Duration duration = arrivalDateTime.difference(departureDateTime);

  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);

  return '$hours h:$minutes min';
}

double calculateDistance(
    double departureStationLate,
    double departureStationLong,
    double destinationStationLate,
    double destinationStationLong) {
  const R = 6378.0; // rayon de la terre
  // Conversion des coordonnees en radians
  double departureStationLateRad = departureStationLate * pi / 180;
  double departureStationLongRad = departureStationLong * pi / 180;
  double destinationStationLateRad = destinationStationLate * pi / 180;
  double destinationStationLongRad = destinationStationLong * pi / 180;

  // Differences des coordonnees
  double deltaLat = (departureStationLateRad - destinationStationLateRad).abs();
  double deltaLong =
      (departureStationLongRad - destinationStationLongRad).abs();

  double a = pow(sin(deltaLat / 2), 2) +
      cos(departureStationLateRad) *
          cos(destinationStationLateRad) *
          pow(sin(deltaLong / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Distance en km
  double distance = R * c;

  return distance;
}
