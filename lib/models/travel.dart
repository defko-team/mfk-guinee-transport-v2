import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class TravelModel {
  final String? id;
  late DocumentReference? travelReference;
  late final DocumentReference? departureStationId;
  late final DocumentReference? destinationStationId;
  late final DocumentReference? departureLocation;
  late final String? arrivalLocation;
  late final DateTime startTime;
  late final DateTime arrivalTime;
  late final int remainingSeats;
  late final double ticketPrice;
  late StationModel? departureStation;
  late StationModel? destinationStation;
  late final bool airConditioned;
  late final String driverName;
  late final String carName;

  TravelModel(
      {this.id,
      required this.departureStationId,
      required this.destinationStationId,
      this.departureLocation,
      this.arrivalLocation,
      required this.startTime,
      required this.arrivalTime,
      required this.remainingSeats,
      required this.ticketPrice,
      this.travelReference,
      this.departureStation,
      this.destinationStation,
      required this.airConditioned,
      required this.driverName,
      required this.carName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departure_station': departureStationId,
      'destination_station': destinationStationId,
      'departure_location': departureLocation,
      'arrival_location': arrivalLocation,
      'start_time': startTime,
      'arrival_time': arrivalTime,
      'remaining_seats': remainingSeats,
      'ticket_price': ticketPrice,
      'air_conditioned': airConditioned,
      'driver_name': driverName,
      'car_name': carName
    };
  }

  factory TravelModel.fromMap(Map<String, dynamic> map) {
    return TravelModel(
      id: map['id'],
      departureStationId: map['departure_station'],
      destinationStationId: map['destination_station'],
      departureLocation: map['departure_location'],
      arrivalLocation: map['arrival_location'],
      startTime: (map['start_time'] as Timestamp)
          .toDate(), // Convert Timestamp to DateTime
      arrivalTime: (map['arrival_time'] as Timestamp)
          .toDate(), // Convert Timestamp to DateTime
      remainingSeats: map['remaining_seats'] ?? 0, // Parse as int, default to 0
      ticketPrice: map['ticket_price'].toDouble() ?? 0.0,
      airConditioned: map['air_conditioned'] ?? false,
      driverName: map['driver_name'] ?? '',
      carName: map['car_name'] ?? '', // Parse as double, default to 0.0
    );
  }

  factory TravelModel.fromMapStation(Map<String, dynamic> map,
      StationModel departureStation, StationModel destinationStation) {
    return TravelModel(
      id: map['id'],
      departureStation: departureStation,
      destinationStation: destinationStation,
      departureStationId: null,
      destinationStationId: null,
      arrivalLocation: map['arrival_location'],
      startTime: (map['start_time'] as Timestamp).toDate(),
      arrivalTime: (map['arrival_time'] as Timestamp).toDate(),
      remainingSeats: map['remaining_seats'] ?? 0,
      ticketPrice: map['ticket_price']?.toDouble() ?? 0.0,
      airConditioned: map['air_conditioned'] ?? false,
      driverName: map['driver_name'] ?? '',
      carName: map['car_name'] ?? '',
      departureLocation: null,
    );
  }

  @override
  String toString() {
    return 'TravelModel {'
        'id: $id, '
        'travelReference: $travelReference, '
        'departureStationId: $departureStationId, '
        'destinationStationId: $destinationStationId, '
        'departureLocation: $departureLocation, '
        'arrivalLocation: $arrivalLocation, '
        'startTime: $startTime, '
        'arrivalTime: $arrivalTime, '
        'remainingSeats: $remainingSeats, '
        'ticketPrice: $ticketPrice, '
        'departureStation: ${departureStation?.name}, ' // Assuming StationModel has a name property
        'destinationStation: ${destinationStation?.name}, '
        'airConditioned: $airConditioned, '
        'driverName: $driverName, '
        'carName: $carName'
        '}';
  }
}
