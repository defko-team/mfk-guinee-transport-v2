import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';
import 'package:mfk_guinee_transport/components/custom_app_bar.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> with SingleTickerProviderStateMixin {
  static const Color lightGrey = Color(0xFFF2F2F2);
  String? _userId;
  final AuthService _authService = AuthService();
  late TabController _tabController;
  List<TravelModel> travels = [];
  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadUserInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      fetchTravels();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  void fetchTravels() async {
    if (_userId == null) return;
    
    print('🔍 Début fetchTravels avec userId: $_userId');
    setState(() => isLoading = true);
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .get();
      
      print('👤 Document utilisateur existe: ${userDoc.exists}');
      print('👤 Données utilisateur complètes: ${userDoc.data()}');

      String prenom = userDoc.data()?['prenom'] ?? '';
      String nom = userDoc.data()?['nom'] ?? '';
      String driverName = '$prenom $nom'.trim();
      
      print('👤 Nom du conducteur construit: $driverName');
      
      var query = FirebaseFirestore.instance
          .collection('Travel')
          .where('driver_name', isEqualTo: driverName);

      print('📅 Tab actif: ${_tabController.index}');
      DateTime now = DateTime.now();
      print('⏰ Date actuelle: $now');

      var snapshot = await query.get();
      print('📊 Nombre de documents trouvés: ${snapshot.docs.length}');
      
      if (snapshot.docs.isNotEmpty) {
        print('📄 Premier document trouvé: ${snapshot.docs.first.data()}');
      }
      
      if (mounted) {
        setState(() {
          travels = snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            print('🎯 Document trouvé - ID: ${doc.id}');
            print('📄 Données du document: ${doc.data()}');
            return TravelModel.fromMap(data);
          }).where((travel) {
            // Filtrer par date selon l'onglet actif
            if (_tabController.index == 0) {
              // Trajets à venir (aujourd'hui et futur)
              return travel.startTime.isAfter(DateTime(now.year, now.month, now.day)) || 
                     travel.startTime.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
            } else {
              // Trajets passés
              return travel.startTime.isBefore(DateTime(now.year, now.month, now.day));
            }
          }).toList();

          // Appliquer le filtre de date sélectionnée si présent
          if (selectedDate != null) {
            print('📆 Filtrage par date sélectionnée: $selectedDate');
            travels = travels.where((travel) {
              bool matchesDate = travel.startTime.year == selectedDate!.year &&
                     travel.startTime.month == selectedDate!.month &&
                     travel.startTime.day == selectedDate!.day;
              print('📅 Trajet ${travel.id} correspond à la date: $matchesDate');
              return matchesDate;
            }).toList();
          }

          // Trier par date
          travels.sort((a, b) => _tabController.index == 0 
              ? a.startTime.compareTo(b.startTime)  // Croissant pour les trajets à venir
              : b.startTime.compareTo(a.startTime)); // Décroissant pour l'historique

          print('✅ Nombre final de trajets: ${travels.length}');
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Erreur dans fetchTravels: $e');
      print('📜 Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des trajets: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return FilterBar(
          selectedDate: selectedDate,
          onFiltersChanged: (date) {
            setState(() {
              selectedDate = date;
            });
            fetchTravels();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return FadeInUp(
      duration: const Duration(milliseconds: 100),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun trajet trouvé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelsList(bool isUpcoming) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : travels.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: travels.length,
                itemBuilder: (context, index) {
                  return TravelCard(
                    travel: travels[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TravelCustomersList(
                            travelId: travels[index].id!,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(125),
        child: Container(
          color: AppColors.green,
          child: SafeArea(
            bottom: false,
            child: CurrentUserAppBar(
              actions: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _showFilterModal,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.green,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              tabs: const [
                Tab(child: Text('À venir', style: TextStyle(color: Colors.white))),
                Tab(child: Text('Historique', style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTravelsList(true),
                _buildTravelsList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime? date) onFiltersChanged;

  const FilterBar({
    super.key,
    this.selectedDate,
    required this.onFiltersChanged,
  });

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime lastDate = DateTime(now.year + 1, 12, 31);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onFiltersChanged(_selectedDate);
    }
  }

  Widget _buildClearButton() {
    bool isAnyFilterSet = _selectedDate != null;
    
    if (!isAnyFilterSet) return const SizedBox.shrink();

    return TextButton.icon(
      icon: const Icon(Icons.clear, size: 20),
      label: const Text('Effacer'),
      onPressed: () {
        setState(() {
          _selectedDate = null;
        });
        widget.onFiltersChanged(null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildClearButton(),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDate == null
                        ? 'Sélectionner une date'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
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
                const Row(
                  children: [
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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: userData['photo_profil'] != null
                            ? NetworkImage(userData['photo_profil'])
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
