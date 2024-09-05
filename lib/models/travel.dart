import 'package:cloud_firestore/cloud_firestore.dart';

class TravelModel {
  final String id;
  final String? departureStationId;
  final String? destinationStationId;
  final String? departureLocation;
  final String? arrivalLocation;
  final DateTime startTime;
  final DateTime arrivalTime;
  final int remainingSeats;
  final double ticketPrice;

  TravelModel({
    required this.id,
    required this.departureStationId,
    required this.destinationStationId,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.startTime,
    required this.arrivalTime,
    required this.remainingSeats,
    required this.ticketPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departure_station_id': departureStationId,
      'destination_station_id': destinationStationId,
      'departure_location': departureLocation,
      'arrival_location': arrivalLocation,
      'start_time': startTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'remaining_seats': remainingSeats,
      'ticket_price': ticketPrice,
    };
  }

  factory TravelModel.fromMap(Map<String, dynamic> map) {
    print(map.toString());
    return TravelModel(
      id: map['id'],
      departureStationId: map['departure_station_id'],
      destinationStationId: map['destination_station_id'],
      departureLocation: map['departure_location'],
      arrivalLocation: map['arrival_location'],
      startTime: (map['start_time'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      arrivalTime: (map['arrival_time'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      remainingSeats: int.tryParse(map['remaining_seats']) ?? 0, // Parse as int, default to 0
      ticketPrice: double.tryParse(map['ticket_price']) ?? 0.0, // Parse as double, default to 0.0
    );
  }
}
