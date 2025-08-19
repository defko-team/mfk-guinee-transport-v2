import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? idNotification;
  final String idUser;
  final DateTime dateHeure;
  final String context; // Peut-être remplacé par un Enum selon le contexte
  final String message;
  bool status;

  NotificationModel({
    this.idNotification,
    required this.idUser,
    required this.dateHeure,
    required this.context,
    required this.message,
    required this.status
  });

  Map<String, dynamic> toMap() {
    return {
      'id_notification': idNotification,
      'id_user': idUser,
      'dateHeure': dateHeure,
      'context': context,
      'message': message,
      'status': status
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      idUser: map['id_user'],
      dateHeure: (map['dateHeure'] as Timestamp).toDate(),
      context: map['context'],
      status: map['status'],
      message: map['message'],
    );
  }
}