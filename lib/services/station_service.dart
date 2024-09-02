import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class StationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<StationModel>> getAllStations() async {
    List<StationModel> stations = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Station').get();
    for (var doc in querySnapshot.docs) {
      stations.add(StationModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return stations;
  }

  Future<StationModel> getStationById(String stationId) async {
    DocumentSnapshot stationDoc = await _firestore.collection('stations').doc(stationId).get();
    return StationModel.fromMap(stationDoc.data() as Map<String, dynamic>);
  }

  Future<void> createStation(StationModel station) async {
    await _firestore.collection('stations').doc(station.id).set(station.toMap());
  }

  Future<void> updateStation(StationModel station) async {
    await _firestore.collection('stations').doc(station.id).update(station.toMap());
  }

  Future<void> deleteStation(String stationId) async {
    await _firestore.collection('stations').doc(stationId).delete();
  }
}
