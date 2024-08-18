import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/models/account_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;

  Future<void> sendOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('OTP verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify the OTP entered by the user and register them
  Future<void> verifyOtpAndRegisterUser({
    required String otp,
    required String prenom,
    required String nom,
    required String telephone,
  }) async {
    if (_verificationId == null) {
      throw Exception('No verification ID found. Please request an OTP first.');
    }

    try {
      // Create a PhoneAuthCredential with the OTP and verification ID
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in the user with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      String userId = userCredential.user!.uid;

      // Check if the user is already registered in Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        // Create UserModel if not registered
        UserModel userModel = UserModel(
          idUser: userId,
          prenom: prenom,
          nom: nom,
          telephone: telephone,
          photoProfil: null,
          idRole: 'Client',  // Default role
        );

        // Create AccountModel
        AccountModel accountModel = AccountModel(
          idAccount: userId,
          idUser: userId,
          statut: 'Active',
          dateCreation: DateTime.now(),
        );

        // Save to Firestore
        await _firestore.collection('users').doc(userId).set(userModel.toMap());
        await _firestore.collection('accounts').doc(userId).set(accountModel.toMap());
      }

      // Store the user in shared preferences
      await _storeUserInPreferences(userId);
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // Redirect to login page, e.g., Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Helper method to store user information in SharedPreferences
  Future<void> _storeUserInPreferences(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isProviderAuthenticated", true);
    prefs.setString("userId", userId);
    prefs.setString("userName", userDoc['prenom']);
    // Store any other necessary information from the user model
  }
}
