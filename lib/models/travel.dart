import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class TravelModel {
  final String? id;
  late DocumentReference? travelReference;
  late final String? departureStationId;
  late final String? destinationStationId;
  late final String? departureLocation;
  late final String? arrivalLocation;
  late final DateTime startTime;
  late final DateTime? arrivalTime;
  late final int remainingSeats;
  late final int? ticketPrice;
  late StationModel? departureStation;
  late StationModel? destinationStation;
  late final bool? airConditioned;
  late final String? driverName;
  late final String? carName;
  late final int? nombreDePlace;

  TravelModel(
      {this.id,
      this.departureStationId,
      this.destinationStationId,
      this.departureLocation,
      this.arrivalLocation,
      required this.startTime,
      this.arrivalTime,
      required this.remainingSeats,
      this.ticketPrice,
      this.travelReference,
      this.departureStation,
      this.destinationStation,
      this.airConditioned,
      this.driverName,
      this.carName,
      this.nombreDePlace});

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'departure_station': FirebaseFirestore.instance
        .collection('Station')
        .doc(departureStationId),
    'destination_station': FirebaseFirestore.instance
        .collection('Station')
        .doc(destinationStationId),
    'departure_location': departureLocation,
    'arrival_location': arrivalLocation,
    'start_time': startTime,
    'arrival_time': arrivalTime,
    'remaining_seats': remainingSeats,
    'ticket_price': ticketPrice,
    'air_conditioned': airConditioned,
    'driver_name': driverName,
    'car_name': carName,
    'nombre_de_place': nombreDePlace,
  };
}
factory TravelModel.fromMap(Map<String, dynamic> map) {
  return TravelModel(
    id: map['id'],
    departureStationId: (map['departure_station'] is DocumentReference)
        ? (map['departure_station'] as DocumentReference).id
        : (map['departure_station'] as String).split('/').last,
    destinationStationId: (map['destination_station'] is DocumentReference)
        ? (map['destination_station'] as DocumentReference).id
        : (map['destination_station'] as String).split('/').last,
    departureLocation: map['departure_location'] ?? '',
    arrivalLocation: map['arrival_location'] ?? '',
    startTime: (map['start_time'] as Timestamp).toDate(),
    arrivalTime: map['arrival_time'] != null
        ? (map['arrival_time'] as Timestamp).toDate()
        : null,
    remainingSeats: map['remaining_seats'] ?? 0,
    ticketPrice: map['ticket_price'] != null
        ? (map['ticket_price'] as num).toInt()
        : 0,
    airConditioned: map['air_conditioned'] ?? false,
    driverName: map['driver_name'] ?? '',
    carName: map['car_name'] ?? '',
    nombreDePlace: map['nombre_de_place'] ?? 0,
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
      ticketPrice: map['ticket_price']?.toInt() ?? 0,
      airConditioned: map['air_conditioned'] ?? false,
      driverName: map['driver_name'] ?? '',
      carName: map['car_name'] ?? '',
      nombreDePlace: map['nombre_de_place'] ?? 0,
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
