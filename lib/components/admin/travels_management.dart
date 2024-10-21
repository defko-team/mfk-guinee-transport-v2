import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/helper/utils/utils.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/car_service.dart';
import 'package:mfk_guinee_transport/services/station_service.dart';
import 'package:mfk_guinee_transport/services/travel_service.dart';

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
      calculateDuration(travel.startTime, travel.arrivalTime);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trajets"),
        backgroundColor: AppColors.green,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: StreamBuilder<List<TravelModel>>(
          stream: TravelService().travelStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 2.5,
                      top: MediaQuery.of(context).size.height / 2.5),
                  child: const CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No travels found'));
            }

            return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, int index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Colors.white,
                    semanticContainer: true,
                    shadowColor: Colors.teal,
                    elevation: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // First Column
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 7),
                                      child: Icon(
                                        Icons.my_location_rounded,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Dash(
                                        direction: Axis.vertical,
                                        length: 28,
                                        dashLength: 4,
                                        dashGap: 3,
                                        dashColor: Colors.grey,
                                        dashThickness: 2,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Icon(
                                        Icons.place,
                                        color: Colors.black,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 1),
                                        child: Text(
                                          '${snapshot.data![index].departureStation?.name}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Container(height: 26),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 1, bottom: 4),
                                        child: Text(
                                          '${snapshot.data![index].destinationStation?.name}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  )),
                              const Padding(
                                  padding: EdgeInsets.only(top: 10, left: 170),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 17, bottom: 11),
                                        child: Icon(
                                          Icons.social_distance,
                                          color: Colors.black,
                                          size: 12,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 17, bottom: 9),
                                        child: Icon(
                                          Icons.access_time_filled,
                                          color: Colors.grey,
                                          size: 12,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 17),
                                        child: Text(
                                          "XOF",
                                          style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, left: 6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 0),
                                        child: Text(
                                          '${distance(snapshot.data![index].departureStation!, snapshot.data![index].destinationStation!)} km',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 0),
                                        child: Text(
                                          duration(snapshot.data![index]),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Text(
                                          '${snapshot.data![index].ticketPrice}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _openAddTravelBottomSheet(
                                          travel: snapshot.data![index]);
                                    },
                                    icon: const Icon(
                                      Icons.edit_square,
                                      size: 14,
                                      color: Colors.black,
                                    ), // Icône à afficher
                                    label: const Text(
                                      "Modifier",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ), // Texte à afficher
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(132, 33),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            40), // Bords arrondis
                                      ),
                                      side: const BorderSide(
                                          width: 1.0,
                                          color: Colors
                                              .black), // Bordure avec couleur
                                    ),
                                  )),
                              Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(snapshot
                                          .data![index].travelReference!.id);
                                    },
                                    icon: const Icon(
                                      Icons.delete_forever_outlined,
                                      size: 14,
                                      color: Colors.red,
                                    ), // Icône à afficher
                                    label: const Text(
                                      "Supprimer",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ), // Texte à afficher
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(132, 33),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            40), // Bords arrondis
                                      ),
                                      side: const BorderSide(
                                          width: 1.0,
                                          color: Colors
                                              .red), // Bordure avec couleur
                                    ),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
      floatingActionButton: AnimatedOpacity(
        opacity: 0.7,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () => _openAddTravelBottomSheet(),
          backgroundColor: AppColors.green,
          shape: const CircleBorder(),
          elevation: 6.0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

    // Load initial data asynchronously
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
          (car) => car.marque.toLowerCase() == travel.carName.toLowerCase(),
        );
      }
      _departureDateController.text =
          DateFormat('yyyy-MM-dd').format(travel.startTime);
      _departureTimeController.text =
          DateFormat('HH:mm').format(travel.startTime);
      _pickedArrivalDate = travel.arrivalTime;
      _pickedDepartureDate = travel.startTime;
      _arrivalDateController.text =
          DateFormat('yyyy-MM-dd').format(travel.arrivalTime);
      _arrivalTimeController.text =
          DateFormat('HH:mm').format(travel.arrivalTime);
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
        departureStationId: _selectedDepartureStation!.stationRef,
        destinationStationId: _selectedDestinationStation!.stationRef,
        //departureLocation: departureLocation,
        // arrivalLocation: arrivalLocation,
        startTime: _pickedDepartureDate!,
        arrivalTime: _pickedArrivalDate!,
        //remainingSeats: remainingSeats,
        ticketPrice: double.parse(_tecketPriceController.text),
        airConditioned: aircondtioned!,
        driverName: 'driverName',
        remainingSeats: 2,
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

            // Add space between label and switch
            const SizedBox(width: 10),

            // Switch widget
            Switch(
              activeColor: AppColors.green,
              inactiveThumbColor: Colors.red,
              value: aircondtioned!,
              onChanged: (value) {
                setState(() {
                  aircondtioned = value;
                });
              },
            ),
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
