import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/vtc/address_autocomplete.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/services/location_service.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';

class VTCTravelForm extends StatefulWidget {
  final ReservationModel? reservation;
  final String? userId;
  const VTCTravelForm({super.key, this.userId, this.reservation});

  @override
  State<StatefulWidget> createState() => _VTCTravelFormState();
}

class _VTCTravelFormState extends State<VTCTravelForm> {
  LocationService locationService = LocationService();
  ReservationService reservationService = ReservationService();
  List<String> _addressSuggestions = [];
  String currentLocation = '';
  final _formKey = GlobalKey<FormState>();
  late String _departureLocation;
  late String _destinationLocation;
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  bool _isLoading = false;
  DateTime? _pickedDepartureDate;
  TimeOfDay? _pickedDepartureTime;

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      String loc = await locationService.getCurrentAddress();
      setState(() {
        currentLocation = loc;
        _departureLocation = loc;
      });
      print("Current location: " + currentLocation!);
    } catch (e) {
      // Handle errors (e.g., show an error message)
      print('Error getting current location: $e');
    }
  }

  Future<void> _fetchAddressSuggestions(String query) async {
    if (query.isNotEmpty) {
      try {
        List<String> suggestions =
            await locationService.fetchAddressSuggestions(query);
        setState(() {
          _addressSuggestions = suggestions;
        });
        print("Address suggestions: ${suggestions.length}");
      } catch (error) {
        print("Error fetching address suggestions: $error");
      }
    } else {
      setState(() {
        _addressSuggestions = [];
      });
    }
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      setState(() {
        _pickedDepartureDate = pickedDate;
        _departureDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
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
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _submitVTCTrajet() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      final ReservationModel reservation = ReservationModel(
        status: ReservationStatus.pending,
        userId: widget.userId!,
        distance: '',
        departureLocation: _departureLocation,
        arrivalLocation: _destinationLocation,
        startTime: DateTime(
            _pickedDepartureDate!.year,
            _pickedDepartureDate!.month,
            _pickedDepartureDate!.day,
            _pickedDepartureTime!.hour,
            _pickedDepartureTime!.minute),
        remainingSeats: 0,
      );

      reservationService.createUserReservation(reservation);

      setState(() {
        _isLoading = false;
      });

      _formKey.currentState!.reset();
      _departureDateController.clear();
      _departureTimeController.clear();

      setState(() {
        _departureLocation = '';
        _destinationLocation = '';
      });      

    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 10,
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Center(
                      child: Text("Ajouter votre reservation",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 20),
                  AddressAutocomplete(
                      onLocationChanged: (val) {
                        _departureLocation = val;
                      },
                      hintText: 'Adresse de depart',
                      currentLocation: currentLocation,
                      labelText: 'Lieu de Depart'),
                  const SizedBox(height: 20),
                  AddressAutocomplete(
                      onLocationChanged: (val) {
                        _destinationLocation = val;
                      },
                      hintText: "Adresse d'arrivée",
                      labelText: 'Destination',
                      isDeparture: false,
                      ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitVTCTrajet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            padding: const EdgeInsets.only(bottom: 15, top: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Enregistrer la reservation',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                ],
              ),
            )));
  }
}
