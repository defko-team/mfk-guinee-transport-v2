import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String? id;
  final String? departureStation;
  final String? destinationStation;
  final String? departureLocation;
  final String? arrivalLocation;
  final DateTime startTime;
  final DateTime? arrivalTime;
  final int remainingSeats;
  final double? ticketPrice;
  final bool? airConditioned;
  final String? driverName;
  final String? carName;
  final ReservationStatus status;
  final String userId;
  final String distance;

  ReservationModel(
      {this.id,
      this.departureStation,
      this.destinationStation,
      this.departureLocation,
      this.arrivalLocation,
      required this.startTime,
      this.arrivalTime,
      required this.remainingSeats,
      this.ticketPrice,
      this.airConditioned,
      this.driverName,
      this.carName,
      required this.status,
      required this.userId,
      required this.distance});

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
        id: map['id'],
        departureStation: map['departure_station'],
        destinationStation: map['destination_station'],
        departureLocation: map['departure_location'],
        arrivalLocation: map['arrival_location'],
        startTime: (map['start_time'] as Timestamp?)!.toDate(),
        arrivalTime: map['arrival_time'] != null
            ? (map['arrival_time'] as Timestamp?)!.toDate()
            : null,
        remainingSeats: map['remaining_seats'],
        ticketPrice: (map['ticket_price'] is int)
            ? (map['ticket_price'] as int).toDouble()
            : 0,
        airConditioned: map['air_conditioned'],
        driverName: map['driver_name'],
        carName: map['car_name'],
        status: _getStatusFromString(map['status'] as String),
        userId: map['user_id'],
        distance: map['distance']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departure_station': departureStation,
      'destination_station': destinationStation,
      'departure_location': departureLocation,
      'arrival_location': arrivalLocation,
      'start_time': startTime,
      'arrival_time': arrivalTime,
      'remaining_seats': remainingSeats,
      'ticket_price': ticketPrice,
      'air_conditioned': airConditioned,
      'driver_name': driverName,
      'car_name': carName,
      'status': status.name,
      'user_id': userId,
      'distance': distance
    };
  }

  ReservationModel copyWith(
      {String? id,
      String? departureStation,
      String? destinationStation,
      String? departureLocation,
      String? arrivalLocation,
      DateTime? startTime,
      DateTime? arrivalTime,
      int? remainingSeats,
      double? ticketPrice,
      bool? airConditioned,
      String? driverName,
      String? carName,
      ReservationStatus? status,
      String? userId,
      String? distances}) {
    return ReservationModel(
        id: id ?? this.id,
        departureStation: departureStation ?? this.departureStation,
        destinationStation: destinationStation ?? this.destinationStation,
        departureLocation: departureLocation ?? this.departureLocation,
        arrivalLocation: arrivalLocation ?? this.arrivalLocation,
        startTime: startTime ?? this.startTime,
        arrivalTime: arrivalTime ?? this.arrivalTime,
        remainingSeats: remainingSeats ?? this.remainingSeats,
        ticketPrice: ticketPrice ?? this.ticketPrice,
        airConditioned: airConditioned ?? this.airConditioned,
        driverName: driverName ?? this.driverName,
        carName: carName ?? this.carName,
        status: status ?? this.status,
        userId: userId ?? this.userId,
        distance: distance ?? this.distance);
  }

  // Helper function to convert string to enum
  static ReservationStatus _getStatusFromString(String status) {
    switch (status) {
      case 'completed':
        return ReservationStatus.completed;
      case 'canceled':
        return ReservationStatus.canceled;
      case 'pending':
        return ReservationStatus.pending;
      case 'confirmed':
        return ReservationStatus.confirmed;
      default:
        return ReservationStatus.unknown;
    }
  }
}

enum ReservationStatus { unknown, pending, completed, confirmed, canceled }
