import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class StationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _stationsCollection =
      FirebaseFirestore.instance.collection('Station');

  // Get all stations
  Stream<List<StationModel>> getStations() {
    return _stationsCollection.snapshots().map((snapshot) {
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
    // Generate a new document reference
    final docRef = _firestore.collection('Station').doc();
    // Create a new StationModel with id set to the document ID
    final stationWithId = StationModel(
      id: docRef.id,
      name: station.name,
      latitude: station.latitude,
      longitude: station.longitude,
      address: station.address,
      docId: docRef.id,
      stationRef: docRef,
    );
    await docRef.set(stationWithId.toMap());
  }

  // Add new station
  Future<void> addStation(StationModel station) async {
    // Generate a new document reference
    final docRef = _stationsCollection.doc();
    final stationWithId = StationModel(
      id: docRef.id,
      name: station.name,
      latitude: station.latitude,
      longitude: station.longitude,
      address: station.address,
      docId: docRef.id,
      stationRef: docRef,
    );
    await docRef.set(stationWithId.toMap());
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
