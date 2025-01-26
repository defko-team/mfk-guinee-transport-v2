import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/services/car_service.dart';
import 'package:mfk_guinee_transport/services/history_service.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:mfk_guinee_transport/views/card_reservation.dart';

class HistoryPage extends StatefulWidget {
  final String title;
  const HistoryPage({super.key, this.title = "Réservations"});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  List<ReservationModel> reservations = [];
  UserService userService = UserService();
  DateTime? selectedDate;
  String? selectedStatus;
  String? selectedVehicle;
  String? userId;
  List<UserModel> users = [];
  List<VoitureModel> cars = [];
  UserModel? currentUser;
  late TabController _tabController;
  bool isLoading = false;
  CarService carService = CarService();

  // Helper function to get French label for status
  String getStatusFrenchLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'canceled':
        return 'Annulé';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final usersData = await userService.getAllUsers();
      final carsData = await carService.getAllVoitures();
      if (mounted) {
        setState(() {
          users = usersData;
          cars = carsData;
        });
      }
      currentUser = await userService.getCurrentUser();
      fetchReservations();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetUsers() async {
    currentUser = await userService.getCurrentUser();
    List<UserModel> fetchedUsers = await UserService().getAllUsers();
    if (mounted) {
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    }
  }

  void fetchReservations() async {
    setState(() => isLoading = true);
    List<ReservationModel> fetchedReservations = await HistoriqueService()
        .fetchReservation(
            startTimeFilter: selectedDate,
            statusFilter: selectedStatus,
            carNameFilter: selectedVehicle,
            userId: userId);

    // Sort reservations by start time
    fetchedReservations.sort((b, a) => a.startTime.compareTo(b.startTime));

    if (mounted) {
      setState(() {
        reservations = fetchedReservations;
        userId = userId;
        isLoading = false;
      });
    }
  }

  void onFiltersChanged(
      DateTime? date, String? status, String? vehicle, String? selectedId) {
    setState(() {
      selectedDate = date;
      selectedStatus = status;
      selectedVehicle = vehicle;
      userId = selectedId;
    });
    fetchReservations();
  }

