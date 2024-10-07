import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/station_service.dart';

class TravelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StationService _stationService = StationService();
  Future<List<TravelModel>> getAllTravels() async {
    List<TravelModel> travels = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Travel').get();
    for (var doc in querySnapshot.docs) {
      TravelModel travel =
          TravelModel.fromMap(doc.data() as Map<String, dynamic>);
      travel.travelReference = doc.reference;
      travel.departureStation =
          await _stationService.getStationById(travel.departureStationId!.id);
      travel.destinationStation =
          await _stationService.getStationById(travel.destinationStationId!.id);
      travels.add(travel);
    }
    return travels;
  }

  // Get travel by departureStationId and destinationStationId
  Future<List<TravelModel>> getTravelsByStations(
      String departureStationId, String destinationStationId) async {
    List<TravelModel> travels = [];

    QuerySnapshot querySnapshot = await _firestore
        .collection('Travel')
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
    DocumentSnapshot travelDoc =
        await _firestore.collection('Travel').doc(travelId).get();
    return TravelModel.fromMap(travelDoc.data() as Map<String, dynamic>);
  }

  Future<void> createTravel(TravelModel travel) async {
    await _firestore.collection('Travel').doc(travel.id).set(travel.toMap());
  }

  Future<void> updateTravel(TravelModel travel) async {
    await _firestore.collection('Travel').doc(travel.id).update(travel.toMap());
  }

  /*Future<void> deleteTravel(String travelId) async {
    await _firestore.collection('Travel').doc(travelId).delete();
  }*/

  Future<bool> deleteTravel(String travelId) async {
    try {
      await _firestore.collection('Travel').doc(travelId).delete();
      return true; // Return true if deletion is successful
    } catch (error) {
      return false;
    }
  }
}
