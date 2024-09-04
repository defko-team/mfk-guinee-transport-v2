import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/components/custom_app_bar.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  static const Color lightGrey = Color(0xFFF2F2F2);

  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _role;

  String? selectedDeparture;
  String? selectedArrival;
  int selectedType = -1;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      DocumentSnapshot roleDoc = await FirebaseFirestore.instance
          .collection('roles')
          .doc(userDoc['id_role'])
          .get();

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

  void _onSearch() {
    if (selectedDeparture != null &&
        selectedArrival != null &&
        selectedType != -1) {
      // Here you can handle the search logic
      print(
          "Departure: $selectedDeparture, Arrival: $selectedArrival, Type: $selectedType");
      // You might want to navigate to another page or make a request with the gathered data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Unfocus the text fields when tapping outside
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: CustomAppBar(
          userName: "$_firstName ${_lastName?[0].toUpperCase()}.",
          avatarUrl: "https://avatar.iran.liara.run/public/48",
        ),
        body: _userId == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Où allez-vous aujourd'hui ?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    LocationForm(
                      onDepartureChanged: (departure) {
                        setState(() {
                          selectedDeparture = departure;
                        });
                      },
                      onArrivalChanged: (arrival) {
                        setState(() {
                          selectedArrival = arrival;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Quel moyen de transport ?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LocationType(
                      onTypeSelected: (type) {
                        setState(() {
                          selectedType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _onSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedType != -1 ? AppColors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Rechercher les voitures',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Votre dernier voyage",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
