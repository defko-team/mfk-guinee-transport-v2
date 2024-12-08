import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
import 'package:mfk_guinee_transport/services/travel_service.dart';
import 'package:mfk_guinee_transport/views/available_cars.dart';

class CustomerHome extends StatefulWidget {
  final String? userId;
  final List<StationModel> locations;

  const CustomerHome(
      {super.key, required this.userId, required this.locations});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int selectedTransportTypeIndex = -1;
  StationModel? selectedDeparture;
  StationModel? selectedArrival;

  void _onSearch() {
    if (selectedDeparture != null &&
        selectedArrival != null &&
        selectedTransportTypeIndex != -1) {
      // Here you can handle the search logic
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (content) => AvailableCarsPage(
              travelSearchInfo: {
                'selectedDeparture': selectedDeparture?.docId,
                'selectedArrival': selectedArrival?.docId,
                'type': selectedTransportTypeIndex,
                'userId': widget.userId,
              },
            ),
          ));
      // You might want to navigate to another page or make a request with the gathered data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool formIsValid = selectedDeparture != null &&
        selectedArrival != null &&
        selectedTransportTypeIndex != -1;
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocationType(onTypeSelected: (type) {
            setState(() {
              selectedTransportTypeIndex = type;
            });
          }),
          if (selectedTransportTypeIndex == 0) ...[
            LocationForm(
              onDepartureChanged: (departure) {
                setState(() {
                  var selectedDepartureFound = widget.locations.where(
                      (location) =>
                          location.name.toLowerCase() ==
                          departure.toLowerCase());

                  selectedDeparture = selectedDepartureFound.isNotEmpty
                      ? selectedDepartureFound.first
                      : null;
                });
              },
              onArrivalChanged: (arrival) {
                setState(() {
                  var selectedArrivalFound = widget.locations.where(
                      (location) =>
                          location.name.toLowerCase() == arrival.toLowerCase());

                  selectedArrival = selectedArrivalFound.isNotEmpty
                      ? selectedArrivalFound.first
                      : null;
                });
              },
              locations: widget.locations,
            ),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomElevatedButton(
                  onClick: formIsValid ? _onSearch : () {},
                  backgroundColor:
                      formIsValid ? AppColors.green : AppColors.grey,
                  text: "Rechercher",
                )),
          ],
          if (selectedTransportTypeIndex == 1)
            AddVTCTravelForm(userId: widget.userId!)
        ],
      ),
    );
  }
}

class AddVTCTravelForm extends StatefulWidget {
  final ReservationModel? reservation;
  final String? userId;
  const AddVTCTravelForm({super.key, this.userId, this.reservation});

  @override
  State<StatefulWidget> createState() => _AddVTCTravelFormState();
}

class _AddVTCTravelFormState extends State<AddVTCTravelForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departureLocationController =
      TextEditingController();
  final TextEditingController _destinationLocationController =
      TextEditingController();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
      margin: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).size.height - 100), // Adjust top margin
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
        departureLocation: _departureLocationController.text,
        arrivalLocation: _destinationLocationController.text,
        startTime: DateTime(
            _pickedDepartureDate!.year,
            _pickedDepartureDate!.month,
            _pickedDepartureDate!.day,
            _pickedDepartureTime!.hour,
            _pickedDepartureTime!.minute),
        remainingSeats: 0, //  vtc user reserve all seats
      );

      setState(() {
        _isLoading = false;
      });

      _formKey.currentState!.reset();
      _departureLocationController.clear();
      _departureDateController.clear();
      _departureTimeController.clear();
      _destinationLocationController.clear();
    }
/*
    */
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
                  TextField(
                    controller: _departureLocationController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        labelText: 'Lieu de Depart',
                        hintText: 'Adresse de depart',
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400),
                        prefixIcon: const Icon(Icons.my_location_rounded,
                            color: Colors.green, size: 18),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        floatingLabelStyle: const TextStyle(
                            color: Colors.black, fontSize: 18.0),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _destinationLocationController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        labelText: 'Destination',
                        hintText: 'Adresse d arrivee',
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400),
                        prefixIcon: const Icon(Icons.place,
                            color: Colors.black, size: 18),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        floatingLabelStyle: const TextStyle(
                            color: Colors.black, fontSize: 18.0),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(10.0))),
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
                      const SizedBox(width: 16), // Space between fields
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