  void _openModifyReservationBottomSheet(
      {required ReservationModel reservation}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Modifier la réservation'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation trouvée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les réservations apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcomingCount = reservations
        .where((res) =>
            res.status == ReservationStatus.pending ||
            res.status == ReservationStatus.confirmed)
        .length;

    final historyCount = reservations
        .where((res) =>
            res.status == ReservationStatus.completed ||
            res.status == ReservationStatus.canceled)
        .length;

    return Scaffold(
      appBar: BaseAppBar(
        title: widget.title,
        showBackArrow: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.green,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('À venir'),
                      if (upcomingCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            upcomingCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Historique'),
                      if (historyCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            historyCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FadeInUp(
                  child: Column(
                    children: [
                      FilterBar(
                        onFiltersChanged: onFiltersChanged,
                        users: users,
                        cars: cars,
                        isAdmin: currentUser?.role?.toLowerCase() == 'admin',
                        isUpcomingTab: true,
                      ),
                      Expanded(
                        child: isLoading
                            ? _buildLoadingState()
                            : reservations.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    itemCount: reservations.length,
                                    itemBuilder: (context, index) {
                                      final reservation = reservations[index];
                                      print(reservation.toMap());
                                      if (reservation.status !=
                                              ReservationStatus.pending &&
                                          reservation.status !=
                                              ReservationStatus.confirmed) {
                                        return const SizedBox.shrink();
                                      }
                                      return FadeInUp(
                                        delay:
                                            Duration(milliseconds: index * 10),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: CardReservation(
                                            reservationModel: reservation,
                                            onOpenModifyReservationBottonSheet:
                                                _openModifyReservationBottomSheet,
                                            isAdmin: currentUser?.role
                                                    ?.toLowerCase() ==
                                                'admin',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
                // Second tab content (History)
                FadeInUp(
                  child: Column(
                    children: [
                      FilterBar(
                        onFiltersChanged: onFiltersChanged,
                        users: users,
                        cars: cars,
                        isAdmin: currentUser?.role?.toLowerCase() == 'admin',
                        isUpcomingTab: false,
                      ),
                      Expanded(
                        child: isLoading
                            ? _buildLoadingState()
                            : reservations.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    itemCount: reservations.length,
                                    itemBuilder: (context, index) {
                                      final reservation = reservations[index];
                                      if (reservation.status !=
                                              ReservationStatus.completed &&
                                          reservation.status !=
                                              ReservationStatus.canceled) {
                                        return const SizedBox.shrink();
                                      }
                                      return FadeInUp(
                                        delay:
                                            Duration(milliseconds: index * 100),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: CardReservation(
                                            reservationModel: reservation,
                                            onOpenModifyReservationBottonSheet:
                                                _openModifyReservationBottomSheet,
                                            isAdmin: currentUser?.role
                                                    ?.toLowerCase() ==
                                                'admin',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatefulWidget {
  final Function(DateTime?, String?, String?, String?) onFiltersChanged;
  final List<UserModel> users;
  final List<VoitureModel> cars;
  final bool isAdmin;
  final bool isUpcomingTab;

  const FilterBar({
    Key? key,
    required this.onFiltersChanged,
    required this.users,
    required this.cars,
    required this.isAdmin,
    required this.isUpcomingTab,
  }) : super(key: key);

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  DateTime? selectedDate;
  String? selectedStatus;
  String? selectedVehicle;
  String? selectedUserId;

  // Helper function to get French label for status
  String getStatusFrenchLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'canceled':
        return 'Annulé';
      default:
        return status;
    }
  }

  // Helper function to get status value from French label
  String? getStatusValueFromLabel(String label) {
    switch (label) {
      case 'En attente':
        return 'pending';
      case 'Confirmé':
        return 'confirmed';
      case 'Terminé':
        return 'completed';
      case 'Annulé':
        return 'canceled';
      default:
        return label;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatusDropdown(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleDropdown(),
              ),
            ],
          ),
          if (widget.isAdmin) ...[
            const SizedBox(height: 8),
            _buildUsersDropdown(),
          ],
          if (_isAnyFilterSet()) ...[
            const SizedBox(height: 8),
            _buildClearButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    final statusOptions = widget.isUpcomingTab
        ? [ReservationStatus.pending, ReservationStatus.confirmed]
        : [ReservationStatus.completed, ReservationStatus.canceled];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedStatus,
        hint: const Text('Statut'),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Tous les statuts'),
          ),
          ...statusOptions.map((ReservationStatus status) {
            final statusValue = status.toString().split('.').last;
            return DropdownMenuItem<String>(
              value: statusValue,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: getStatusColor(statusValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(getStatusFrenchLabel(statusValue)),
                ],
              ),
            );
          }).toList(),
        ],
        onChanged: (String? newValue) {
          setState(() {
            selectedStatus = newValue;
          });
          widget.onFiltersChanged(
              selectedDate, newValue, selectedVehicle, selectedUserId);
        },
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedVehicle,
        hint: const Text('Véhicules'),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Tous les véhicules'),
          ),
          ...widget.cars.map((VoitureModel car) {
            return DropdownMenuItem<String>(
              value: car.marque,
              child: Text(car.marque),
            );
          }).toList(),
        ],
        onChanged: (String? newValue) {
          setState(() {
            selectedVehicle = newValue;
          });
          widget.onFiltersChanged(
              selectedDate, selectedStatus, newValue, selectedUserId);
        },
      ),
    );
  }

  Widget _buildUsersDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedUserId,
        hint: const Text('Utilisateur'),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: widget.users.map((UserModel user) {
          return DropdownMenuItem<String>(
            value: user.idUser,
            child: Text(user.nom ?? 'Unknown User'),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedUserId = newValue;
          });
          widget.onFiltersChanged(
              selectedDate, selectedStatus, selectedVehicle, newValue);
        },
      ),
    );
  }

  Widget _buildClearButton() {
    return TextButton(
      onPressed: _clearFilters,
      child: const Text('Effacer les filtres'),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedStatus = null;
      selectedVehicle = null;
      selectedUserId = null;
    });
    widget.onFiltersChanged(null, null, null, null);
  }

  bool _isAnyFilterSet() {
    return selectedDate != null ||
        selectedStatus != null ||
        selectedVehicle != null ||
        selectedUserId != null;
  }
}
