// screens/driver_trips_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../models/trip.dart';
import '../../services/driver_service.dart';

class DriverTripsPage extends StatefulWidget {
  final String driverId;

  const DriverTripsPage({super.key, required this.driverId});

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage>
    with SingleTickerProviderStateMixin {
  final DriverService _driverService = DriverService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print("driverId: ${widget.driverId}");

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Mes trajets',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E7D63),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Tous'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTrips(),
          _buildAllTrips(),
          _buildPastTrips(),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     _showCreateTripDialog();
      //   },
      //   backgroundColor: const Color(0xFF2E7D63),
      //   foregroundColor: Colors.white,
      //   icon: const Icon(Icons.add),
      //   label: const Text('Nouveau trajet'),
      // ),
    );
  }

  Widget _buildUpcomingTrips() {
    return StreamBuilder<List<Trip>>(
      stream: _driverService.getUpcomingTrips(widget.driverId),
      builder: (context, snapshot) {
        return _buildTripsList(snapshot, 'Aucun trajet à venir');
      },
    );
  }

  Widget _buildAllTrips() {
    return StreamBuilder<List<Trip>>(
      stream: _driverService.getDriverTrips(widget.driverId),
      builder: (context, snapshot) {
        return _buildTripsList(snapshot, 'Aucun trajet trouvé');
      },
    );
  }

  Widget _buildPastTrips() {
    return StreamBuilder<List<Trip>>(
      stream: _driverService.getDriverTrips(widget.driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _TripsLoadingSkeleton();
        }

        if (snapshot.hasError) {
          return _ErrorCard(message: 'Erreur: ${snapshot.error}');
        }

        final allTrips = snapshot.data ?? [];
        final now = DateTime.now();
        final pastTrips = allTrips.where((trip) =>
        trip.dateDepart.isBefore(now) ||
            trip.status == TripStatus.termine ||
            trip.status == TripStatus.annule
        ).toList();

        return _buildTripsListView(pastTrips, 'Aucun trajet dans l\'historique');
      },
    );
  }

  Widget _buildTripsList(AsyncSnapshot<List<Trip>> snapshot, String emptyMessage) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const _TripsLoadingSkeleton();
    }

    if (snapshot.hasError) {
      return _ErrorCard(message: 'Erreur: ${snapshot.error}');
    }

    final trips = snapshot.data ?? [];
    return _buildTripsListView(trips, emptyMessage);
  }

  Widget _buildTripsListView(List<Trip> trips, String emptyMessage) {
    if (trips.isEmpty) {
      return _EmptyTripsState(message: emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TripCardDetailed(
              trip: trips[index],
              onTap: () => _showTripDetails(trips[index]),
              onEdit: () => _showEditTripDialog(trips[index]),
              onDelete: () => _showDeleteTripDialog(trips[index]),
            ),
          );
        },
      ),
    );
  }

  void _showTripDetails(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsPage(trip: trip),
      ),
    );
  }

  void _showCreateTripDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau trajet'),
        content: const Text('Fonctionnalité de création de trajet à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditTripDialog(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le trajet'),
        content: Text('Modifier le trajet de ${trip.stationDepart} vers ${trip.stationArrivee}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implémenter la modification
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTripDialog(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le trajet'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce trajet ?\n\n${trip.stationDepart} → ${trip.stationArrivee}\n${DateFormat('dd/MM/yyyy à HH:mm').format(trip.dateDepart)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _driverService.deleteTrip(trip.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trajet supprimé')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ==================== COMPONENTS ====================

class _TripCardDetailed extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TripCardDetailed({
    required this.trip,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec heure et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy à HH:mm').format(trip.dateDepart),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(trip.status),
                      style: TextStyle(
                        color: _getStatusColor(trip.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Trajet
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${trip.stationDepart} → ${trip.stationArrivee}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Véhicule et climatisation
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(trip.vehicule),
                  if (trip.climatise) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.ac_unit, size: 16, color: Colors.blue),
                    const Text(' Climatisé', style: TextStyle(color: Colors.blue, fontSize: 12)),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Footer avec places et prix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${trip.placesReservees}/${trip.placesTotal} places',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${trip.prix.toInt()} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D63),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.blue,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.planifie:
        return const Color(0xFF1976D2);
      case TripStatus.enCours:
        return const Color(0xFFFF9800);
      case TripStatus.termine:
        return const Color(0xFF388E3C);
      case TripStatus.annule:
        return const Color(0xFFD32F2F);
    }
  }

  String _getStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.planifie:
        return 'Planifié';
      case TripStatus.enCours:
        return 'En cours';
      case TripStatus.termine:
        return 'Terminé';
      case TripStatus.annule:
        return 'Annulé';
    }
  }
}

// ==================== SKELETON & EMPTY STATES ====================

class _TripsLoadingSkeleton extends StatelessWidget {
  const _TripsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _EmptyTripsState extends StatelessWidget {
  final String message;

  const _EmptyTripsState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tirez pour actualiser',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 32),
            const SizedBox(height: 12),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.red.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TRIP DETAILS PAGE ====================

class TripDetailsPage extends StatelessWidget {
  final Trip trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet'),
        backgroundColor: const Color(0xFF2E7D63),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip.stationDepart} → ${trip.stationArrivee}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date de départ',
                      value: DateFormat('dd/MM/yyyy à HH:mm').format(trip.dateDepart),
                    ),
                    if (trip.dateArrivee != null)
                      _DetailRow(
                        icon: Icons.flag,
                        label: 'Arrivée prévue',
                        value: DateFormat('dd/MM/yyyy à HH:mm').format(trip.dateArrivee!),
                      ),
                    _DetailRow(
                      icon: Icons.directions_car,
                      label: 'Véhicule',
                      value: trip.vehicule,
                    ),
                    _DetailRow(
                      icon: Icons.people,
                      label: 'Places',
                      value: '${trip.placesReservees}/${trip.placesTotal}',
                    ),
                    _DetailRow(
                      icon: Icons.attach_money,
                      label: 'Prix par place',
                      value: '${trip.prix.toInt()} FCFA',
                    ),
                    if (trip.climatise)
                      const _DetailRow(
                        icon: Icons.ac_unit,
                        label: 'Climatisation',
                        value: 'Oui',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Liste des passagers
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Passagers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Booking>>(
                      stream: DriverService().getTripBookings(trip.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final bookings = snapshot.data ?? [];

                        if (bookings.isEmpty) {
                          return const Text('Aucun passager pour le moment');
                        }

                        return Column(
                          children: bookings.map((booking) => ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(booking.passengerName),
                            subtitle: Text(booking.passengerPhone),
                            trailing: Text('${booking.placesReservees} place(s)'),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}