import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/station_service.dart';
import 'package:mfk_guinee_transport/services/travel_service.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mfk_guinee_transport/views/available_cars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key});

  @override
  _StationPageState createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  StationService stationService = StationService();
  TravelService travelService = TravelService();
  List<StationModel> stations = [];
  List<TravelModel> travels = [];
  Map<String, List<TravelModel>> groupedTravels = {};

  String userId = '';

  // get the current userId from sharedPreferences
  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _getCurrentUserId();
  }

  Future<void> _loadData() async {
    try {
      final stationsData = await stationService.getAllStations();
      final travelsData = await travelService.getAllTravels();

      if (mounted) {
        setState(() {
          stations = stationsData;
          travels = travelsData;
          _groupTravels();
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  void _groupTravels() {
    groupedTravels.clear();
    for (var travel in travels) {
      if (travel.departureStationId == null ||
          travel.destinationStationId == null) continue;
      String key =
          '${travel.departureStationId}_${travel.destinationStationId}';
      if (!groupedTravels.containsKey(key)) {
        groupedTravels[key] = [];
      }
      groupedTravels[key]!.add(travel);
    }
  }

  Widget _buildItineraryCard(
      String departureId, String destinationId, List<TravelModel> travelGroup) {
    final departureStation = stations.firstWhere(
      (s) => s.docId == departureId,
      orElse: () => StationModel(
        id: 'unknown',
        name: 'Station inconnue',
        latitude: 0,
        longitude: 0,
        address: 'Adresse inconnue',
        docId: departureId,
      ),
    );

    final destinationStation = stations.firstWhere(
      (s) => s.docId == destinationId,
      orElse: () => StationModel(
        id: 'unknown',
        name: 'Station inconnue',
        latitude: 0,
        longitude: 0,
        address: 'Adresse inconnue',
        docId: destinationId,
      ),
    );

    final availableCars = travelGroup.length;

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _showItineraryDetails(
              departureStation, destinationStation, travelGroup),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Départ',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            departureStation.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            departureStation.address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_forward, color: AppColors.green),
                        const SizedBox(height: 4),
                        Dash(
                          direction: Axis.horizontal,
                          length: 30,
                          dashLength: 5,
                          dashColor: AppColors.green.withOpacity(0.5),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$availableCars véhicules',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Arrivée',
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destinationStation.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            destinationStation.address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showItineraryDetails(StationModel departure, StationModel destination,
      List<TravelModel> travelGroup) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Détails de l\'itinéraire',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailSection(
                  'Point de départ',
                  departure.name,
                  departure.address,
                  Icons.location_on,
                  Colors.blue[700]!,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    height: 40,
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailSection(
                  'Destination',
                  destination.name,
                  destination.address,
                  Icons.location_on,
                  AppColors.green,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailInfo(
                      Icons.directions_car,
                      'Véhicules',
                      '${travelGroup.length}',
                      AppColors.green,
                    ),
                    _buildDetailInfo(
                      Icons.event_seat,
                      'Places',
                      travelGroup.isNotEmpty
                          ? travelGroup
                              .fold<int>(
                                  0,
                                  (previousValue, element) =>
                                      previousValue + element.remainingSeats)
                              .toString()
                          : 'N/A',
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: travelGroup.isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AvailableCarsPage(
                                  travelSearchInfo: {
                                    'selectedDeparture': departure.docId,
                                    'selectedArrival': destination.docId,
                                    'userId': userId,
                                  },
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      travelGroup.isNotEmpty
                          ? 'Voir les véhicules disponibles'
                          : 'Aucun véhicule disponible',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: travelGroup.isNotEmpty
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String label,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: 'Destinations',
      ),
      backgroundColor: Colors.grey[50],
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: groupedTravels.length,
        itemBuilder: (context, index) {
          final entry = groupedTravels.entries.elementAt(index);
          final ids = entry.key.split('_');
          return _buildItineraryCard(ids[0], ids[1], entry.value);
        },
      ),
    );
  }
}
