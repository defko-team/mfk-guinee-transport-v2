import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/car.dart';

class VoitureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all voitures
  Future<List<VoitureModel>> getAllVoitures() async {
    List<VoitureModel> voitures = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Car').get();
    for (var doc in querySnapshot.docs) {
      VoitureModel voiture =
          VoitureModel.fromMap(doc.data() as Map<String, dynamic>);
      voitures.add(voiture);
    }
    return voitures;
  }

  // Stream all voitures (for real-time updates)
  Stream<List<VoitureModel>> voitureStream() {
    return _firestore.collection('Car').snapshots().map(
      (QuerySnapshot voitureQuerySnapshot) {
        List<VoitureModel> voitures = [];
        for (QueryDocumentSnapshot voitureDoc in voitureQuerySnapshot.docs) {
          VoitureModel voiture =
              VoitureModel.fromMap(voitureDoc.data() as Map<String, dynamic>);
          voitures.add(voiture);
        }
        return voitures;
      },
    );
  }

  // Get voiture by id
  Future<VoitureModel> getVoitureById(String idVoiture) async {
    DocumentSnapshot voitureDoc =
        await _firestore.collection('Car').doc(idVoiture).get();
    return VoitureModel.fromMap(voitureDoc.data() as Map<String, dynamic>);
  }

  // Get voitures by chauffeur ID
  Future<List<VoitureModel>> getVoituresByChauffeurId(
      String idChauffeur) async {
    List<VoitureModel> voitures = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection('Car')
        .where('id_chauffeur', isEqualTo: idChauffeur)
        .get();
    for (var doc in querySnapshot.docs) {
      VoitureModel voiture =
          VoitureModel.fromMap(doc.data() as Map<String, dynamic>);
      voitures.add(voiture);
    }
    return voitures;
  }

  // Create a new voiture
  Future<void> createVoiture(VoitureModel voiture) async {
    await _firestore.collection('Car').add(voiture.toMap());
  }

  // Update an existing voiture
  Future<void> updateVoiture(VoitureModel voiture) async {
    await _firestore
        .collection('Car')
        .doc(voiture.idVoiture)
        .update(voiture.toMap());
  }

  // Delete a voiture by id
  Future<bool> deleteVoiture(String idVoiture) async {
    try {
      await _firestore.collection('Car').doc(idVoiture).delete();
      return true;
    } catch (error) {
      return false;
    }
  }
}
