import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save a ReservationModel to Firestore
  Future<void> saveReservation(ReservationModel reservation) async {
    try {
      DocumentReference docRef = _firestore.collection('reservation').doc();

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

  Future<void> createReservation(ReservationModel reservation) async {
    //try {
    //DocumentReference docRef =
    await _firestore.collection('Reservation').add(reservation.toMap());
    // return docRef.id;
    // } catch (e) {
    //   return null;
    // }
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
