class NotificationModel {
  final String idNotification;
  final String idUser;
  final DateTime dateHeure;
  final String context; // Peut-être remplacé par un Enum selon le contexte
  final String message;

  NotificationModel({
    required this.idNotification,
    required this.idUser,
    required this.dateHeure,
    required this.context,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_notification': idNotification,
      'id_user': idUser,
      'date_heure': dateHeure.toIso8601String(),
      'context': context,
      'message': message,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      idNotification: map['id_notification'],
      idUser: map['id_user'],
      dateHeure: DateTime.parse(map['date_heure']),
      context: map['context'],
      message: map['message'],
    );
  }
}