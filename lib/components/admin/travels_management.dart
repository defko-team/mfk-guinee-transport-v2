import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/helper/utils/utils.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/car_service.dart';
import 'package:mfk_guinee_transport/services/firebase_messaging_service.dart';
import 'package:mfk_guinee_transport/services/station_service.dart';
import 'package:mfk_guinee_transport/services/travel_service.dart';
import 'package:mfk_guinee_transport/views/card_travel.dart';

class AdminTravelsManagementPage extends StatefulWidget {
  const AdminTravelsManagementPage({super.key});

  @override
  State<AdminTravelsManagementPage> createState() =>
      _AdminTravelManagementPageState();
}

class _AdminTravelManagementPageState
    extends State<AdminTravelsManagementPage> {
  void _openAddTravelBottomSheet({TravelModel? travel}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20),
              child: AddTravelForm(travel: travel),
            ));
  }

  String distance(
          StationModel departureStation, StationModel destinationStation) =>
      calculateDistance(departureStation.latitude!, departureStation.longitude!,
              destinationStation.latitude!, destinationStation.longitude!)
          .toStringAsFixed(0);

  String duration(TravelModel travel) =>
      calculateDuration(travel.startTime, travel.arrivalTime!);

  Future<void> _showDeleteConfirmationDialog(String travelId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this travel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Annuler
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmer
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    // Si l'utilisateur a confirmé, supprimer le voyage
    if (confirm == true) {
      _deleteTravel(travelId);
    }
  }

  Future<void> _deleteTravel(String travelId) async {
    bool success = await TravelService()
        .deleteTravel(travelId); // Appelle la méthode de suppression

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Travel successfully deleted')));
      // _loadTravels(); // Recharger les voyages après suppression
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error deleting travel')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: const BaseAppBar(title: 'Trajets', showBackArrow: false),
        body: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 16),
          child: StreamBuilder<List<TravelModel>>(
              stream: TravelService().travelStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No travels found'),
                  );
                }

                // Group travels by itinerary
                Map<String, List<TravelModel>> groupedTravels = {};
                for (var travel in snapshot.data!) {
                  String key = '${travel.departureStation?.id}-${travel.destinationStation?.id}';
                  if (!groupedTravels.containsKey(key)) {
                    groupedTravels[key] = [];
                  }
                  groupedTravels[key]!.add(travel);
                }

                // Sort each group by start time
                groupedTravels.forEach((key, travels) {
                  travels.sort((a, b) => a.startTime.compareTo(b.startTime));
                });

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: groupedTravels.length,
                  itemBuilder: (context, index) {
                    String key = groupedTravels.keys.elementAt(index);
                    List<TravelModel> travels = groupedTravels[key]!;
                    TravelModel firstTravel = travels.first;

                    return ExpansionTile(
                      title: Text(
                        '${firstTravel.departureStation?.name} → ${firstTravel.destinationStation?.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${travels.length} voyages disponibles',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      children: travels.map((travel) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: CardTravel(
                            travelModel: travel,
                            onShowDeleteDialog: _showDeleteConfirmationDialog,
                            onDuration: duration,
                            onDistance: distance,
                            onOpenAddTravelBottomSheet: _openAddTravelBottomSheet,
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openAddTravelBottomSheet(),
          backgroundColor: AppColors.green,
          elevation: 4,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AddTravelForm extends StatefulWidget {
  final TravelModel? travel;

  const AddTravelForm({super.key, this.travel});

  @override
  State<StatefulWidget> createState() => _AddTravelFormState();
}

class _AddTravelFormState extends State<AddTravelForm> {
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  final TextEditingController _tecketPriceController = TextEditingController();
  List<StationModel> stations = [];
  List<VoitureModel> cars = [];
  StationModel? _selectedDepartureStation;
  StationModel? _selectedDestinationStation;
  VoitureModel? _selectedVoiture;
  bool? aircondtioned = false;
  bool _isLoading = false;
  DateTime? _pickedDepartureDate;
  DateTime? _pickedArrivalDate;
  DocumentReference? currentTravelReference;
  bool? isUpdate = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    await _loadCars();
    await _loadStation();
    if (widget.travel != null) {
      _initializeForEdit(widget.travel!);
    }
  }

  Future<void> _loadStation() async {
    final allStations = await StationService().getAllStations();
    setState(() {
      stations = allStations;
    });
  }

  Future<void> _loadCars() async {
    final allCars = await CarService().getAllVoitures();
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

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      setState(() {
        _pickedArrivalDate = pickedDate;
        _arrivalDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectDepartureTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null && _pickedDepartureDate != null) {
      setState(() {
        final selectedDateTime = DateTime(
          _pickedDepartureDate!.year,
          _pickedDepartureDate!.month,
          _pickedDepartureDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _departureTimeController.text =
            DateFormat('HH:mm').format(selectedDateTime);
        _pickedDepartureDate = selectedDateTime;
      });
    }
  }

  Future<void> _selectArrivalTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null && _pickedArrivalDate != null) {
      setState(() {
        final selectedArrivalDateTime = DateTime(
          _pickedArrivalDate!.year,
          _pickedArrivalDate!.month,
          _pickedArrivalDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _arrivalTimeController.text =
            DateFormat('HH:mm').format(selectedArrivalDateTime);
        _pickedArrivalDate = selectedArrivalDateTime;
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

  void _initializeForEdit(TravelModel travel) {
    setState(() {
      isUpdate = true;
      currentTravelReference = travel.travelReference;
      _tecketPriceController.text = travel.ticketPrice.toString();
      _selectedDepartureStation = travel.departureStation!;
      _selectedDestinationStation = travel.destinationStation!;
      if (cars.isNotEmpty) {
        _selectedVoiture = cars.firstWhere(
          (car) => car.marque.toLowerCase() == travel.carName!.toLowerCase(),
        );
      }
      _departureDateController.text =
          DateFormat('yyyy-MM-dd').format(travel.startTime);
      _departureTimeController.text =
          DateFormat('HH:mm').format(travel.startTime);
      _pickedArrivalDate = travel.arrivalTime;
      _pickedDepartureDate = travel.startTime;
      _arrivalDateController.text =
          DateFormat('yyyy-MM-dd').format(travel.arrivalTime!);
      _arrivalTimeController.text =
          DateFormat('HH:mm').format(travel.arrivalTime!);
    });
  }

  void _submitTrajet() async {
    setState(() {
      _isLoading = true;
    });

    final double price = double.parse(_tecketPriceController.text);

    if (price == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez renseigner un prix')));
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final TravelModel travel = TravelModel(
        travelReference: currentTravelReference,
        id: currentTravelReference?.id ?? '',
        departureStationId: _selectedDepartureStation!.stationRef!.id,
        destinationStationId: _selectedDestinationStation!.stationRef!.id,
        startTime: _pickedDepartureDate!,
        arrivalTime: _pickedArrivalDate!,
        ticketPrice: int.parse(_tecketPriceController.text),
        airConditioned: aircondtioned!,
        driverName: await CarService().getDriverNameById(_selectedVoiture!.idChauffeur),
        remainingSeats: _selectedVoiture!.nombreDePlace,
        nombreDePlace: _selectedVoiture!.nombreDePlace,
        carName: _selectedVoiture!.marque);

    if (isUpdate!) {
      print(travel.toString());
      TravelService().updateTravel(travel);
      Navigator.of(context).pop();
    } else {
      TravelService().createTravel(travel);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
        const Text("Ajouter ou Modifier un trajet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Autocomplete<StationModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<StationModel>.empty();
            }
            return stations.where((StationModel station) {
              return station.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (StationModel station) => station.name,
          onSelected: (StationModel selection) {
            setState(() {
              _selectedDepartureStation = selection;
              stations = stations
                  .where((station) =>
                      station.stationRef!.id != selection.stationRef!.id)
                  .toList();
            });
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            if (_selectedDepartureStation != null &&
                textEditingController.text.isEmpty) {
              textEditingController.text = _selectedDepartureStation!.name;
            }
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                  labelText: 'Station de Depart',
                  prefixIcon: const Icon(Icons.my_location_rounded,
                      color: Colors.green, size: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black)),
                  hintText: 'Tapez pour rechercher....'),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<StationModel> onSelected,
              Iterable<StationModel> options) {
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
                        final StationModel option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.name),
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
        Autocomplete<StationModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<StationModel>.empty();
            }
            return stations.where((StationModel station) {
              return station.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (StationModel station) => station.name,
          onSelected: (StationModel selection) {
            setState(() {
              _selectedDestinationStation = selection;
            });
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            if (_selectedDestinationStation != null &&
                textEditingController.text.isEmpty) {
              textEditingController.text = _selectedDestinationStation!.name;
            }
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                  labelText: 'Station de Destination',
                  prefixIcon:
                      const Icon(Icons.place, color: Colors.black, size: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black)),
                  hintText: 'Tapez pour rechercher....'),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<StationModel> onSelected,
              Iterable<StationModel> options) {
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
                        final StationModel option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.name),
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
                        final VoitureModel option = options.elementAt(index);
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
        TextField(
          controller: _tecketPriceController,
          cursorColor: Colors.black,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              labelText: 'Prix trajet',
              hintText: 'Entrez prix du trajet',
              labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
              prefixIcon: const Icon(Icons.price_change_outlined,
                  color: Colors.black, size: 18),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10.0)),
              floatingLabelStyle:
                  const TextStyle(color: Colors.black, fontSize: 18.0),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
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
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10.0)),
                    floatingLabelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18.0),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.5),
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
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(10.0)),
                      floatingLabelStyle:
                          const TextStyle(color: Colors.black, fontSize: 18.0),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10.0))),
                  readOnly: true,
                  onTap: () {
                    if (_pickedDepartureDate != null) {
                      _selectDepartureTime(context);
                    } else {
                      _showSnackBar('Please pick a date first');
                    }
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
                        fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: Colors.black, size: 18),
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
                      labelText: 'heure d\'arrivée',
                      hintText: 'Entrez l\'heure d\'arrivée',
                      labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                      prefixIcon: const Icon(Icons.access_time,
                          color: Colors.black, size: 18),
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
                  readOnly: true,
                  onTap: () {
                    if (_pickedArrivalDate != null) {
                      _selectArrivalTime(context);
                    } else {
                      _showSnackBar('Please pick a date first');
                    }
                  }),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Air Conditionnée',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(width: 10),
            Switch(
                activeColor: AppColors.green,
                inactiveThumbColor: Colors.red,
                value: aircondtioned!,
                onChanged:
                    _selectedVoiture != null && _selectedVoiture!.airConditioner
                        ? (value) {
                            setState(() {
                              aircondtioned = value;
                            });
                          }
                        : null),
          ],
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _submitTrajet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Enregistrer le trajet',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
        const SizedBox(height: 20)
      ],
    ));
  }
}
