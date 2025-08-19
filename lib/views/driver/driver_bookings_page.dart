// screens/driver_bookings_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../services/driver_service.dart';

class DriverBookingsPage extends StatefulWidget {
  final String driverId;

  const DriverBookingsPage({super.key, required this.driverId});

  @override
  State<DriverBookingsPage> createState() => _DriverBookingsPageState();
}

class _DriverBookingsPageState extends State<DriverBookingsPage>
    with SingleTickerProviderStateMixin {
  final DriverService _driverService = DriverService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
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
          'Mes réservations',
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
            Tab(text: 'En attente'),
            Tab(text: 'Confirmées'),
            Tab(text: 'Toutes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsByStatus(BookingStatus.enAttente),
          _buildBookingsByStatus(BookingStatus.confirmee),
          _buildAllBookings(),
        ],
      ),
    );
  }

  Widget _buildBookingsByStatus(BookingStatus status) {
    return StreamBuilder<List<Booking>>(
      stream: _driverService.getDriverBookings(widget.driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _BookingsLoadingSkeleton();
        }

        if (snapshot.hasError) {
          return _ErrorCard(message: 'Erreur: ${snapshot.error}');
        }

        final allBookings = snapshot.data ?? [];
        final filteredBookings = allBookings.where((booking) => booking.status == status).toList();

        return _buildBookingsListView(filteredBookings, _getEmptyMessage(status));
      },
    );
  }

  Widget _buildAllBookings() {
    return StreamBuilder<List<Booking>>(
      stream: _driverService.getDriverBookings(widget.driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _BookingsLoadingSkeleton();
        }

        if (snapshot.hasError) {
          return _ErrorCard(message: 'Erreur: ${snapshot.error}');
        }

        final bookings = snapshot.data ?? [];
        return _buildBookingsListView(bookings, 'Aucune réservation trouvée');
      },
    );
  }

  Widget _buildBookingsListView(List<Booking> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return _EmptyBookingsState(message: emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BookingCard(
              booking: bookings[index],
              onTap: () => _showBookingDetails(bookings[index]),
              onStatusChange: (status) => _updateBookingStatus(bookings[index], status),
            ),
          );
        },
      ),
    );
  }

  String _getEmptyMessage(BookingStatus status) {
    switch (status) {
      case BookingStatus.enAttente:
        return 'Aucune réservation en attente';
      case BookingStatus.confirmee:
        return 'Aucune réservation confirmée';
      case BookingStatus.annulee:
        return 'Aucune réservation annulée';
    }
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BookingDetailsModal(booking: booking),
    );
  }

  Future<void> _updateBookingStatus(Booking booking, BookingStatus newStatus) async {
    try {
      await _driverService.updateBookingStatus(booking.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réservation ${_getStatusText(newStatus).toLowerCase()}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.enAttente:
        return 'En attente';
      case BookingStatus.confirmee:
        return 'Confirmée';
      case BookingStatus.annulee:
        return 'Annulée';
    }
  }
}

// ==================== COMPONENTS ====================

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final Function(BookingStatus) onStatusChange;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onStatusChange,
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
              // Header avec nom et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.passengerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(booking.status),
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Téléphone
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    booking.passengerPhone,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date de réservation
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Réservé le ${DateFormat('dd/MM/yyyy à HH:mm').format(booking.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer avec places et montant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${booking.placesReservees} place(s)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${booking.montantTotal.toInt()} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D63),
                        ),
                      ),
                    ],
                  ),
                  if (booking.status == BookingStatus.enAttente)
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onStatusChange(BookingStatus.confirmee),
                          icon: const Icon(Icons.check_circle_outline, size: 20),
                          color: Colors.green,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          onPressed: () => onStatusChange(BookingStatus.annulee),
                          icon: const Icon(Icons.cancel_outlined, size: 20),
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

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.enAttente:
        return const Color(0xFFFF9800);
      case BookingStatus.confirmee:
        return const Color(0xFF388E3C);
      case BookingStatus.annulee:
        return const Color(0xFFD32F2F);
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.enAttente:
        return 'En attente';
      case BookingStatus.confirmee:
        return 'Confirmée';
      case BookingStatus.annulee:
        return 'Annulée';
    }
  }
}

class _BookingDetailsModal extends StatelessWidget {
  final Booking booking;

  const _BookingDetailsModal({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header du modal
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Détails de la réservation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Informations passager
          _DetailSection(
            title: 'Passager',
            children: [
              _DetailRow(
                icon: Icons.person,
                label: 'Nom',
                value: booking.passengerName,
              ),
              _DetailRow(
                icon: Icons.phone,
                label: 'Téléphone',
                value: booking.passengerPhone,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informations réservation
          _DetailSection(
            title: 'Réservation',
            children: [
              _DetailRow(
                icon: Icons.event_seat,
                label: 'Places réservées',
                value: '${booking.placesReservees}',
              ),
              _DetailRow(
                icon: Icons.attach_money,
                label: 'Montant total',
                value: '${booking.montantTotal.toInt()} FCFA',
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Date de réservation',
                value: DateFormat('dd/MM/yyyy à HH:mm').format(booking.createdAt),
              ),
              _DetailRow(
                icon: Icons.info_outline,
                label: 'Statut',
                value: _getStatusText(booking.status),
                valueColor: _getStatusColor(booking.status),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actions
          if (booking.status == BookingStatus.enAttente) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Confirmer réservation
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Annuler réservation
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.enAttente:
        return const Color(0xFFFF9800);
      case BookingStatus.confirmee:
        return const Color(0xFF388E3C);
      case BookingStatus.annulee:
        return const Color(0xFFD32F2F);
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.enAttente:
        return 'En attente';
      case BookingStatus.confirmee:
        return 'Confirmée';
      case BookingStatus.annulee:
        return 'Annulée';
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D63),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SKELETON & EMPTY STATES ====================

class _BookingsLoadingSkeleton extends StatelessWidget {
  const _BookingsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _EmptyBookingsState extends StatelessWidget {
  final String message;

  const _EmptyBookingsState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
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