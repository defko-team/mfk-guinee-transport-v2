import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/models/role_model.dart';
import 'package:mfk_guinee_transport/models/account_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> isConnectedToInternet() async {
  try {
    final result = await InternetAddress.lookup('www.google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
  return false;
}

Future<void> createDefaultAdmin() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  const String defaultAdminPhone = '+221778445637';

  try {
    QuerySnapshot userSnapshot = await firestore
        .collection('Users')
        .where('telephone', isEqualTo: defaultAdminPhone)
        .get();

    if (userSnapshot.docs.isEmpty) {
      // Create a new admin user in Firestore
      String userId = firestore.collection('Users').doc().id;
      String roleId = firestore.collection('roles').doc().id;
      String accountId = firestore.collection('Accounts').doc().id;

      // Create the role 'Admin' if it doesn't exist
      DocumentSnapshot roleDoc = await firestore.collection('roles').doc('Admin').get();
      if (!roleDoc.exists) {
        RoleModel adminRole = RoleModel(idRole: roleId, nom: 'Admin');
        await firestore.collection('roles').doc(roleId).set(adminRole.toMap());
      } else {
        roleId = roleDoc.id;
      }

      // Create the admin user in Firestore
      UserModel adminUser = UserModel(
        idUser: userId,
        prenom: 'Admin',
        nom: 'User',
        telephone: defaultAdminPhone,
        idRole: roleId,
      );
      await firestore.collection('Users').doc(userId).set(adminUser.toMap());

      // Create the admin's account
      AccountModel adminAccount = AccountModel(
        idAccount: accountId,
        idUser: userId,
        statut: 'Active',
        dateCreation: DateTime.now(),
      );
      await firestore.collection('Accounts').doc(accountId).set(adminAccount.toMap());

      // Here we use the predefined OTP method to sign in the admin
      // Start the phone number verification process with the default phone number
      await auth.verifyPhoneNumber(
        phoneNumber: defaultAdminPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          print('Admin user signed in without OTP verification.');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Automatically provide the default OTP (223344)
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: '223344',
          );
          await auth.signInWithCredential(credential);
          print('Admin signed in using default OTP.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code auto-retrieval timeout.');
        },
        timeout: const Duration(seconds: 60), // Timeout duration
      );
    }
  } catch (e) {
    print('Error creating default admin: $e');
  }
}