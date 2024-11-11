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
}
