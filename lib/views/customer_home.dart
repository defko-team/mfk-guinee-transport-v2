import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
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
      // Gérer le cas où l'utilisateur n'est pas trouvé
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non trouvé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _userId == null
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Utilisateur: $_userId',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Prénom: $_firstName',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Nom: $_lastName',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Téléphone: $_phoneNumber',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Rôle: $_role',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
