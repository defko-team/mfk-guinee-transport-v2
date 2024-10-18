import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';

class ReservationService {
  final CollectionReference reservationCollection =
      FirebaseFirestore.instance.collection('reservation');

  // Method to get all reservations for a specific user with optional filters
  Future<List<ReservationModel>> getUserReservations({
    required String userId,
    DateTime? startTimeFilter,
    String? statusFilter,
    String? carNameFilter,
  }) async {
    try {
      Query query = reservationCollection.where('user_id', isEqualTo: userId);

      // Apply optional filters if they are provided
      if (startTimeFilter != null) {
        query =
            query.where('start_time', isGreaterThanOrEqualTo: startTimeFilter);
      }

      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      if (carNameFilter != null && carNameFilter.isNotEmpty) {
        query = query.where('car_name', isEqualTo: carNameFilter);
      }

      // Execute the query
      QuerySnapshot querySnapshot = await query.get();

      // Convert documents into ReservationModel model instances
      List<ReservationModel> reservations = querySnapshot.docs.map((doc) {
        return ReservationModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return reservations;
    } catch (e) {
      print('Error fetching reservations: $e');
      return [];
    }
  }
}
