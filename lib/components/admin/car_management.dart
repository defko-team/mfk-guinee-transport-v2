import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/user_model.dart'; // Import du modèle UserModel

class AdminCarManagementPage extends StatefulWidget {
  const AdminCarManagementPage({super.key});

  @override
  _AdminCarManagementPageState createState() => _AdminCarManagementPageState();
}

class _AdminCarManagementPageState extends State<AdminCarManagementPage> {
  void _openAddCarBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: const AddCarForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures'),
        backgroundColor: AppColors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: const Text(
          'Aucune voiture pour l’instant',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddCarBottomSheet,
        backgroundColor: AppColors.green,
        shape: const CircleBorder(),
        elevation: 6.0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class AddCarForm extends StatefulWidget {
  const AddCarForm({super.key});

  @override
  _AddCarFormState createState() => _AddCarFormState();
}

class _AddCarFormState extends State<AddCarForm> {
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _nombrePlaceController = TextEditingController();
  final TextEditingController _chauffeurSearchController = TextEditingController(); // Champ de recherche pour chauffeur
  File? _imageFile;
  String? _selectedChauffeurId;
  List<UserModel> chauffeurs = [];
  List<UserModel> filteredChauffeurs = [];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadChauffeurs() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id_role', isEqualTo: 'Chauffeur')
          .get();

      setState(() {
        chauffeurs = querySnapshot.docs.map((doc) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
        filteredChauffeurs = chauffeurs;
      });
    } catch (e) {
      print('Erreur lors de la récupération des chauffeurs: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChauffeurs();
  }

  void _filterChauffeurs(String query) {
    setState(() {
      filteredChauffeurs = chauffeurs.where((chauffeur) {
        final fullName = '${chauffeur.prenom} ${chauffeur.nom}'.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _submitCar() {
    final marque = _marqueController.text;
    final nombreDePlace = int.tryParse(_nombrePlaceController.text);

    if (marque.isEmpty || nombreDePlace == null || _selectedChauffeurId == null || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner une image.')),
      );
      return;
    }

    final voiture = VoitureModel(
      idVoiture: DateTime.now().toString(),
      photo: _imageFile?.path ?? '',
      marque: marque,
      nombreDePlace: nombreDePlace,
      idChauffeur: _selectedChauffeurId!,
    );

    print('Nouvelle voiture ajoutée: ${voiture.toMap()}');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            'Ajouter une voiture',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? const Icon(Icons.car_rental, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Champ Marque
          TextField(
            controller: _marqueController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              labelText: 'Marque de la voiture',
              hintText: 'Entrez la marque',
              labelStyle: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              prefixIcon: const Icon(Icons.directions_car, color: Colors.black, size: 18),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              floatingLabelStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Champ Nombre de places
          TextField(
            controller: _nombrePlaceController,
            keyboardType: TextInputType.number,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              labelText: 'Nombre de places',
              hintText: 'Entrez le nombre de places',
              labelStyle: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              prefixIcon: const Icon(Icons.event_seat, color: Colors.black, size: 18),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              floatingLabelStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Dropdown pour sélectionner le chauffeur avec filtrage en temps réel
          DropdownButtonFormField<String>(
            value: _selectedChauffeurId,
            hint: const Text('Sélectionnez un chauffeur'),
            items: filteredChauffeurs.map((chauffeur) {
              return DropdownMenuItem<String>(
                value: chauffeur.idUser,
                child: Text('${chauffeur.prenom} ${chauffeur.nom}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedChauffeurId = value;
              });
            },
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              labelText: 'Chauffeur',
              labelStyle: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              floatingLabelStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Bouton Soumettre
          ElevatedButton(
            onPressed: _submitCar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Center(
              child: Text(
                'Ajouter la voiture',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
