import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/travel_reservation_record.dart';

class TravelReservationRecordService {
  final CollectionReference _travelReservationRecordCollection =
      FirebaseFirestore.instance.collection('TravelReservationRecord');

  Stream<List<TravelReservationRecordModel>> getTravelReservationRecords() {
    return _travelReservationRecordCollection
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
      List<TravelReservationRecordModel> records = [];
      for (var doc in snapshot.docs) {
        TravelReservationRecordModel record =
            TravelReservationRecordModel.fromMap(
                doc.data() as Map<String, dynamic>);
        record.id = doc.reference.id;
        records.add(record);
      }
      return records;
    });
  }

  Future<void> addTravelReservationRecord(TravelReservationRecordModel record) {
    return _travelReservationRecordCollection.add(record.toMap());
  }

  Future<void> updateTravelReservationRecord(
      TravelReservationRecordModel record) {
    return _travelReservationRecordCollection
        .doc(record.id)
        .update(record.toMap());
  }

  Future<void> deleteTravelReservationRecord(String id) {
    return _travelReservationRecordCollection.doc(id).delete();
  }
}
