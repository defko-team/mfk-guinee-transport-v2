import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';

class UserService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> users = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Users').get();
    for (var doc in querySnapshot.docs) {
      users.add(UserModel.fromMap(doc as Map<String, dynamic>));
    }
    return users;
  }

  Future<UserModel> getUserById(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();
    return UserModel.fromMap(userDoc as Map<String, dynamic>);
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('Users').doc(user.idUser).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('Users').doc(user.idUser).update(user.toMap());
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('Users').doc(userId).delete();
  }
}