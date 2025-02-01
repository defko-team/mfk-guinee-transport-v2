import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/booking_confirmation.dart';
import 'package:mfk_guinee_transport/components/vtc/address_autocomplete.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/services/location_service.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';

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
  LocationService locationService = LocationService();
  ReservationService reservationService = ReservationService();
  String currentLocation = '';
  final _formKey = GlobalKey<FormState>();
  late String _departureLocation = '';
  late String _destinationLocation = '';
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
      print("Current location: ${currentLocation!}");
    } catch (e) {
      // Handle errors (e.g., show an error message)
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
    }
  }

  void _submitVTCTraject() async {
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

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return BookingConfirmationDialog(
              book: () async {
                reservationService.createUserReservation(reservation);
                widget.refreshData();
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
                AddressAutocomplete(
                    onLocationChanged: (val) {
                      _departureLocation = val;
                    },
                    hintText: 'Adresse de depart',
                    currentLocation: currentLocation,
                    labelText: 'Lieu de Depart'),
                const SizedBox(height: 24),
                AddressAutocomplete(
                  onLocationChanged: (val) {
                    _destinationLocation = val;
                  },
                  hintText: "Adresse d'arrivée",
                  labelText: 'Destination',
                  isDeparture: false,
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
