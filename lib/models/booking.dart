enum BookingStatus { enAttente, confirmee, annulee }

class Booking {
  final String id;
  final String tripId;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;
  final int placesReservees;
  final double montantTotal;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.placesReservees,
    required this.montantTotal,
    this.status = BookingStatus.enAttente,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'passenger_id': passengerId,
      'passenger_name': passengerName,
      'passenger_phone': passengerPhone,
      'places_reservees': placesReservees,
      'montant_total': montantTotal,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      tripId: map['trip_id'] ?? '',
      passengerId: map['passenger_id'] ?? '',
      passengerName: map['passenger_name'] ?? '',
      passengerPhone: map['passenger_phone'] ?? '',
      placesReservees: map['places_reservees'] ?? 0,
      montantTotal: (map['montant_total'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => BookingStatus.enAttente,
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}