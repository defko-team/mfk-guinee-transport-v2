import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class TravelModel {
  final String id;
  final StationModel? departureStation;
  final StationModel? destinationStation;
  final String? departureLocation;
  final String? arrivalLocation;
  final DateTime startTime;
  final DateTime arrivalTime;
  final int remainingSeats;
  final int ticketPrice;
  final bool airConditioned;
  final String driverName;
  final String carName;

  TravelModel({
    required this.id,
    required this.departureStation,
    required this.destinationStation,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.startTime,
    required this.arrivalTime,
    required this.remainingSeats,
    required this.ticketPrice,
    required this.airConditioned,
    required this.driverName,
    required this.carName
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departure_station': '/Station/${departureStation?.docId}',
      'destination_station': '/Station/${destinationStation?.docId}',
      'departure_location': departureLocation,
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

  factory TravelModel.fromMap(Map<String, dynamic> map, StationModel departure, StationModel destination) {
    print('Map: $map');
    return TravelModel(
      id: map['id'],
      departureStation: departure,
      destinationStation: destination,
      departureLocation: map['departure_location'],
      arrivalLocation: map['arrival_location'],
      startTime: (map['start_time'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      arrivalTime: (map['arrival_time'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      remainingSeats: map['remaining_seats'] ?? 0, // Parse as int, default to 0
      ticketPrice: map['ticket_price'] ?? 0, // Parse as double, default to 0.0
      airConditioned: map['air_conditioned'] ?? false, // Parse as bool
      driverName: map['driver_name'], // Parse as string
      carName: map['car_name'], // Parse as string
    );
  }
}
