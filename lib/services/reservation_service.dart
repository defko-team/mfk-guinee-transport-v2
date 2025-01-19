import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService userService = new UserService();

  // Save a ReservationModel to Firestore
  Future<void> saveReservation(ReservationModel reservation) async {
    try {
      DocumentReference docRef = _firestore.collection('Reservation').doc();

      // Assigning a new ID to the reservation object if it doesn't have one
      final reservationWithId = reservation.id == null
          ? reservation.copyWith(id: docRef.id)
          : reservation;

      // Saving the reservation to Firestore
      await docRef.set(reservationWithId.toMap());

      print('Reservation saved successfully!');
    } catch (e) {
      print('Failed to save reservation: $e');
      throw Exception('Error saving reservation');
    }
  }

  // Create a new reservation for current user
  Future<void> createUserReservation(ReservationModel reservation) async {
    UserModel user = await userService.getCurrentUser();
    var res = reservation.copyWith(userId: user.idUser);
    await _firestore.collection('Reservation').add(res.toMap());
  }

  Stream<List<ReservationModel>> reservationStream() {
    return _firestore
        .collection('Reservation')
        .snapshots()
        .asyncMap((QuerySnapshot reservationQuerySnapshot) async {
      List<ReservationModel> reservations = [];

      for (QueryDocumentSnapshot reservationDoc
          in reservationQuerySnapshot.docs) {
        ReservationModel reservationModel = ReservationModel.fromMap(
            reservationDoc.data() as Map<String, dynamic>);
        reservationModel.id = reservationDoc.reference.id;
        reservations.add(reservationModel);
        print("reservation: ${reservationModel.ticketPrice}");
      }
      return reservations;
    });
  }

  Stream<List<ReservationModel>> userReservationStream(String userId) {
    return _firestore
        .collection('Reservation')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .asyncMap((QuerySnapshot reservationQuerySnapshot) async {
      List<ReservationModel> reservations = [];

      for (QueryDocumentSnapshot reservationDoc
          in reservationQuerySnapshot.docs) {
        ReservationModel reservationModel = ReservationModel.fromMap(
            reservationDoc.data() as Map<String, dynamic>);
        reservationModel.id = reservationDoc.reference.id;
        reservations.add(reservationModel);
      }
      return reservations;
    });
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    await _firestore
        .collection('Reservation')
        .doc(reservation.id!)
        .update(reservation.toMap());
  }
}
