import 'package:cloud_firestore/cloud_firestore.dart';

class TravelReservationRecordModel {
  late final String? id;
  late final String idTravel;
  late final String idUser;
  late final String passengerLastName;
  late final String passengerFirstName;
  late final DateTime date;
  TravelReservationStatus status;

  TravelReservationRecordModel({
    this.id,
    required this.idTravel,
    required this.idUser,
    required this.date,
    required this.status,
    required this.passengerLastName,
    required this.passengerFirstName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idTravel': idTravel,
      'idUser': idUser,
      'date': date,
      'status': status,
      'passengerLastName': passengerLastName,
      'passengerFirstName': passengerFirstName,
    };
  }

  factory TravelReservationRecordModel.fromMap(Map<String, dynamic> map) {
    return TravelReservationRecordModel(
      id: map['id'],
      idTravel: map['idTravel'],
      idUser: map['idUser'],
      date: (map['date'] as Timestamp).toDate(),
      status: travelReservationStatus[map['status']]!,
      passengerLastName: map['passengerLastName'],
      passengerFirstName: map['passengerFirstName'],
    );
  }

  @override
  String toString() {
    return 'TravelReservationRecordModel{id: $id, idTravel: $idTravel, idUser: $idUser, date: $date, status: $status, passengerLastName: $passengerLastName, passengerFirstName: $passengerFirstName}';
  }
}

Map<String, TravelReservationStatus> travelReservationStatus = {
  "completed": TravelReservationStatus.completed,
  "confirmed": TravelReservationStatus.confirmed,
  "canceled": TravelReservationStatus.canceled,
  "pending": TravelReservationStatus.pending,
  "unknown": TravelReservationStatus.unknown,
};

enum TravelReservationStatus {
  unknown,
  pending,
  completed,
  confirmed,
  canceled
}
