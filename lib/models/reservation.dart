
class ReservationModel {
  final String? id;
  final String? departureStation;
  final String? destinationStation;
  final String? departureLocation;
  final String? arrivalLocation;
  final DateTime startTime;
  final DateTime arrivalTime;
  final int remainingSeats;
  final int ticketPrice;
  final bool airConditioned;
  final String driverName;
  final String carName;
  final ReservationStatus status;
  final String userId;
  final String distance;

  ReservationModel({
    this.id,
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
    required this.carName,
    required this.status,
    required this.userId,
    required this.distance
    });

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'],
      departureStation: map['departure_station'],
      destinationStation: map['destination_station'],
      departureLocation: map['departure_location'],
      arrivalLocation: map['arrival_location'],
      startTime: map['start_time'],
      arrivalTime: map['arrival_time'],
      remainingSeats: map['remaining_seats'],
      ticketPrice: map['ticket_price'],
      airConditioned: map['air_conditioned'],
      driverName: map['driver_name'],
      carName: map['car_name'],
      status: map['status'],
      userId: map['user_id'],
      distance: map['distance']
    );
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
      'status': status,
      'user_id': userId,
      'distance': distance
    };
  }
}

enum ReservationStatus {
  completed,
  confirmed,
  canceled
}