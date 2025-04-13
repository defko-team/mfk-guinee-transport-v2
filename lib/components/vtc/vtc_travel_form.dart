import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/booking_confirmation.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/services/location_service.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../services/auth_service.dart';
import '../../services/notifications_service.dart';

class VTCTravelForm extends StatefulWidget {
  final ReservationModel? reservation;
  final String? userId;
  final Function refreshData;

  const VTCTravelForm(
      {super.key, this.userId, this.reservation, required this.refreshData});

  @override
  State<StatefulWidget> createState() => _VTCTravelFormState();
}

class _VTCTravelFormState extends State<VTCTravelForm> {
  final String _geoCodeApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  final List<String> COUNTRIES = ['gn', 'sn', 'fr'];
  LocationService locationService = LocationService();
  ReservationService reservationService = ReservationService();
  String currentLocation = '';
  final _formKey = GlobalKey<FormState>();
  late String _departureLocation = '';
  late String _destinationLocation = '';
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  bool _isLoading = false;
  DateTime? _pickedDepartureDate;
  TimeOfDay? _pickedDepartureTime;
  LatLng? _departureCoords;
  LatLng? _destinationCoords;
  String _distance = '';
  DateTime? _arrivalTime;
  int _durationSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      String loc = await locationService.getCurrentAddressV2();
      setState(() {
        currentLocation = loc;
        _departureLocation = loc;
        _departureController.text = loc;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Show time picker after date is selected
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            DateTime.now().add(const Duration(minutes: 1))),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Only update if selected time is in the future
        if (combinedDateTime.isAfter(currentTime)) {
          setState(() {
            _pickedDepartureDate = pickedDate;
            _pickedDepartureTime = pickedTime;
            _departureDateController.text =
                DateFormat('dd-MM-yyyy').format(combinedDateTime);
            _departureTimeController.text =
                DateFormat('HH:mm').format(combinedDateTime);
          });
          _updateArrivalTime(); // Calculate arrival time when duration changes
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner une heure future'),
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDepartureTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedTime != null) {
      setState(() {
        _pickedDepartureTime = pickedTime;
        _departureTimeController.text =
            "${pickedTime.hour}:${pickedTime.minute}";
      });
      _updateArrivalTime(); // Calculate arrival time when duration changes
    }
  }

  Future<void> _calculateDistanceAndTime() async {
    if (_departureCoords == null || _destinationCoords == null) return;

    try {
      final routeDetails = await locationService.getRouteDetails(
        origin: _departureCoords!,
        destination: _destinationCoords!,
      );

      setState(() {
        _distance = routeDetails['distance'];
        _durationSeconds = routeDetails['durationSeconds'];
        _updateArrivalTime(); // Calculate arrival time when duration changes
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating route: ${e.toString()}')),
      );
    }
  }

  void _updateArrivalTime() {
    if (_pickedDepartureDate == null || _pickedDepartureTime == null) return;

    final departureDateTime = DateTime(
      _pickedDepartureDate!.year,
      _pickedDepartureDate!.month,
      _pickedDepartureDate!.day,
      _pickedDepartureTime!.hour,
      _pickedDepartureTime!.minute,
    );

    setState(() {
      _arrivalTime = departureDateTime.add(
        Duration(seconds: _durationSeconds),
      );
    });
  }

  void _submitVTCTraject() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      final ReservationModel reservation = ReservationModel(
          status: ReservationStatus.pending,
          userId: widget.userId!,
          distance: _distance,
          departureLocation: _departureLocation,
          arrivalLocation: _destinationLocation,
          startTime: DateTime(
              _pickedDepartureDate!.year,
              _pickedDepartureDate!.month,
              _pickedDepartureDate!.day,
              _pickedDepartureTime!.hour,
              _pickedDepartureTime!.minute),
          remainingSeats: 0,
          arrivalTime: _arrivalTime);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return BookingConfirmationDialog(
              book: () async {
                ReservationModel res =
                    await reservationService.saveReservation(reservation);
                widget.refreshData();
                NotificationsService()
                    .sendAndCreateNotificationForReservation(res);
              },
              displayText: "Votre réservation a été créée avec succès.");
        },
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid = _departureLocation.isNotEmpty &&
        _destinationLocation.isNotEmpty &&
        _pickedDepartureDate != null &&
        _pickedDepartureTime != null;
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "Ajouter votre réservation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                GooglePlaceAutoCompleteTextField(
                  textEditingController: _departureController,
                  googleAPIKey: _geoCodeApiKey,
                  inputDecoration: InputDecoration(
                    hintText: 'Adresse de depart',
                    labelText: 'Lieu de Depart',
                    contentPadding: const EdgeInsets.all(0.0),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(Icons.location_on,
                        color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  debounceTime: 800,
                  countries: COUNTRIES,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    setState(() {
                      _departureCoords = LatLng(
                          double.parse(prediction.lat ?? '0.0'),
                          double.parse(prediction.lng ?? '0.0'));
                    });
                    _calculateDistanceAndTime();
                  },
                  itemClick: (prediction) {
                    setState(() {
                      _departureLocation = prediction.description ?? '';
                      _departureController.text = prediction.description ?? '';
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Destination Location Autocomplete
                GooglePlaceAutoCompleteTextField(
                  textEditingController: _destinationController,
                  googleAPIKey: _geoCodeApiKey,
                  inputDecoration: InputDecoration(
                    hintText: "Adresse d'arrivée",
                    labelText: 'Destination',
                    contentPadding: const EdgeInsets.all(0.0),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(Icons.location_on,
                        color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  debounceTime: 800,
                  countries: COUNTRIES,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    setState(() {
                      _destinationCoords = LatLng(
                          double.parse(prediction.lat ?? '0.0'),
                          double.parse(prediction.lng ?? '0.0'));
                    });
                    _calculateDistanceAndTime();
                  },
                  itemClick: (prediction) {
                    setState(() {
                      _destinationLocation = prediction.description ?? '';
                      _destinationController.text =
                          prediction.description ?? '';
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _departureDateController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0.0),
                            labelText: 'Date de départ',
                            hintText: 'Entrez la date de départ',
                            labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.black, size: 18),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10.0)),
                            floatingLabelStyle: const TextStyle(
                                color: Colors.black, fontSize: 18.0),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 1.5),
                                borderRadius: BorderRadius.circular(10.0))),
                        readOnly: true,
                        onTap: () => _selectDepartureDate(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                          controller: _departureTimeController,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              labelText: 'heure de départ',
                              hintText: 'Entrez l\'heure de départ',
                              labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                              prefixIcon: const Icon(Icons.access_time,
                                  color: Colors.black, size: 18),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(10.0)),
                              floatingLabelStyle: const TextStyle(
                                  color: Colors.black, fontSize: 18.0),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(10.0))),
                          readOnly: true,
                          onTap: () {
                            _selectDepartureTime(context);
                          }),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_departureDateController.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Départ prévu: ${_departureDateController.text} ${_departureTimeController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arrivée estimée: ${_arrivalTime != null ? DateFormat('dd-MM-yyyy HH:mm').format(_arrivalTime!) : 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                    if (_distance.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Distance: $_distance',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isFormValid ? _submitVTCTraject : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isFormValid ? AppColors.green : AppColors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Enregistrer la réservation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
