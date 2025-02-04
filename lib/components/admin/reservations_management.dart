import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mfk_guinee_transport/components/admin/driver_assignment_dialog.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/services/car_service.dart';
import 'package:mfk_guinee_transport/services/notifications_service.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:mfk_guinee_transport/views/card_reservation.dart';

class AdminReservationsManagementPage extends StatefulWidget {
  const AdminReservationsManagementPage({super.key});

  @override
  State<StatefulWidget> createState() =>
      _AdminReservationsManagementPageState();
}

class _AdminReservationsManagementPageState
    extends State<AdminReservationsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'Tous',
    'En attente',
    'Confirmées',
    'Terminées',
    'Annulées'
  ];
  final Map<String, ReservationStatus> _statusMap = {
    'En attente': ReservationStatus.pending,
    'Confirmées': ReservationStatus.confirmed,
    'Terminées': ReservationStatus.completed,
    'Annulées': ReservationStatus.canceled
  };

  void onOpenModifyReservationBottonSheet({
    required ReservationModel reservation,
  }) async {
    final bool isVtcReservation = reservation.departureLocation != null &&
        reservation.arrivalLocation != null;

    if (isVtcReservation) {
      await showDialog(
        context: context,
        builder: (context) => CarAssignmentDialog(
          onCarSelected: (car) async {
            try {
              // Get driver info if car has assigned driver
              String? driverName;
              String? driverId;
              final driver = await UserService().getUserById(car.idChauffeur!);
              if (driver != null) {
                driverName = '${driver.prenom} ${driver.nom}';
                driverId = driver.idUser;
              }

              await ReservationService().updateReservation(
                reservation.copyWith(
                  status: ReservationStatus.confirmed,
                  driverName: driverName,
                  carName: car.marque,
                ),
              );
              final user = await UserService().getUserById(reservation.userId);
              if (user.fcmToken != null) {
                print('Test notification ${user.fcmToken}');
                final notificationStatus = await NotificationsService()
                    .sendNotification(
                        user.fcmToken!,
                        "Confirmation reservation",
                        "Votre reservation a ete mise a jour");

                if (notificationStatus) {
                  await NotificationsService().createNotification(
                      idUser: reservation.userId,
                      context: "Confirmation de reservation",
                      message:
                          "Votre reservation a ete mise a jour avec succes",
                      status: false,
                      dateHeure: DateTime.now());
                }
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Réservation VTC confirmée'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur de confirmation'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      );
    } else {
      // Regular taxi confirmation (unchanged)
      try {
        await ReservationService().updateReservation(
          reservation.copyWith(status: ReservationStatus.confirmed),
        );
        final user = await UserService().getUserById(reservation.userId);
        if (user.fcmToken != null) {
          print('Test notification');
          final notificationStatus = await NotificationsService()
              .sendNotification(user.fcmToken!, "Confirmation reservation",
                  "Votre reservation a ete mise a jour");

          if (notificationStatus) {
            await NotificationsService().createNotification(
                idUser: reservation.userId,
                context: "Confirmation de reservation",
                message: "Votre reservation a ete mise a jour avec succes",
                status: true,
                dateHeure: DateTime.now());
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation taxi confirmée'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur de confirmation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    final reservationStatus = _statusMap[status];
    switch (reservationStatus) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.completed:
        return Colors.blue;
      case ReservationStatus.canceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReservationsList(
      List<ReservationModel> reservations, String? filterStatus) {
    // Filter reservations by status if needed
    var filteredReservations = filterStatus != null && filterStatus != 'Tous'
        ? reservations
            .where((r) => r.status == _statusMap[filterStatus])
            .toList()
        : reservations;

    // Debug print to check filtering
    print('Filter Status: $filterStatus');
    print('Status Map Value: ${_statusMap[filterStatus]}');
    print('Filtered Count: ${filteredReservations.length}');
    print('Original Count: ${reservations.length}');
    if (filteredReservations.isNotEmpty) {
      print('Sample Status: ${filteredReservations.first.status}');
    }

    if (filteredReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              filterStatus == 'Tous'
                  ? 'Aucune réservation trouvée'
                  : 'Aucune réservation ${filterStatus?.toLowerCase() ?? ''} trouvée',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Group reservations by date
    Map<String, List<ReservationModel>> groupedReservations = {};
    for (var reservation in filteredReservations) {
      String dateKey =
          DateFormat('dd MMMM yyyy', 'fr_FR').format(reservation.startTime);
      if (!groupedReservations.containsKey(dateKey)) {
        groupedReservations[dateKey] = [];
      }
      groupedReservations[dateKey]!.add(reservation);
    }

    // Sort dates in descending order
    var sortedDates = groupedReservations.keys.toList()
      ..sort((a, b) => DateFormat('dd MMMM yyyy', 'fr_FR')
          .parse(b)
          .compareTo(DateFormat('dd MMMM yyyy', 'fr_FR').parse(a)));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String dateKey = sortedDates[index];
        List<ReservationModel> dayReservations = groupedReservations[dateKey]!;

        // Sort reservations by time for each date
        dayReservations.sort((a, b) => b.startTime.compareTo(a.startTime));

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          child: ExpansionTile(
            title: Row(
              children: [
                const Icon(Icons.event, color: AppColors.green),
                const SizedBox(width: 8),
                Text(
                  dateKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${dayReservations.length} réservation${dayReservations.length > 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            children: dayReservations.map((reservation) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: CardReservation(
                  reservationModel: reservation,
                  onOpenModifyReservationBottonSheet:
                      onOpenModifyReservationBottonSheet,
                  isAdmin: true,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: const BaseAppBar(
          title: 'Gestion des réservations', showBackArrow: false),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
            ),
            Expanded(
              child: StreamBuilder<List<ReservationModel>>(
                stream: ReservationService().reservationStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Aucune réservation trouvée'));
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: _tabs.map((String tab) {
                      return _buildReservationsList(
                          snapshot.data!, tab == 'Tous' ? null : tab);
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*

class ModifyReservationForm extends StatefulWidget {
  final ReservationModel reservation;

  const ModifyReservationForm({super.key, required this.reservation});

  @override
  State<StatefulWidget> createState() => _ModifyReservationFormState();
}

class _ModifyReservationFormState extends State<ModifyReservationForm> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _departureLocationController =
      TextEditingController();
  final TextEditingController _departureDateTimeController =
      TextEditingController();
  final TextEditingController _destinationLocationController =
      TextEditingController();
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
    _loadCars();
    _departureLocationController.text =
        widget.reservation.departureLocation ?? '';
    _destinationLocationController.text =
        widget.reservation.arrivalLocation ?? '';
    _departureDateTimeController.text =
        DateFormat('dd/MM/yyyy HH:mm').format(widget.reservation.startTime);
    _tecketPriceController.text =
        widget.reservation.ticketPrice?.toString() ?? '';
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

  Future<void> _loadCars() async {
    try {
      final allCars = await CarService().getAllVoitures();
      setState(() {
        cars = allCars;
      });
    } catch (e) {
      print('Error loading cars: $e');
    }
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));

    if (pickedDate != null && mounted) {
      setState(() {
        _pickedArrivalDate = pickedDate;
        _arrivalDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectArrivalTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedTime != null && _pickedArrivalDate != null && mounted) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _modifyReservation() async {
    if (!mounted) return;

    if (_selectedVoiture == null) {
      _showSnackBar(
          'Pour confirmer la réservation, veuillez enregistrer une voiture.');
      return;
    }

    if (_pickedArrivalDate == null) {
      _showSnackBar(
          'Pour confirmer la réservation, veuillez sélectionner la date et l\'heure d\'arrivée.');
      return;
    }

    final price = int.tryParse(_tecketPriceController.text);
    if (price == null || price <= 0) {
      _showSnackBar(
          'Pour confirmer la réservation, veuillez entrer un prix de ticket valide.');
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
        widget.reservation.driverName =
            await CarService().getDriverNameById(_selectedVoiture!.idChauffeur);
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
        print('Test notification');
        final notificationStatus = await NotificationsService()
            .sendNotification(user.fcmToken!, "Confirmation reservation",
                "Votre reservation a ete mise a jour");

        if (notificationStatus) {
          await NotificationsService().createNotification(
              idUser: widget.reservation.userId,
              context: "Confirmation de reservation",
              message: "Votre reservation a ete mise a jour avec succes",
              status: true,
              dateHeure: DateTime.now());
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
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Text("Modifier le trajet identifiant a mettre",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _arrivalDateController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
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
                    readOnly: true,
                    onTap: () => _selectArrivalDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _arrivalTimeController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
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
*/