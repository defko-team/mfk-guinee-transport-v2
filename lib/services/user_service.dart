import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/role_model.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> users = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Users').get();
    for (var doc in querySnapshot.docs) {
      users.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return users;
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();
    DocumentSnapshot roleDoc = await _firestore.collection('roles').doc(userDoc['id_role']).get();
    UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    RoleModel role = RoleModel.fromMap(roleDoc.data() as Map<String, dynamic>);
    user.role = role.nom;
    return user;
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