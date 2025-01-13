import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/car_service.dart';
import 'package:mfk_guinee_transport/services/notifications_service.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:mfk_guinee_transport/views/card_reservation.dart';

class AdminReservationsManagementPage extends StatefulWidget {
  const AdminReservationsManagementPage({super.key});

  @override
  State<StatefulWidget> createState() => _AdminReservationsManagementPageState();
}

class _AdminReservationsManagementPageState extends State<AdminReservationsManagementPage> {
  void _openModifyReservationBottomSheet({required ReservationModel reservation}) {
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
          top: 20
        ),
        child: ModifyReservationForm(reservation: reservation),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Réservations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          elevation: 0,
          backgroundColor: AppColors.green,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: 16
          ),
          child: StreamBuilder<List<ReservationModel>>(
            stream: ReservationService().reservationStream(),
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
                  child: Text('No Reservations found'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CardReservation(
                      reservationModel: snapshot.data![index],
                      onOpenModifyReservationBottonSheet: _openModifyReservationBottomSheet
                    ),
                  );
                }
              );
            }
          ),
        ),
      ),
    );
  }
}

class ModifyReservationForm extends StatefulWidget {
  final ReservationModel reservation;

  const ModifyReservationForm({super.key, required this.reservation});

  @override
  State<StatefulWidget> createState() => _ModifyReservationFormState();
}

class _ModifyReservationFormState extends State<ModifyReservationForm> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _departureLocationController = TextEditingController();
  final TextEditingController _departureDateTimeController = TextEditingController();
  final TextEditingController _destinationLocationController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  final TextEditingController _tecketPriceController = TextEditingController();
  List<VoitureModel> cars = [];
  VoitureModel? _selectedVoiture;
  bool? aircondtioned = false;
  bool _isLoading = false;
  DateTime? _pickedArrivalDate;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _departureLocationController.text = widget.reservation.departureLocation ?? '';
    _destinationLocationController.text = widget.reservation.arrivalLocation ?? '';
    _departureDateTimeController.text = DateFormat('dd/MM/yyyy HH:mm')
        .format(widget.reservation.startTime);
    _tecketPriceController.text = widget.reservation.ticketPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _departureLocationController.dispose();
    _departureDateTimeController.dispose();
    _destinationLocationController.dispose();
    _arrivalDateController.dispose();
    _arrivalTimeController.dispose();
    _tecketPriceController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      final allCars = await VoitureService().getAllVoitures();
      if (mounted) {
        setState(() {
          cars = allCars;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading cars: ${e.toString()}');
      }
    }
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101)
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _pickedArrivalDate = pickedDate;
        _arrivalDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectArrivalTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now()
    );
    
    if (pickedTime != null && _pickedArrivalDate != null && mounted) {
      setState(() {
        final selectedArrivalDateTime = DateTime(
          _pickedArrivalDate!.year,
          _pickedArrivalDate!.month,
          _pickedArrivalDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _arrivalTimeController.text = DateFormat('HH:mm').format(selectedArrivalDateTime);
        _pickedArrivalDate = selectedArrivalDateTime;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 100
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _modifyReservation() async {
    if (!mounted) return;
    
    if (_selectedVoiture == null) {
      _showSnackBar('Please select a car');
      return;
    }

    if (_pickedArrivalDate == null) {
      _showSnackBar('Please select arrival date and time');
      return;
    }

    final price = double.tryParse(_tecketPriceController.text);
    if (price == null || price <= 0) {
      _showSnackBar('Please enter a valid ticket price');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      widget.reservation.arrivalTime = _pickedArrivalDate;
      widget.reservation.carName = _selectedVoiture?.marque;
      widget.reservation.ticketPrice = price;
      
      if (_selectedVoiture?.idChauffeur != null) {
        widget.reservation.driverName = await VoitureService()
            .getDriverNameById(_selectedVoiture!.idChauffeur);
      }
      
      widget.reservation.airConditioned = aircondtioned ?? false;

      if (widget.reservation.arrivalTime != null &&
          widget.reservation.carName != null &&
          widget.reservation.carName!.isNotEmpty &&
          widget.reservation.ticketPrice != null &&
          widget.reservation.ticketPrice! > 0) {
        widget.reservation.status = ReservationStatus.pending;
      }

      await ReservationService().updateReservation(widget.reservation);

      final user = await UserService().getUserById(widget.reservation.userId);
      
      if (user.fcmToken != null) {
        final notificationStatus = await NotificationsService().sendNotification(
          user.fcmToken!,
          "Confirmation reservation",
          "Votre reservation a ete mise a jour"
        );

        if (notificationStatus) {
          await NotificationsService().createNotification(
            idUser: widget.reservation.userId,
            context: "Confirmation de reservation",
            message: "Votre reservation a ete mise a jour avec succes",
            status: true,
            dateHeure: DateTime.now()
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Reservation updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error updating reservation: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
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
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const Text("Modifier le trajet identifiant a mettre",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              enabled: false,
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
                  fontWeight: FontWeight.w400
                ),
                prefixIcon: const Icon(Icons.my_location_rounded,
                  color: Colors.green, size: 18
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 18.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0)
                )
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              enabled: false,
              controller: _destinationLocationController,
              cursorColor: Colors.black,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0.0),
                labelText: 'Destination',
                hintText: 'Adresse de destination',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400
                ),
                prefixIcon: const Icon(Icons.my_location_rounded,
                  color: Colors.green, size: 18
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 18.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0)
                )
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              enabled: false,
              controller: _departureDateTimeController,
              cursorColor: Colors.black,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0.0),
                labelText: 'Date et heure de depart',
                hintText: 'Adresse de depart',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400
                ),
                prefixIcon: const Icon(Icons.my_location_rounded,
                  color: Colors.green, size: 18
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 18.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0)
                )
              ),
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
                VoidCallback onFieldSubmitted
              ) {
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
                      color: Colors.black, size: 18
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black)
                    ),
                    hintText: 'Tapez pour rechercher....'
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<VoitureModel> onSelected,
                Iterable<VoitureModel> options
              ) {
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
                        }
                      ),
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
                  fontWeight: FontWeight.w400
                ),
                prefixIcon: const Icon(Icons.price_change_outlined,
                  color: Colors.black, size: 18
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 18.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0)
                )
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _arrivalDateController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      labelText: 'Date d\'arrivée',
                      hintText: 'Entrez la date',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                        size: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectArrivalDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _arrivalTimeController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      labelText: 'Heure d\'arrivée',
                      hintText: 'Entrez l\'heure',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                      prefixIcon: const Icon(
                        Icons.access_time,
                        color: Colors.black,
                        size: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    readOnly: true,
                    onTap: () {
                      if (_pickedArrivalDate != null) {
                        _selectArrivalTime(context);
                      } else {
                        _showSnackBar('Please pick a date first');
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Air Conditionnée',
                    style: TextStyle(fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  activeColor: AppColors.green,
                  inactiveThumbColor: Colors.red,
                  value: aircondtioned ?? false,
                  onChanged: _selectedVoiture?.airConditioner == true
                    ? (value) {
                        setState(() {
                          aircondtioned = value;
                        });
                      }
                    : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                onPressed: _modifyReservation,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
