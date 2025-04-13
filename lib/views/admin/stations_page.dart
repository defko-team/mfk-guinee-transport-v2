import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import '../../models/station.dart';
import '../../services/station_service.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({Key? key}) : super(key: key);

  @override
  _StationsPageState createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  final StationService _stationService = StationService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final String _geoCodeApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']
  final List<String> COUNTRIES = ['gn', 'sn', 'fr'];
  LatLng _stationCoords = LatLng(0.0, 0.0);
  String _stationLocation = '';

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();

  void _showAddStationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ajouter une nouvelle gare',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  focusNode: _nameFocusNode,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de la gare',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                ),
                const SizedBox(height: 16),
                GooglePlaceAutoCompleteTextField(
                  focusNode: _addressFocusNode,
                  textEditingController: _addressController,
                  googleAPIKey: _geoCodeApiKey,
                  inputDecoration: InputDecoration(
                    hintText: 'Adresse de la gare',
                    labelText: 'Lieu de la gare',
                    contentPadding: const EdgeInsets.all(0.0),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(Icons.location_on,
                        color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  debounceTime: 800,
                  countries: COUNTRIES,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    setState(() {
                      _stationCoords = LatLng(
                          double.parse(prediction.lat ?? '0.0'),
                          double.parse(prediction.lng ?? '0.0'));
                    });
                  },
                  itemClick: (prediction) {
                    setState(() {
                      _stationLocation = prediction.description ?? '';
                      _addressController.text = prediction.description ?? '';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _stationService.addStation(
                  StationModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    address: _addressController.text,
                    latitude: double.parse(_stationCoords.latitude.toString()),
                    longitude:
                        double.parse(_stationCoords.longitude.toString()),
                    docId: '',
                  ),
                );
                Navigator.pop(context);
                _clearControllers();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ajouter',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _addressController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: 'Gestion des Gares',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStationDialog,
          ),
        ],
        showBackArrow: false,
      ),
      body: StreamBuilder<List<StationModel>>(
        stream: _stationService.getStations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stations = snapshot.data ?? [];

          return stations.isEmpty
              ? Center(
                  child: Text(
                    'Aucune gare disponible',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          station.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Adresse: ${station.address}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            (station.latitude != null &&
                                    station.longitude != null)
                                ? Text(
                                    'Coordonnées: ${station.latitude?.toStringAsFixed(2)}, ${station.longitude?.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  )
                                : Text(
                                    'Coordonnées: Non renseignées',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.edit),
                                title: Text(
                                  'Modifier',
                                  style: GoogleFonts.poppins(),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onTap: () {
                                // TODO: Implement edit functionality
                              },
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  'Supprimer',
                                  style: GoogleFonts.poppins(
                                    color: Colors.red,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onTap: () {
                                _stationService.deleteStation(station.docId);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        onPressed: _showAddStationDialog,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
