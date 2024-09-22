import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/station_service.dart';

class TravelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<List<TravelModel>> getAllTravels() async {
    List<TravelModel> travels = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Travel').get();
    //for (var doc in querySnapshot.docs) {
    //  travels.add(TravelModel.fromMap(doc.data() as Map<String, dynamic>));
    //}
    return travels;
  }

  // Get travel by departureStationId and destinationStationId
  Future<List<TravelModel>> getTravelsByStations(String departureStationId, String destinationStationId) async {

    List<TravelModel> travels = [];
    DocumentReference departureStationRef = _firestore.collection('Station').doc(departureStationId);
    DocumentReference destinationStationRef = _firestore.collection('Station').doc(destinationStationId);

    DocumentSnapshot departureStationSnapshot = await departureStationRef.get();
    Map<String, dynamic>? departureStationData = departureStationSnapshot.data() as Map<String, dynamic>?;
    StationModel departureStation = StationModel.fromMap(departureStationData!);

    DocumentSnapshot destinationStationSnapshot = await destinationStationRef.get();
    Map<String, dynamic>? destinationStationData = destinationStationSnapshot.data() as Map<String, dynamic>?;
    StationModel destinationStation = StationModel.fromMap(destinationStationData!);

    QuerySnapshot travelQuerySnapshot = await _firestore.collection('Travel')
      .where('departure_station', isEqualTo: departureStationRef)
      .where('destination_station', isEqualTo: destinationStationRef)
      .get();

    for (QueryDocumentSnapshot travelDoc in travelQuerySnapshot.docs) {
        // Get Travel data
        Map<String, dynamic> travelData = travelDoc.data() as Map<String, dynamic>;
        TravelModel travel = TravelModel.fromMap(travelData, departureStation, destinationStation);

        // Now you have both travel and station data
        travels.add(travel);
    }

    return travels;
  }

  // Get travel by id

  //Future<TravelModel> getTravelById(String travelId) async {
  //  DocumentSnapshot travelDoc = await _firestore.collection('Travel').doc(travelId).get();
  //  return TravelModel.fromMap(travelDoc.data() as Map<String, dynamic>);
  //}

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