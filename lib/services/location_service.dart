import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Method to get the user's current position.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check and request location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Get the current position.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Method to get the address from coordinates.
  Future<String> getCurrentAddress() async {

    var position = await getCurrentLocation();

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        45.19325208729803, 5.712001526367023,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      } else {
        return 'No address available for this location.';
      }
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }

Future<List<String>> fetchAddressSuggestions(String query) async {
  if (query.isEmpty) return [];


  var position = await getCurrentLocation();

  var longitude = 5.712001526367023;
  var latitude = 45.19325208729803;

  var zoom = 10;

  final dio = Dio();
  final url = 'https://nominatim.openstreetmap.org/search';

  // Define the bounding box (viewbox) based on user location
  const double delta = 0.5;
  final minLongitude = longitude - delta;
  final maxLongitude = longitude + delta;
  final minLatitude = latitude - delta;
  final maxLatitude = latitude + delta;

  try {
    final response = await dio.get(
      url,
      queryParameters: {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '5',
        'viewbox': '$minLongitude,$minLatitude,$maxLongitude,$maxLatitude',
        'bounded': '1',
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'zoom': zoom.toString(),
      },
      options: Options(
        headers: {'User-Agent': 'YourAppName/1.0 (your.email@example.com)'},
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((item) {
        var value = item["display_name"] as String;
        return value.replaceRange(75, null, "...");
        }).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  } catch (e) {
    print('Error fetching suggestions: $e');
    return [];
  }
}
}