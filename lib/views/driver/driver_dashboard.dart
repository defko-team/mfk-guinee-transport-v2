// screens/driver_dashboard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/views/user_profile.dart';

import '../../components/notifications_page.dart';
import '../../models/driver_stats.dart';
import '../../models/trip.dart';
import '../../services/driver_service.dart';
import 'driver_bookings_page.dart';
import 'driver_trip_page.dart';

class DriverDashboard extends StatefulWidget {
  final String driverId;

  const DriverDashboard({
    super.key,
    required this.driverId,
  });

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final DriverService _driverService = DriverService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Tableau de bord',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E7D63),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Statistiques
              _buildStatsSection(),

              const SizedBox(height: 24),

              // Section Navigation
              _buildNavigationSection(),

              const SizedBox(height: 24),

              // Section Trajets du jour
              _buildTodayTripsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<DriverStats>(
      future: _driverService.getDriverStats(widget.driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _StatsLoadingSkeleton();
        }

        if (snapshot.hasError) {
          return _StatsErrorCard(error: snapshot.error.toString());
        }

        final stats = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mes statistiques',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Ce mois',
                    value: '${NumberFormat('#,###', 'fr_FR').format(stats.monthRevenue)} FCFA',
                    subtitle: '${stats.monthSeats} places vendues',
                    icon: Icons.trending_up,
                    color: const Color(0xFF2E7D63),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Aujourd\'hui',
                    value: '${stats.todayTrips}',
                    subtitle: 'trajets planifiés',
                    icon: Icons.today,
                    color: const Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total trajets',
                    value: '${stats.totalTrips}',
                    subtitle: 'depuis le début',
                    icon: Icons.route,
                    color: const Color(0xFF7B1FA2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Ce mois',
                    value: '${stats.monthTrips}',
                    subtitle: 'trajets effectués',
                    icon: Icons.directions_car,
                    color: const Color(0xFFD84315),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Navigation rapide',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _NavigationCard(
                title: 'Mes trajets',
                subtitle: 'Gérer mes voyages',
                icon: Icons.map_outlined,
                color: const Color(0xFF1976D2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverTripsPage(driverId: widget.driverId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NavigationCard(
                title: 'Réservations',
                subtitle: 'Voir mes clients',
                icon: Icons.people_outline,
                color: const Color(0xFF388E3C),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverBookingsPage(driverId: widget.driverId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trajets d\'aujourd\'hui',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverTripsPage(driverId: widget.driverId),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Trip>>(
          stream: _driverService.getTodayTrips(widget.driverId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _TripCardSkeleton();
            }

            if (snapshot.hasError) {
              return _ErrorCard(message: 'Erreur de chargement des trajets');
            }

            final trips = snapshot.data ?? [];

            if (trips.isEmpty) {
              return const _EmptyTodayTrips();
            }

            return Column(
              children: trips.take(3).map((trip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TripCard(trip: trip),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ==================== COMPONENTS ====================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('HH:mm').format(trip.dateDepart),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(trip.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${trip.stationDepart} → ${trip.stationArrivee}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trip.placesReservees}/${trip.placesTotal} places',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${trip.prix.toInt()} FCFA',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D63),
                ),
              ),
            ],
          ),
        ],
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

class _StatsLoadingSkeleton extends StatelessWidget {
  const _StatsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SkeletonCard()),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SkeletonCard()),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard()),
          ],
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _TripCardSkeleton extends StatelessWidget {
  const _TripCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )),
    );
  }
}

class _EmptyTodayTrips extends StatelessWidget {
  const _EmptyTodayTrips();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun trajet aujourd\'hui',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier trajet',
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

class _StatsErrorCard extends StatelessWidget {
  final String error;

  const _StatsErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Erreur de chargement des statistiques',
              style: TextStyle(color: Colors.red.shade700),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
