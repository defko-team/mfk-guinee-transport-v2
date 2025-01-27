import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:flutter/cupertino.dart';

class CardReservation extends StatelessWidget {
  final ReservationModel reservationModel;
  final void Function({required ReservationModel reservation})
      onOpenModifyReservationBottonSheet;
  final bool isAdmin;

  const CardReservation({
    super.key,
    required this.reservationModel,
    required this.onOpenModifyReservationBottonSheet,
    this.isAdmin = false,
  });

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
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

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'En attente';
      case ReservationStatus.confirmed:
        return 'Confirmée';
      case ReservationStatus.completed:
        return 'Terminée';
      case ReservationStatus.canceled:
        return 'Annulée';
      default:
        return 'Inconnue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reservationModel.id ?? ''),
      direction: isAdmin ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmer la suppression'),
                content: const Text(
                    'Voulez-vous vraiment supprimer cette réservation ?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Supprimer',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          );
        }
        return false;
      },
      background: Container(
        color: Colors.red,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Détails de la réservation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _DetailItem(
                            icon: Icons.numbers,
                            title: 'Numéro réservation',
                            value: reservationModel.id ?? '',
                          ),
                          const Divider(height: 24),
                          _DetailItem(
                            icon: Icons.person,
                            title: 'Chauffeur',
                            value: reservationModel.driverName ?? '',
                          ),
                          const Divider(height: 24),
                          _DetailItem(
                            icon: Icons.my_location,
                            title: 'Départ',
                            value: reservationModel.departureStation ??
                                reservationModel.departureLocation ??
                                '',
                          ),
                          const Divider(height: 24),
                          _DetailItem(
                            icon: Icons.location_on_outlined,
                            title: 'Destination',
                            value: reservationModel.destinationStation ??
                                reservationModel.arrivalLocation ??
                                '',
                          ),
                          const Divider(height: 24),
                          _DetailItem(
                            icon: Icons.calendar_today,
                            title: 'Date de départ',
                            value: DateFormat('dd/MM/yyyy')
                                .format(reservationModel.startTime),
                          ),
                          const Divider(height: 24),
                          _DetailItem(
                            icon: Icons.access_time,
                            title: 'Heure de départ',
                            value: DateFormat('HH:mm')
                                .format(reservationModel.startTime),
                          ),
                          if (reservationModel.arrivalTime != null) ...[
                            const Divider(height: 24),
                            _DetailItem(
                              icon: Icons.calendar_today,
                              title: 'Date de d' 'arrivée',
                              value: DateFormat('dd/MM/yyyy')
                                  .format(reservationModel.arrivalTime!),
                            ),
                            const Divider(height: 24),
                            _DetailItem(
                              icon: Icons.access_time,
                              title: 'Heure de d' 'arrivée',
                              value: DateFormat('HH:mm')
                                  .format(reservationModel.arrivalTime!),
                            ),
                          ],
                          if (reservationModel.ticketPrice != null) ...[
                            const Divider(height: 24),
                            _DetailItem(
                              icon: Icons.attach_money,
                              title: 'Prix',
                              value: '${reservationModel.ticketPrice} CFA',
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservationModel.departureStation ??
                            reservationModel.departureLocation ??
                            '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservationModel.destinationStation ??
                            reservationModel.arrivalLocation ??
                            '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(reservationModel.startTime),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(reservationModel.startTime),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reservationModel.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(reservationModel.status),
                        style: TextStyle(
                          color: _getStatusColor(reservationModel.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isAdmin &&
                        reservationModel.status == ReservationStatus.pending)
                      ElevatedButton.icon(
                        onPressed: () {
                          onOpenModifyReservationBottonSheet(
                              reservation: reservationModel);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
