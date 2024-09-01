import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/components/custom_app_bar.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/views/user_profile.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  static const Color lightGrey = Color(0xFFF2F2F2);

  String? _userId;
  int selectedType = -1;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("userId");
    });
  }

  void _onSearch() {
    // Logique de recherche
  }

  void _onItemTapped(int index) async {
    if (index == 3) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
      if (result == true) {
        setState(() {});
      } else {
        setState(() {
          _selectedIndex = 0;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: _userId == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(135),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(_userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text("Erreur lors du chargement des données"));
                    }
                    
                    var userData = snapshot.data!.data() as Map<String, dynamic>;
                    String userName = "${userData['prenom']} ${userData['nom'][0].toUpperCase()}.";
                    String avatarUrl = userData['photo_profil'] ?? 'assets/images/default_avatar.png';

                    return CustomAppBar(
                      userName: userName,
                      avatarUrl: avatarUrl,
                    );
                  },
                ),
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
                          // Logique de gestion du départ
                        });
                      },
                      onArrivalChanged: (arrival) {
                        setState(() {
                          // Logique de gestion de l'arrivée
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
                        backgroundColor: selectedType != -1 ? AppColors.green : Colors.grey,
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
                    // Ajouter le contenu du dernier voyage ici
                  ],
                ),
              ),
        bottomNavigationBar: _userId == null
            ? null
            : BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: Colors.green,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    label: 'Gares',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'Historique',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz),
                    label: 'Plus',
                  ),
                ],
              ),
      ),
    );
  }
}
