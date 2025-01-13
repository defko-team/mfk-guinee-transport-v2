import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/components/trip_card.dart';
import 'package:mfk_guinee_transport/components/trip_card_detail.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/history_service.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:mfk_guinee_transport/views/card_reservation.dart';

class HistoryPage extends StatefulWidget {
  final String title;
  const HistoryPage({super.key, this.title = "Reservations"});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ReservationModel> reservations = [];
  UserService userService = new UserService();
  DateTime? selectedDate;
  String? selectedStatus;
  String? selectedVehicle;
  String? userId;
  List<UserModel> users = [];
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    fetchReservations();
    fetUsers();
  }

  Future<void> fetUsers() async {
    currentUser = await userService.getCurrentUser();

    List<UserModel> fetchedUsers = await UserService().getAllUsers();
    if (mounted) {
      setState(() {
        users = fetchedUsers;
      });
    }
  }

  // Fetch reservations using ReservationService

  void fetchReservations() async {
    List<ReservationModel> fetchedReservations = await HistoriqueService()
        .fetchReservation(
            startTimeFilter: selectedDate,
            statusFilter: selectedStatus,
            carNameFilter: selectedVehicle,
            userId: userId);
    setState(() {
      reservations = fetchedReservations;
      userId = userId;
    });
  }

  void onFiltersChanged(
      DateTime? date, String? status, String? vehicle, String? selectedId) {
    setState(() {
      selectedDate = date;
      selectedStatus = status;
      selectedVehicle = vehicle;
      userId = selectedId;
    });
    fetchReservations(); // Fetch reservations with the new filters
  }

  // Helper function to get color from status
  static Color _getColorFromStatus(String status) {
    switch (status) {
      case 'completed':
        return AppColors.green;
      case 'canceled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _openModifyReservationBottomSheet(
      {required ReservationModel reservation}) {
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
              child: const Text(''),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          title: widget.title,
          showBackArrow: false,
        ),
        body: // Within your page's content
            DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.black, // Active tab color
                unselectedLabelColor: Colors.grey, // Inactive tab color
                // Add this if your background is light
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2, color: Colors.black),
                ),
                tabs: [
                  Tab(text: 'A venir'),
                  Tab(text: 'Historique'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // First tab content
                    Column(
                      children: [
                        FilterBar(
                            onFiltersChanged: onFiltersChanged,
                            users: users,
                            isAdmin:
                                currentUser?.role?.toLowerCase() == 'admin'),
                        Expanded(
                            child: SingleChildScrollView(
                          child: StreamBuilder<List<ReservationModel>>(
                              stream: ReservationService()
                                  .userReservationStream(userId ?? ""),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Padding(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.5),
                                      child: const CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('No Reservations found'));
                                }
                                return ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, int index) {
                                      return CardReservation(
                                          reservationModel:
                                              snapshot.data![index],
                                          onOpenModifyReservationBottonSheet:
                                              _openModifyReservationBottomSheet);
                                    });
                              }),
                        ))
                      ],
                    ),
                    // Second tab content
                    Column(
                      children: [
                        FilterBar(
                            onFiltersChanged: onFiltersChanged,
                            users: users,
                            isAdmin:
                                currentUser?.role?.toLowerCase() == 'admin'),
                        Expanded(
                            child: ListView.builder(
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            final reservation = reservations[index];
                            return TripCard(
                              origin: reservation.departureLocation ?? "",
                              destination: reservation.destinationStation ?? "",
                              vehicleName: reservation.carName ?? "",
                              status: reservation.status.name,
                              statusColor:
                                  _getColorFromStatus(reservation.status.name),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (BuildContext context) {
                                    return DraggableScrollableSheet(
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return TripDetailCard(
                                          userName: reservation.driverName!,
                                          userAvatarUrl:
                                              "https://st3.depositphotos.com/15648834/17930/v/1600/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg",
                                          rating: 4.9,
                                          origin:
                                              reservation.departureLocation ??
                                                  "",
                                          destination:
                                              reservation.destinationStation ??
                                                  "",
                                          distance:
                                              "${reservation.distance} km",
                                          time: "25 min", // Example data
                                          price:
                                              "${reservation.ticketPrice} CFA",
                                          status: reservation.status.name,
                                          onCancel: () {
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class FilterBar extends StatefulWidget {
  final Function(DateTime?, String?, String?, String?) onFiltersChanged;
  final List<UserModel> users;
  final bool isAdmin;

  const FilterBar(
      {Key? key,
      required this.onFiltersChanged,
      required this.users,
      required this.isAdmin})
      : super(key: key);

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  DateTime? selectedDate;
  String? selectedStatus;
  String? selectedVehicle;
  String? userId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // _buildDatePicker(context),
          // const SizedBox(width: 16),
          _buildStatusDropdown(),
          const SizedBox(width: 16), // Horizontal space
          _buildVehicleDropdown(),
          const SizedBox(width: 16), // Horizontal space
          if (widget.isAdmin) _buildUsersDropdown(),
          if (_isAnyFilterSet()) // Conditionally render the IconButton
            IconButton(
              icon: const Icon(Icons.clear), // "X" icon to clear filters
              onPressed: _clearFilters, // Clear filters when pressed
            ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            selectedDate = picked;
          });
          widget.onFiltersChanged(
              selectedDate, selectedStatus, selectedVehicle, userId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
              : 'Date',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      hint: const Text('Status'),
      value: selectedStatus,
      items:
          ['confirmed', 'pending', 'completed', 'canceled'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedStatus = newValue;
        });
        widget.onFiltersChanged(
            selectedDate, selectedStatus, selectedVehicle, userId);
      },
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButton<String>(
      hint: const Text('Véhicule'),
      value: selectedVehicle,
      items: ['Voiture X1', 'Voiture X2'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedVehicle = newValue;
        });
        widget.onFiltersChanged(
            selectedDate, selectedStatus, selectedVehicle, userId);
      },
    );
  }

  Widget _buildUsersDropdown() {
    return Expanded(
      child: Autocomplete<UserModel>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return widget.users;
          }
          return widget.users.where((UserModel user) {
            final fullName = '${user.prenom} ${user.nom}'.toLowerCase();
            return fullName.contains(textEditingValue.text.toLowerCase());
          });
        },
        displayStringForOption: (UserModel user) =>
            '${user.prenom} ${user.nom}',
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Utilisateurs',
              suffixIcon: textEditingController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded),
                      onPressed: () {
                        textEditingController.clear(); // Clear the text field
                        setState(() {
                          userId = null; // Reset the selected product
                        });
                        widget.onFiltersChanged(selectedDate, selectedStatus,
                            selectedVehicle, userId);
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
            ),
            onTapOutside: (PointerDownEvent event) {
              FocusScope.of(context).unfocus();
            },
          );
        },
        onSelected: (UserModel selectedUser) {
          setState(() {
            userId = selectedUser.idUser;
          });
          widget.onFiltersChanged(
              selectedDate, selectedStatus, selectedVehicle, userId);
        },
      ),
    );
  }

  // Function to clear all filters
  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedStatus = null;
      selectedVehicle = null;
    });
    // Notify parent widget about filter clearing
    widget.onFiltersChanged(
        selectedDate, selectedStatus, selectedVehicle, userId);
  }

  // Check if any filter is set
  bool _isAnyFilterSet() {
    return selectedDate != null ||
        selectedStatus != null ||
        selectedVehicle != null;
  }
}
