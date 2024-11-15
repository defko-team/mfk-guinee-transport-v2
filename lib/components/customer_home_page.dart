import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/services/car_service.dart';
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

  /* void _openAddVTCTravelBottomSheet({ReservationModel? reservation}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20),
              child: AddVTCTravelForm(reservation: reservation),
            ));
  }*/

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
              print(type);
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
          if (selectedTransportTypeIndex == 1) AddVTCTravelForm()
        ],
      ),
    );
  }
}

class AddVTCTravelForm extends StatefulWidget {
  final ReservationModel? reservation;

  const AddVTCTravelForm({super.key, this.reservation});

  @override
  State<StatefulWidget> createState() => _AddVTCTravelFormState();
}

class _AddVTCTravelFormState extends State<AddVTCTravelForm> {
  final TextEditingController _departureLocationController =
      TextEditingController();
  final TextEditingController _destinationLocationController =
      TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  List<VoitureModel> cars = [];
  VoitureModel? _selectedVoiture;
  bool _isLoading = false;
  DateTime? _pickedDepartureDate;
  DateTime? _pickedArrivalDate;
  bool? aircondtioned = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final allCars = await VoitureService().getAllVoitures();
    setState(() {
      cars = allCars;
    });
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

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 50), // Adjust top margin
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _pickedArrivalDate = pickedDate;
        _arrivalDateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _selectArrivalTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _arrivalTimeController.text = "${pickedTime.hour}:${pickedTime.minute}";
      });
    }
  }

  Future<void> _selectDepartureTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedTime != null) {
      setState(() {
        _departureTimeController.text =
            "${pickedTime.hour}:${pickedTime.minute}";
      });
    }
  }

  void _submitVTCTrajet() async {}

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 10,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 10),
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
                    floatingLabelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18.0),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.5),
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
                    prefixIcon:
                        const Icon(Icons.place, color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10.0)),
                    floatingLabelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18.0),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10.0))),
              ),
              const SizedBox(height: 20),
              Autocomplete<VoitureModel>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<VoitureModel>.empty();
                  }
                  return cars.where((VoitureModel option) {
                    return option.marque
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (VoitureModel option) => option.marque,
                onSelected: (VoitureModel selection) {
                  setState(() {
                    _selectedVoiture = selection;
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  if (_selectedVoiture != null &&
                      textEditingController.text.isEmpty) {
                    textEditingController.text = _selectedVoiture!.marque;
                  }
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                        labelText: 'Voiture',
                        prefixIcon: const Icon(Icons.directions_car_outlined,
                            color: Colors.black, size: 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        hintText: 'Tapez pour rechercher....'),
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<VoitureModel> onSelected,
                    Iterable<VoitureModel> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 80,
                        constraints: const BoxConstraints(maxHeight: 200.0),
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final VoitureModel option =
                                  options.elementAt(index);
                              return ListTile(
                                title: Text(option.marque),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            }),
                      ),
                    ),
                  );
                },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _arrivalDateController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        labelText: 'Date de d\'arrivée',
                        hintText: 'Entrez la date d\'arrivée',
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Colors.black, size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        floatingLabelStyle: const TextStyle(
                            color: Colors.black, fontSize: 18.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectArrivalDate(context),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between fields
                  Expanded(
                    child: TextField(
                      controller: _arrivalTimeController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        labelText: 'Heure d\'arrivée',
                        hintText: 'Entrez l\'heure d\'arrivée',
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(Icons.access_time,
                            color: Colors.black, size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        floatingLabelStyle: const TextStyle(
                            color: Colors.black, fontSize: 18.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectArrivalTime(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Air Conditionnée',
                    style: TextStyle(fontSize: 16.0),
                  ),

                  // Add space between label and switch
                  const SizedBox(width: 10),

                  // Switch widget
                  Switch(
                      activeColor: AppColors.green,
                      inactiveThumbColor: Colors.red,
                      value: aircondtioned!,
                      onChanged: _selectedVoiture != null &&
                              _selectedVoiture!.airConditioner
                          ? (value) {
                              setState(() {
                                aircondtioned = value;
                              });
                            }
                          : null),
                ],
              ),
              const SizedBox(height: 2),
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
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
