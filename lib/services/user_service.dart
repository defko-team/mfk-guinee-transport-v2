import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/account_model.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> users = [];
    QuerySnapshot querySnapshot = await _firestore.collection('Users').get();
    for (var doc in querySnapshot.docs) {
      users.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return users;
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");
      
      if (userId == null) {
        return null;
      }
      
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();
          
      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(userId).get();
    if (!userDoc.exists) {
      return null;
    } 
    return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
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

  Future<void> createAccount(AccountModel account) async {
    await _firestore
        .collection('Accounts')
        .doc(account.idAccount)
        .set(account.toMap());
  }

  Future<List<UserModel>> getChauffeurs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('role', isEqualTo: 'Chauffeur')
          .get();
          
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting chauffeurs: $e');
      return [];
    }
  }

  Stream<List<UserModel>> getUsersByRoleStream(String role) {
    return _firestore
        .collection('Users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('role', isEqualTo: role)
          .get();
          
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }
}
