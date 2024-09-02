import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/travel.dart';

class TravelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TravelModel>> getAllTravels() async {
    List<TravelModel> travels = [];
    QuerySnapshot querySnapshot = await _firestore.collection('travels').get();
    for (var doc in querySnapshot.docs) {
      travels.add(TravelModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return travels;
  }

  Future<TravelModel> getTravelById(String travelId) async {
    DocumentSnapshot travelDoc = await _firestore.collection('travels').doc(travelId).get();
    return TravelModel.fromMap(travelDoc.data() as Map<String, dynamic>);
  }

  Future<void> createTravel(TravelModel travel) async {
    await _firestore.collection('travels').doc(travel.id).set(travel.toMap());
  }

  Future<void> updateTravel(TravelModel travel) async {
    await _firestore.collection('travels').doc(travel.id).update(travel.toMap());
  }

  Future<void> deleteTravel(String travelId) async {
    await _firestore.collection('travels').doc(travelId).delete();
  }
}