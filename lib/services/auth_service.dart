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

  Future<bool> isExistingDriverNumber(String phoneNumber) async {
    try {
      // Récupérer d'abord l'ID du rôle chauffeur
      QuerySnapshot roleSnapshot = await _firestore
          .collection('roles')
          .where('nom', isEqualTo: 'Chauffeur')
          .limit(1)
          .get();

      if (roleSnapshot.docs.isEmpty) return false;
      String chauffeurRoleId = roleSnapshot.docs.first.id;

      // Vérifier si un utilisateur avec ce numéro et ce rôle existe
      QuerySnapshot userSnapshot = await _firestore
          .collection('Users')
          .where('telephone', isEqualTo: phoneNumber.replaceAll(' ', ''))
          .where('id_role', isEqualTo: chauffeurRoleId)
          .limit(1)
          .get();

      return userSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du numéro de chauffeur: $e');
      return false;
    }
  }

  Future<String?> sendOtp(String phoneNumber) async {
    try {
      final Completer<String> completer = Completer<String>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          completer.complete(null);
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(OtpVerificationException(
              'Échec de la vérification OTP: ${e.message}'));
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Ne rien faire ici pour éviter les problèmes de completion multiple
        },
        timeout: const Duration(seconds: 60),
      );

      return completer.future;
    } catch (e) {
      throw OtpVerificationException(
          'Impossible d\'obtenir l\'ID de vérification');
    }
  }

  Future<void> verifyOtpAndRegisterUser({
    required String otp,
    required String prenom,
    required String nom,
    required String telephone,
    required String verificationId,
    required bool isRegistration,
    required BuildContext context,
  }) async {
    try {
      print('=== Début de verifyOtpAndRegisterUser ===');
      print('Téléphone: $telephone');
      print('IsRegistration: $isRegistration');

      // Création des credentials avec l'OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Connexion avec les credentials
      UserCredential userCredential;
      try {
        print('Tentative de connexion avec les credentials...');
        userCredential = await _auth.signInWithCredential(credential);
        print('Connexion réussie avec userId: ${userCredential.user?.uid}');
      } on FirebaseAuthException catch (authError) {
        print('Erreur FirebaseAuth: ${authError.code} - ${authError.message}');
        if (authError.code == 'session-expired') {
          throw Exception(
              'Le code OTP a expiré. Veuillez demander un nouveau code.');
        } else if (authError.code == 'invalid-verification-code') {
          throw Exception(
              'Le code OTP est invalide. Veuillez vérifier et réessayer.');
        }
        throw Exception('Erreur d\'authentification: ${authError.message}');
      }

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception(
            'Échec de l\'authentification: aucun utilisateur trouvé');
      }

      String firebaseUserId = user.uid;
      print('Firebase UserId obtenu: $firebaseUserId');

      // Nettoyer le numéro de téléphone
      String cleanPhoneNumber = telephone.replaceAll(' ', '');

      if (isRegistration) {
        print('Mode inscription');
        // Vérifier si c'est un chauffeur existant
        bool isDriver = await isExistingDriverNumber(telephone);
        print('Est-ce un chauffeur? $isDriver');

        if (isDriver) {
          print('Traitement chauffeur existant...');
          // Récupérer le document du chauffeur
          QuerySnapshot driverDoc = await _firestore
              .collection('Users')
              .where('telephone', isEqualTo: cleanPhoneNumber)
              .limit(1)
              .get();

          print('Documents chauffeur trouvés: ${driverDoc.docs.length}');

          if (driverDoc.docs.isNotEmpty) {
            final driverSnapshot = driverDoc.docs.first;
            String driverId = driverSnapshot.id;
            Map<String, dynamic>? driverData =
                driverSnapshot.data() as Map<String, dynamic>?;

            print('Document chauffeur trouvé, ID: $driverId');
            print('Données actuelles du chauffeur:');
            print(driverData);

            await _firestore.collection('Users').doc(driverId).update({
              'idUser': firebaseUserId,
              'prenom': prenom,
              'nom': nom,
            });
            print('Document chauffeur mis à jour');

            // Vérification du compte
            QuerySnapshot accountDoc = await _firestore
                .collection('Accounts')
                .where('idUser', isEqualTo: firebaseUserId)
                .limit(1)
                .get();

            print('Compte existant? ${accountDoc.docs.isNotEmpty}');

            if (accountDoc.docs.isEmpty) {
              String accountId = _firestore.collection('Accounts').doc().id;
              AccountModel accountModel = AccountModel(
                idAccount: accountId,
                idUser: firebaseUserId,
                statut: 'Active',
                dateCreation: DateTime.now(),
              );
              await _firestore
                  .collection('Accounts')
                  .doc(accountId)
                  .set(accountModel.toMap());
              print('Nouveau compte créé avec ID: $accountId');
            }

            print('Stockage des préférences...');
            await _storeUserInPreferences(driverId);
            print('Redirection...');
            await _redirectUserBasedOnRole(driverId, context);
            print('Processus chauffeur terminé');
            return;
          }
        } else {
          print('Création d\'un nouveau compte client');
          String roleId = await _getRoleId('Client');
          print('RoleId obtenu: $roleId');
          String newUserId = _firestore.collection('Users').doc().id;
          String accountId = _firestore.collection('Accounts').doc().id;

          UserModel userModel = UserModel(
            idUser: firebaseUserId,
            prenom: prenom,
            nom: nom,
            telephone: cleanPhoneNumber,
            photoProfil: null,
            idRole: roleId,
          );

          AccountModel accountModel = AccountModel(
            idAccount: accountId,
            idUser: firebaseUserId,
            statut: 'Active',
            dateCreation: DateTime.now(),
          );

          await _firestore
              .collection('Users')
              .doc(newUserId)
              .set(userModel.toMap());
          print('Utilisateur client créé');
          await _firestore
              .collection('Accounts')
              .doc(accountId)
              .set(accountModel.toMap());
          print('Compte client créé');

          print('Stockage des préférences...');
          await _storeUserInPreferences(newUserId);
          print('Redirection...');
          await _redirectUserBasedOnRole(newUserId, context);
          return;
        }
      } else {
        print('Mode connexion');
        // Chercher l'utilisateur par numéro de téléphone
        QuerySnapshot userQuery = await _firestore
            .collection('Users')
            .where('telephone', isEqualTo: cleanPhoneNumber)
            .limit(1)
            .get();

        print('Documents utilisateur trouvés: ${userQuery.docs.length}');

        if (userQuery.docs.isEmpty) {
          throw Exception('Aucun compte trouvé avec ce numéro de téléphone.');
        }

        final userSnapshot = userQuery.docs.first;
        String firestoreUserId = userSnapshot.id;
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData == null) {
          throw Exception('Données utilisateur invalides.');
        }
        // Mettre à jour l'idUser Firebase si nécessaire
        if (userData['idUser'] != firebaseUserId) {
          await _firestore.collection('Users').doc(firestoreUserId).update({
            'idUser': firebaseUserId,
          });
        }

        await setupFcmToken(userData, firestoreUserId);
        print('Stockage final des préférences...');
        await _storeUserInPreferences(firestoreUserId);
        print('Redirection finale...');
        await _redirectUserBasedOnRole(firestoreUserId, context);
      }

      print('=== Fin de verifyOtpAndRegisterUser ===');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'session-expired') {
        throw Exception(
            'Le code OTP a expiré. Un nouveau code va vous être envoyé.');
      }
      throw Exception('Erreur d\'authentification: ${e.message}');
    } catch (e) {
      print('Erreur générale: $e');
      throw Exception('La vérification OTP a échoué : ${e.toString()}');
    }
  }

  Future<void> _storeUserInPreferences(String userId) async {
    print('=== Début _storeUserInPreferences ===');
    print('UserId reçu: $userId');

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();
      print('Document utilisateur existe? ${userDoc.exists}');
      print('Données utilisateur: ${userDoc.data()}');

      if (!userDoc.exists) {
        throw Exception('Document utilisateur non trouvé');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (!userData.containsKey('id_role')) {
        throw Exception('Champ id_role manquant dans le document utilisateur');
      }

      print('ID du rôle trouvé: ${userData['id_role']}');
      DocumentSnapshot roleDoc =
          await _firestore.collection('roles').doc(userData['id_role']).get();
      print('Document rôle existe? ${roleDoc.exists}');
      print('Données rôle: ${roleDoc.data()}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", userId);
      print("userRoleId from userData ${userData['id_role']}");
      String roleName = (roleDoc.data() as Map<String, dynamic>)['nom'];
      print('Nom du rôle: $roleName');

      switch (roleName) {
        case 'Client':
          print('Configuration des préférences pour Client');
          prefs.setBool("isCustomerAuthenticated", true);
          prefs.setBool("isProviderAuthenticated", false);
          prefs.setBool("isDriverAuthenticated", false);
          break;
        case 'Admin':
          print('Configuration des préférences pour Admin');
          prefs.setBool("isCustomerAuthenticated", false);
          prefs.setBool("isProviderAuthenticated", true);
          prefs.setBool("isDriverAuthenticated", false);
          break;
        case 'Chauffeur':
          print('Configuration des préférences pour Chauffeur');
          prefs.setBool("isCustomerAuthenticated", false);
          prefs.setBool("isProviderAuthenticated", false);
          prefs.setBool("isDriverAuthenticated", true);
          break;
      }
      print('=== Fin _storeUserInPreferences ===');
    } catch (e) {
      print('Erreur dans _storeUserInPreferences: $e');
      rethrow;
    }
  }

  Future<void> _redirectUserBasedOnRole(
      String userId, BuildContext context) async {
    print('=== Début _redirectUserBasedOnRole ===');
    print('UserId reçu: $userId');

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();
      print('Document utilisateur existe? ${userDoc.exists}');
      print('Données utilisateur: ${userDoc.data()}');

      if (!userDoc.exists) {
        print('Document utilisateur non trouvé!');
        throw Exception('Utilisateur non trouvé');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print('Données utilisateur parsées: $userData');

      if (!userData.containsKey('id_role')) {
        print('Champ id_role manquant!');
        throw Exception('Rôle non défini pour l\'utilisateur');
      }

      String roleId = userData['id_role'];
      print('ID du rôle trouvé: $roleId');

      DocumentSnapshot roleDoc =
          await _firestore.collection('roles').doc(roleId).get();
      print('Document rôle existe? ${roleDoc.exists}');
      print('Données rôle: ${roleDoc.data()}');

      if (!roleDoc.exists) {
        print('Document rôle non trouvé!');
        throw Exception('Rôle non trouvé');
      }

      String roleName = (roleDoc.data() as Map<String, dynamic>)['nom'];
      print('Nom du rôle: $roleName');

      switch (roleName) {
        case 'Client':
          print('Redirection vers customerHome');
          Navigator.pushNamedAndRemoveUntil(
              context, '/customerHome', (Route<dynamic> route) => false);
          break;
        case 'Admin':
          print('Redirection vers providerHome');
          Navigator.pushNamedAndRemoveUntil(
              context, '/providerHome', (Route<dynamic> route) => false);
          break;
        case 'Chauffeur':
          print('Redirection vers driverHome');
          Navigator.pushNamedAndRemoveUntil(
              context, '/driverHome', (Route<dynamic> route) => false);
          break;
        default:
          print('Rôle inconnu!');
          throw Exception('Rôle inconnu : $roleName');
      }

      print('=== Fin _redirectUserBasedOnRole ===');
    } catch (e) {
      print('Erreur dans _redirectUserBasedOnRole: $e');
      await signOut();
      Navigator.pushReplacementNamed(context, '/login');
      throw Exception('Erreur lors de la redirection : ${e.toString()}');
    }
  }

  Future<void> saveAdminFcmToken(String? fcmToken) async {
      await FirebaseFirestore.instance
          .collection('app_config')
          .doc('admin')
          .set({'fcm_token': fcmToken}, SetOptions(merge: true));
  }

  Future<String?> getAdminFcmToken() async {
    DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('app_config')
        .doc('admin')
        .get();
    return adminDoc.exists ? adminDoc['fcm_token'] as String? : null;
  }

  Future<void> setupFcmToken(userData, firestoreUserId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('userId');
    String? fcmToken = preferences.getString('fcmToken');
    bool? isAdmin = preferences.getBool("isProviderAuthenticated");
    if (fcmToken != null && userData['fcm_token'] != fcmToken) {
      await _firestore.collection('Users').doc(firestoreUserId).update({
        'fcm_token': fcmToken,
      });
      if (isAdmin!) {
          await saveAdminFcmToken(fcmToken);
      }
    }
  }

  Future<String> _getRoleId(String roleName) async {
    QuerySnapshot roleSnapshot = await _firestore
        .collection('roles')
        .where('nom', isEqualTo: roleName)
        .limit(1)
        .get();

    if (roleSnapshot.docs.isEmpty) {
      String roleId = _firestore.collection('roles').doc().id;
      RoleModel roleModel = RoleModel(
        idRole: roleId,
        nom: roleName,
      );
      await _firestore.collection('roles').doc(roleId).set(roleModel.toMap());
      return roleId;
    }

    return roleSnapshot.docs.first.id;
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
