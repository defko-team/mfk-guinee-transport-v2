import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/travel.dart';

class TravelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TravelModel>> getAllTravels() async {
    List<TravelModel> travels = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Travel').get();
    for (var doc in querySnapshot.docs) {
      travels.add(TravelModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return travels;
  }

  // Get travel by departureStationId and destinationStationId
  Future<List<TravelModel>> getTravelsByStations(String departureStationId, String destinationStationId) async {
    List<TravelModel> travels = [];

    QuerySnapshot querySnapshot = await _firestore.collection('Travel')
    .where('departure_station_id', isEqualTo: departureStationId)
    .where('destination_station_id', isEqualTo: destinationStationId)
    .get();

    for (var doc in querySnapshot.docs) {
      travels.add(TravelModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return travels;
  }

  // Get travel by id

  Future<TravelModel> getTravelById(String travelId) async {
    DocumentSnapshot travelDoc = await _firestore.collection('Travel').doc(travelId).get();
    return TravelModel.fromMap(travelDoc.data() as Map<String, dynamic>);
  }

  Future<void> createTravel(TravelModel travel) async {
    await _firestore.collection('Travel').doc(travel.id).set(travel.toMap());
  }

  Future<void> updateTravel(TravelModel travel) async {
    await _firestore.collection('Travel').doc(travel.id).update(travel.toMap());
  }

  Future<void> deleteTravel(String travelId) async {
    await _firestore.collection('Travel').doc(travelId).delete();
  }
}