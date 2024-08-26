import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


// TODO : move all firestore calls to user_service.dart

// TODO : move all functions to auth_controller.dart

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    
    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      DocumentSnapshot roleDoc = await FirebaseFirestore.instance.collection('roles').doc(userDoc['id_role']).get();

      setState(() {
        _userId = userId;
        _firstName = userDoc['prenom'];
        _lastName = userDoc['nom'];
        _phoneNumber = userDoc['telephone'];
        _role = roleDoc['nom'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non trouvé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _userId == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Utilisateur: $_userId',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Prénom: $_firstName',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nom: $_lastName',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Téléphone: $_phoneNumber',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rôle: $_role',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
