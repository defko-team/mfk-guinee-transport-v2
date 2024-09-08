import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/components/custom_app_bar.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/services/station_service.dart';
import 'package:mfk_guinee_transport/views/available_cars.dart';
import 'package:mfk_guinee_transport/views/user_profile.dart';
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

  StationModel? selectedDeparture;
  StationModel? selectedArrival;

  int _selectedIndex = 0;

  int selectedTransportTypeIndex = -1;
  List<StationModel> locations = [];

  final StationService _stationService = StationService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadingStation();
  }

  Future<void> _loadingStation() async {
    List<StationModel> data = await _stationService.getAllStations();

    setState(() {
      locations = data;
    });
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
        selectedTransportTypeIndex != -1) {
      // Here you can handle the search logic
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (content) => AvailableCarsPage(
              reservationInfo: {
                'selectedDeparture': selectedDeparture?.id,
                'selectedArrival': selectedArrival?.id,
                'type': selectedTransportTypeIndex,
                'userId': _userId,
              },
            ),
          ));
      // You might want to navigate to another page or make a request with the gathered data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool formIsValid = selectedDeparture != null &&
        selectedArrival != null &&
        selectedTransportTypeIndex != -1;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Unfocus the text fields when tapping outside
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
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return const Center(
                          child: Text("Erreur lors du chargement des données"));
                    }

                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String userName =
                        "${userData['prenom']} ${userData['nom'][0].toUpperCase()}.";
                    String avatarUrl = userData['photo_profil'] ??
                        'assets/images/default_avatar.png';

                    return CustomAppBar(
                      userName: userName,
                      avatarUrl: avatarUrl,
                    );
                  },
                ),
              ),
        body: _userId == null
            ? const Center(child: CircularProgressIndicator())
            : Container(
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
                          var selectedDepartureFound = locations.where(
                              (location) =>
                                  location.name.toLowerCase() ==
                                  departure.toLowerCase());

                          selectedDeparture = selectedDepartureFound.isNotEmpty
                              ? selectedDepartureFound.first
                              : null;
                        });
                      },
                      onArrivalChanged: (arrival) {
                        setState(() {
                          var selectedArrivalFound = locations.where(
                              (location) =>
                                  location.name.toLowerCase() ==
                                  arrival.toLowerCase());

                          selectedArrival = selectedArrivalFound.isNotEmpty
                              ? selectedArrivalFound.first
                              : null;
                        });
                      },
                      locations: locations,
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
                          selectedTransportTypeIndex = type;
                        });
                      },
                    ),
                    const Spacer(),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomElevatedButton(
                          onSearch: formIsValid ? _onSearch : () {},
                          backgroundColor:
                              formIsValid ? AppColors.green : AppColors.grey,
                          text: "Rechercher",
                        )),
                  ],
                ),
              ),
      ),
    );
  }
}
