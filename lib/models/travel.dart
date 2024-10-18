import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class TravelModel {
  final String id;
  late DocumentReference? travelReference;
  final DocumentReference? departureStationId;
  final DocumentReference? destinationStationId;
  final DocumentReference? departureLocation;
  final String? arrivalLocation;
  final DateTime startTime;
  final DateTime arrivalTime;
  final int remainingSeats;
  final double ticketPrice;
  late StationModel? departureStation;
  late StationModel? destinationStation;
  final bool airConditioned;
  final String driverName;
  final String carName;

  TravelModel(
      {required this.id,
      required this.departureStationId,
      required this.destinationStationId,
      required this.departureLocation,
      required this.arrivalLocation,
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
      'departure_station': departureStationId?.path,
      'destination_station': destinationStationId?.path,
      'departure_location': departureLocation?.path,
      'arrival_location': arrivalLocation,
      'start_time': startTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
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
      ticketPrice: map['ticket_price'].toDouble() ??
          0.0, airConditioned: true, driverName: '', carName: '', // Parse as double, default to 0.0
    );
  }
  
  
  factory TravelModel.fromMapStation(Map<String, dynamic> map, StationModel departureStation, StationModel destinationStation) {
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
}
