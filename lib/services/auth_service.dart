import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/models/account_model.dart';
import 'package:mfk_guinee_transport/models/role_model.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> sendOtp(String phoneNumber) async {
    try {
      final Completer<String> completer = Completer<String>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          completer.complete(null); // Signifie que la vérification automatique a réussi
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(OtpVerificationException('OTP verification failed: ${e.message}'));
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          completer.complete(verificationId);
        },
        timeout: const Duration(seconds: 60),
      );

      return completer.future;
    } catch (e) {
      throw OtpVerificationException('Failed to obtain verification ID');
    }
  }

  Future<void> verifyOtpAndRegisterUser({
    required String otp,
    required String prenom,
    required String nom,
    required String telephone,
    required String verificationId,
    required bool isRegistration,
    required BuildContext context
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      String userId = userCredential.user!.uid;

      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        if (isRegistration) {
          throw Exception('L\'utilisateur existe déjà.');
        } else {
        
          UserModel userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          await _storeUserInPreferences(userId);
          await _redirectUserBasedOnRole(userModel.idRole, context);
        }
      } else {
        if (!isRegistration) {
          throw Exception('Aucun compte trouvé avec ce numéro de téléphone.');
        }

        String roleId = _firestore.collection('roles').doc().id;
        String accountId = _firestore.collection('Accounts').doc().id;

        DocumentSnapshot roleDoc = await _firestore.collection('roles').doc('Client').get();

        if (!roleDoc.exists) {
          RoleModel roleModel = RoleModel(
            idRole: roleId,
            nom: 'Client',
          );
          await _firestore.collection('roles').doc(roleId).set(roleModel.toMap());
        } else {
          roleId = roleDoc.id;
        }

        UserModel userModel = UserModel(
          idUser: userId,
          prenom: prenom,
          nom: nom,
          telephone: telephone,
          photoProfil: null,
          idRole: roleId,
        );

        AccountModel accountModel = AccountModel(
          idAccount: accountId,
          idUser: userId,
          statut: 'Active',
          dateCreation: DateTime.now(),
        );

        await _firestore.collection('Users').doc(userId).set(userModel.toMap());
        await _firestore.collection('Accounts').doc(accountId).set(accountModel.toMap());

        await _storeUserInPreferences(userId);
        await _redirectUserBasedOnRole(roleId, context);  // Passer le context ici
      }
    } catch (e) {
      throw Exception('La vérification OTP a échoué : ${e.toString()}');
    }
  }

  Future<void> _storeUserInPreferences(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();
    DocumentSnapshot roleDoc = await _firestore.collection('roles').doc(userDoc['id_role']).get();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("userId", userId);

    if (roleDoc['nom'] == 'Client') {
      prefs.setBool("isCustomerAuthenticated", true);
      prefs.setBool("isProviderAuthenticated", false);
    } else if (roleDoc['nom'] == 'Provider') {
      prefs.setBool("isCustomerAuthenticated", false);
      prefs.setBool("isProviderAuthenticated", true);
    }
  }

  Future<void> _redirectUserBasedOnRole(String roleId, BuildContext context) async {
    DocumentSnapshot roleDoc = await _firestore.collection('roles').doc(roleId).get();
    String roleName = roleDoc['nom'];

    if (roleName == 'Client') {
      Navigator.pushReplacementNamed(context, '/customerHome');
    } else if (roleName == 'Provider') {
      Navigator.pushReplacementNamed(context, '/providerHome');
    } else {
      throw Exception('Rôle inconnu : $roleName');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }
}

class OtpVerificationException implements Exception {
  final String message;
  OtpVerificationException(this.message);

  @override
  String toString() => 'OtpVerificationException: $message';
}
