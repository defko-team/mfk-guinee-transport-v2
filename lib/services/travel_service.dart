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
      print(travel.toString());
      if (travel.departureStationId != null &&
          travel.destinationStationId != null) {
        travel.departureStation =
            await _stationService.getStationById(travel.departureStationId!);
        travel.destinationStation =
            await _stationService.getStationById(travel.destinationStationId!);
      }
      travels.add(travel);
    }
    return travels;
  }

  Stream<List<TravelModel>> travelStream() {
    return _firestore.collection('Travel').snapshots().asyncMap(
      (QuerySnapshot travelQuerySnapshot) async {
        List<TravelModel> travels = [];
        for (QueryDocumentSnapshot travelDoc in travelQuerySnapshot.docs) {
          TravelModel travel =
              TravelModel.fromMap(travelDoc.data() as Map<String, dynamic>);
          travel.travelReference = travelDoc.reference;
          if ((travel.departureStationId != null) &&
              (travel.destinationStationId != null)) {
            String departureStationId = travel.departureStationId!;
            String destinationStationId = travel.destinationStationId!;
            travel.departureStation =
                await _stationService.getStationById(departureStationId);

            travel.destinationStation =
                await _stationService.getStationById(destinationStationId);
          }
          travels.add(travel); // Add the travel to the list
        }
        return travels;
      },
    );
  }

  // Get travel by departureStationId and destinationStationId
  Future<List<TravelModel>> getTravelsByStations(
      String departureStationId, String destinationStationId) async {
    List<TravelModel> travels = [];
    DocumentReference departureStationRef =
        _firestore.collection('Station').doc(departureStationId);
    DocumentReference destinationStationRef =
        _firestore.collection('Station').doc(destinationStationId);

    DocumentSnapshot departureStationSnapshot = await departureStationRef.get();
    StationModel departureStation =
        StationModel.fromDocument(departureStationSnapshot);

    DocumentSnapshot destinationStationSnapshot =
        await destinationStationRef.get();
    StationModel destinationStation =
        StationModel.fromDocument(destinationStationSnapshot);

    QuerySnapshot travelQuerySnapshot = await _firestore
        .collection('Travel')
        .where('departure_station', isEqualTo: departureStationRef)
        .where('destination_station', isEqualTo: destinationStationRef)
        .get();

    for (QueryDocumentSnapshot travelDoc in travelQuerySnapshot.docs) {
      // Get Travel data
      Map<String, dynamic> travelData =
          travelDoc.data() as Map<String, dynamic>;
      TravelModel travel = TravelModel.fromMapStation(
          travelData, departureStation, destinationStation);

      travel.travelReference = travelDoc.reference;
      // Now you have both travel and station data

      if(travel.remainingSeats > 0) {
        travels.add(travel);
      }
    }

    return travels;
  }

  // Get travel by id

  Future<TravelModel> getTravelById(String travelId) async {
    DocumentSnapshot travelDoc =
        await _firestore.collection('Travel').doc(travelId).get();
    return TravelModel.fromMap(travelDoc.data() as Map<String, dynamic>);
  }

  Future<String?> createTravel(TravelModel travel) async {
    try {
      String travelId = _firestore.collection('Travel').doc().id;
      await _firestore.collection('Travel').doc(travelId).set(travel.toMap());
      return travelId;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateTravel(TravelModel travel) async {
    await _firestore.collection('Travel').doc(travel.id).update(travel.toMap());
  }

  Future<void> decrementRemainingSeats(String travelId) async {
    await _firestore.collection('Travel').doc(travelId).update({
      'remaining_seats': FieldValue.increment(-1)
    });
    
  }

  Future<bool> deleteTravel(String travelId) async {
    try {
      await _firestore.collection('Travel').doc(travelId).delete();
      return true;
    } catch (error) {
      return false;
    }
  }
}
