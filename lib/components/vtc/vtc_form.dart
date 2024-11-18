import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/vtc/address_autocomplete.dart';
import 'package:mfk_guinee_transport/helper/utils/line_painter.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/services/location_service.dart';

class VtcForm extends StatefulWidget {
  final ValueChanged<String> onDepartureChanged;
  final ValueChanged<String> onArrivalChanged;
  final List<StationModel> locations;

  const VtcForm({
    super.key,
    required this.onDepartureChanged,
    required this.onArrivalChanged,
    required this.locations,
  });

  @override
  State<VtcForm> createState() => _VtcFormState();
}

class _VtcFormState extends State<VtcForm> {
  TextEditingController departureController = TextEditingController();
  TextEditingController arrivalController = TextEditingController();
  LocationService locationService = LocationService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      String currentLocation =
          await locationService.getCurrentAddress();

      print("Current location: " + currentLocation);

      widget.onDepartureChanged(currentLocation);
    } catch (e) {
      // Handle errors (e.g., show an error message)
      print('Error getting current location: $e');
    }
  }

  Future<List<String>> _fetchAddressSuggestions(String query) async {
    var suggestions = await locationService.fetchAddressSuggestions(query);

    suggestions.forEach((add) {
      print("Address: " + add + "\n");
    });

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.01,
        screenHeight * 0.01,
        screenWidth * 0.01,
        screenHeight * 0.02,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015,
          horizontal: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.my_location,
                        color: Colors.green, size: 24),
                    SizedBox(
                      height: 40,
                      child: CustomPaint(
                        painter: DottedLinePainter(),
                      ),
                    ),
                    const Icon(Icons.location_on,
                        color: Colors.green, size: 24),
                  ],
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    children: [
                      AddressAutocomplete(
                        showCurrentLocation: true,
                        hintText: 'VTC Départ',
                        onLocationChanged: widget.onDepartureChanged,
                      ),
                      AddressAutocomplete(
                        hintText: 'VTC Arrivée',
                        onLocationChanged: widget.onArrivalChanged,
                        showCurrentLocation: true,
                      ),
                    ],
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
