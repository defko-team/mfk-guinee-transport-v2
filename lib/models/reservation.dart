import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/travel.dart';

class ReservationModel {
  late final String? id;
  final TravelModel travelModel;
  final ReservationStatus status;
  final DocumentReference userReference;

  ReservationModel(
      {this.id,
      required this.travelModel,
      required this.status,
      required this.userReference});

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
        id: map['id'],
        travelModel: map['travel'],
        status: map['status'],
        userReference: map['userReference']);
  }
}

enum ReservationStatus { completed, confirmed, canceled }
