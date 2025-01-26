import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';
import 'package:mfk_guinee_transport/components/custom_app_bar.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:intl/intl.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  static const Color lightGrey = Color(0xFFF2F2F2);
  String? _userId;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId != null) {
      setState(() {
        _userId = userId;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Sélectionner une période')]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String userName =
                      "${userData['prenom']} ${userData['nom'][0].toUpperCase()}.";
                  String avatarUrl = userData['photo_profil'] ??
                      'assets/images/default_avatar.png';

                  return CurrentUserAppBar(
                    actions: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterModal,
                    ),
                  );
                },
              ),
            ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : TravelsList(driverId: _userId!),
    );
  }
}

class TravelsList extends StatelessWidget {
  final String driverId;

  const TravelsList({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    // Get today's date range
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Travel')
          // TODO: Adapter la requête en fonction de comment vous stockez l'identifiant du chauffeur
          // Pour le moment, on récupère tous les trajets du jour
          //.where('driver_name', isEqualTo: driverId)
          .where('start_time', isGreaterThanOrEqualTo: startOfDay)
          .where('start_time', isLessThanOrEqualTo: endOfDay)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Erreur Firestore: ${snapshot.error}');
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucun trajet prévu aujourd\'hui'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final travelData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final travel = TravelModel.fromMap(travelData);

            return TravelCard(
              travel: travel,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TravelCustomersList(travelId: travel.id!),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class TravelCard extends StatelessWidget {
  final TravelModel travel;
  final VoidCallback onTap;

  const TravelCard({
    super.key,
    required this.travel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0, // Supprime l'ombre
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFFFAFAFA), // Blanc très léger
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('HH:mm').format(travel.startTime),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF6FF), // Bleu très clair
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${travel.remainingSeats} places',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FutureBuilder<List<DocumentSnapshot>>(
                      future: Future.wait([
                        FirebaseFirestore.instance
                            .collection('Station')
                            .doc(travel.departureStationId)
                            .get(),
                        FirebaseFirestore.instance
                            .collection('Station')
                            .doc(travel.destinationStationId)
                            .get(),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Chargement des stations...');
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text(
                              'Erreur de chargement des stations');
                        }

                        try {
                          final departureStation =
                              StationModel.fromDocument(snapshot.data![0]);
                          final destinationStation =
                              StationModel.fromDocument(snapshot.data![1]);

                          return Text(
                            '${departureStation.name} → ${destinationStation.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          );
                        } catch (e) {
                          return const Text('Erreur de format des stations');
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (travel.airConditioned == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.ac_unit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Climatisé'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TravelCustomersList extends StatelessWidget {
  final String travelId;

  const TravelCustomersList({super.key, required this.travelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF30BE76)),
        title: const Text(
          'Liste des passagers',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reservation')
            .where('travel_id', isEqualTo: travelId)
            .where('status', isEqualTo: ReservationStatus.confirmed.name)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun passager pour ce trajet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reservationData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final reservation = ReservationModel.fromMap(reservationData);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(reservation.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = "${userData['prenom']} ${userData['nom']}";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userData['photo_profil'] != null
                            ? NetworkImage(userData['photo_profil'])
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                      title: Text(userName),
                      subtitle: Text('Distance: ${reservation.distance}'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
