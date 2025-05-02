import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/models/account_model.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isExistingDriverNumber(String phoneNumber) async {
    try {

      // Vérifier si un utilisateur avec ce numéro et ce rôle existe
      QuerySnapshot userSnapshot = await _firestore
          .collection('Users')
          .where('telephone', isEqualTo: phoneNumber.replaceAll(' ', ''))
          .where('role', isEqualTo: 'Chauffeur')
          .limit(1)
          .get();

      return userSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du numéro de chauffeur: $e');
      return false;
    }
  }

  Future<String?> sendOtp(String phoneNumber) async {
    print('phoneNumber dans sendOtp: $phoneNumber');
    try {
      Completer<String?> completer = Completer<String?>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (usually on Android)
          try {
            await _auth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(null); // No verification ID needed
            }
          } catch (e) {
            print('Erreur lors de la connexion automatique: $e');
            if (!completer.isCompleted) {
              completer.completeError(e);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Échec de la vérification: ${e.code} - ${e.message}');
          
          String errorMessage = 'Échec de la vérification';
          
          // Personnaliser les messages d'erreur
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Le numéro de téléphone est invalide. Veuillez vérifier le format.';
              break;
            case 'too-many-requests':
              errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
              break;
            case 'quota-exceeded':
              errorMessage = 'Quota dépassé. Veuillez contacter le support.';
              break;
            default:
              errorMessage = 'Erreur de vérification: ${e.message}';
          }
          
          if (!completer.isCompleted) {
            completer.completeError(Exception(errorMessage));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code envoyé, verificationId: $verificationId');
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Délai d\'attente expiré pour la récupération automatique du code');
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        timeout: const Duration(seconds: 120),
      );

      return await completer.future;
    } catch (e) {
      print('Erreur dans sendOtp: $e');
      
      // Vérifier si le numéro de téléphone est au bon format
      if (!phoneNumber.startsWith('+')) {
        throw Exception('Le numéro de téléphone doit commencer par le code pays (+xxx)');
      }
      
      rethrow;
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

          UserModel userModel = UserModel(
            idUser: firebaseUserId,
            prenom: prenom,
            nom: nom,
            telephone: cleanPhoneNumber,
            photoProfil: null,
            role: UserRole.Client,
          );

          AccountModel accountModel = AccountModel(
            idAccount: firebaseUserId,
            idUser: firebaseUserId,
            statut: 'Active',
            dateCreation: DateTime.now(),
          );

          await UserService().createUser(userModel);
          print('Utilisateur client créé');

          await UserService().createAccount(accountModel);
          print('Compte client créé');

          print('Stockage des préférences...');
          await _storeUserInPreferences(firebaseUserId);

          print('Redirection...');
          await _redirectUserBasedOnRole(firebaseUserId, context);
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
      UserModel? user = await UserService().getUserById(userId);
      print('Document utilisateur existe? ${user != null}');
      
      if (user == null) {
        throw Exception('Document utilisateur non trouvé');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", userId);

      switch (user.role) {
        case UserRole.Client:
          print('Configuration des préférences pour Client');
          prefs.setBool("isCustomerAuthenticated", true);
          prefs.setBool("isProviderAuthenticated", false);
          prefs.setBool("isDriverAuthenticated", false);
          break;
        case UserRole.Admin:
          print('Configuration des préférences pour Admin');
          prefs.setBool("isCustomerAuthenticated", false);
          prefs.setBool("isProviderAuthenticated", true);
          prefs.setBool("isDriverAuthenticated", false);
          break;
        case UserRole.Chauffeur:
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
      UserModel? user = await UserService().getUserById(userId);
      print('Document utilisateur existe? ${user != null}');
      
      if (user == null) {
        print('Document utilisateur non trouvé!');
        throw Exception('Utilisateur non trouvé');
      }

      switch (user.role) {
        case UserRole.Client:
          print('Redirection vers customerHome');
          Navigator.pushNamedAndRemoveUntil(
              context, '/customerHome', (Route<dynamic> route) => false);
          break;
        case UserRole.Admin:
          print('Redirection vers providerHome');
          Navigator.pushNamedAndRemoveUntil(
              context, '/providerHome', (Route<dynamic> route) => false);
          break;
        case UserRole.Chauffeur:
          print('Redirection vers driverHome');
          Navigator.pushNamedAndRemoveUntil(
              context, '/driverHome', (Route<dynamic> route) => false);
          break;
        default:
          print('Rôle inconnu!');
          throw Exception('Rôle inconnu : ${user.role}');
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
