enum TripStatus { planifie, enCours, termine, annule }

class Trip {
  final String id;
  final String driverId;
  final String stationDepart;
  final String stationArrivee;
  final DateTime dateDepart;
  final DateTime? dateArrivee;
  final int placesTotal;
  final int placesReservees;
  final double prix;
  final bool climatise;
  final String vehicule;
  final TripStatus status;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.driverId,
    required this.stationDepart,
    required this.stationArrivee,
    required this.dateDepart,
    this.dateArrivee,
    required this.placesTotal,
    this.placesReservees = 0,
    required this.prix,
    this.climatise = false,
    required this.vehicule,
    this.status = TripStatus.planifie,
    required this.createdAt,
  });

  int get placesDisponibles => placesTotal - placesReservees;
  bool get isComplete => placesReservees >= placesTotal;
  bool get isToday {
    final now = DateTime.now();
    return dateDepart.year == now.year &&
        dateDepart.month == now.month &&
        dateDepart.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driver_id': driverId,
      'station_depart': stationDepart,
      'station_arrivee': stationArrivee,
      'date_depart': dateDepart.toIso8601String(),
      'date_arrivee': dateArrivee?.toIso8601String(),
      'places_total': placesTotal,
      'places_reservees': placesReservees,
      'prix': prix,
      'climatise': climatise,
      'vehicule': vehicule,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      driverId: map['driver_id'] ?? '',
      stationDepart: map['station_depart'] ?? '',
      stationArrivee: map['station_arrivee'] ?? '',
      dateDepart: DateTime.parse(map['date_depart']),
      dateArrivee: map['date_arrivee'] != null
          ? DateTime.parse(map['date_arrivee'])
          : null,
      placesTotal: map['places_total'] ?? 0,
      placesReservees: map['places_reservees'] ?? 0,
      prix: (map['prix'] ?? 0).toDouble(),
      climatise: map['climatise'] ?? false,
      vehicule: map['vehicule'] ?? '',
      status: TripStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TripStatus.planifie,
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Trip copyWith({
    String? id,
    String? driverId,
    String? stationDepart,
    String? stationArrivee,
    DateTime? dateDepart,
    DateTime? dateArrivee,
    int? placesTotal,
    int? placesReservees,
    double? prix,
    bool? climatise,
    String? vehicule,
    TripStatus? status,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      stationDepart: stationDepart ?? this.stationDepart,
      stationArrivee: stationArrivee ?? this.stationArrivee,
      dateDepart: dateDepart ?? this.dateDepart,
      dateArrivee: dateArrivee ?? this.dateArrivee,
      placesTotal: placesTotal ?? this.placesTotal,
      placesReservees: placesReservees ?? this.placesReservees,
      prix: prix ?? this.prix,
      climatise: climatise ?? this.climatise,
      vehicule: vehicule ?? this.vehicule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}