import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station.dart';

class StationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _stationsCollection =
      FirebaseFirestore.instance.collection('Station');

  // Get all stations
  Stream<List<StationModel>> getStations() {
    return _stationsCollection.snapshots().map((snapshot) {
      print('snapshot: ${snapshot.docs}');
      return snapshot.docs
          .map((doc) => StationModel.fromDocument(doc))
          .toList();
    });
  }

  Future<List<StationModel>> getAllStations() async {
    List<StationModel> stations = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Station').get();
    for (var doc in querySnapshot.docs) {
      StationModel station = StationModel.fromDocument(doc);
      station.stationRef = doc.reference;
      stations.add(station);
    }
    return stations;
  }

  Future<StationModel> getStationById(String stationId) async {
    DocumentSnapshot stationDoc =
        await _firestore.collection('Station').doc(stationId).get();
    StationModel station =
        StationModel.fromMap(stationDoc.data() as Map<String, dynamic>);
    station.stationRef = stationDoc.reference;
    return station;
  }

  Future<void> createStation(StationModel station) async {
    await _firestore.collection('Station').doc(station.id).set(station.toMap());
  }

  // Add new station
  Future<void> addStation(StationModel station) async {
    await _stationsCollection.add(station.toMap());
  }

  Future<void> updateStation(StationModel station) async {
    await _firestore
        .collection('Station')
        .doc(station.id)
        .update(station.toMap());
  }

  Future<void> deleteStation(String stationId) async {
    await _firestore.collection('Station').doc(stationId).delete();
  }
}
