import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';

class AdminCarManagementPage extends StatefulWidget {
  const AdminCarManagementPage({super.key});

  @override
  State<AdminCarManagementPage> createState() => _AdminCarManagementPageState();
}

class _AdminCarManagementPageState extends State<AdminCarManagementPage> {
  List<bool> _isExpanded = [];
  final UserService _userService = UserService();

  void _openAddCarBottomSheet({VoitureModel? voiture}) {
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
        child: AddCarForm(voiture: voiture),
      ),
    );
  }

  Future<UserModel?> _getChauffeur(String idChauffeur) async {
    try {
      return await _userService.getUserById(idChauffeur);
    } catch (e) {
      print('Erreur lors de la récupération du chauffeur: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BaseAppBar(
        title: 'Voitures',
        showBackArrow: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Car').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Une erreur est survenue: ${snapshot.error}'));
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          final voitures = snapshot.data!.docs.map((doc) {
            return VoitureModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          if (_isExpanded.length != voitures.length) {
            _isExpanded = List<bool>.filled(voitures.length, false);
          }

          if (voitures.isEmpty) {
            return Center(
              child: Text(
                'Aucune voiture pour l’instant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: voitures.length,
            itemBuilder: (context, index) {
              final voiture = voitures[index];

              return FutureBuilder<UserModel?>(
                future: voiture.idChauffeur.isEmpty
                    ? Future.value(null)
                    : _getChauffeur(voiture.idChauffeur),
                builder: (context, chauffeurSnapshot) {
                  return Card(
                    child: ExpansionTile(
                      leading: voiture.photo != null && voiture.photo!.isNotEmpty
                          ? Image.network(voiture.photo!, width: 50, height: 50)
                          : const Icon(Icons.directions_car),
                      title: Text(voiture.marque),
                      subtitle: Text(
                        chauffeurSnapshot.hasData && chauffeurSnapshot.data != null
                            ? 'Chauffeur: ${chauffeurSnapshot.data!.nom} ${chauffeurSnapshot.data!.prenom}'
                            : 'Aucun chauffeur assigné',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openAddCarBottomSheet(voiture: voiture),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nombre de places: ${voiture.nombreDePlace}'),
                              Text('Air conditionné: ${voiture.airConditioner ? 'Oui' : 'Non'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddCarBottomSheet(),
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
  final VoitureModel? voiture;

  const AddCarForm({super.key, this.voiture});

  @override
  State<AddCarForm> createState() => _AddCarFormState();
}

class _AddCarFormState extends State<AddCarForm> {
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _nombrePlaceController = TextEditingController();
  final TextEditingController _chauffeurController =
      TextEditingController(); // For the chauffeur name
  File? _imageFile;
  String? _selectedChauffeurId;
  String? _imageUrl;
  bool _isLoading = false;

  List<UserModel> chauffeurs = [];
  List<UserModel> filteredChauffeurs = [];
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadChauffeurs().then((_) {
      if (widget.voiture != null) {
        _initializeForEdit(widget.voiture!);
      }
    });
  }

  Future<void> _loadChauffeurs() async {
    try {
      final loadedChauffeurs =
          await _userService.getUsersByRole(UserRole.Chauffeur);
      setState(() {
        chauffeurs = loadedChauffeurs;
        filteredChauffeurs = chauffeurs;
      });
    } catch (e) {
      print('Error loading chauffeurs: $e');
    }
  }

  void _initializeForEdit(VoitureModel voiture) async {
    _marqueController.text = voiture.marque;
    _nombrePlaceController.text = voiture.nombreDePlace.toString();
    _selectedChauffeurId = voiture.idChauffeur;
    _imageUrl = voiture.photo;

    if (_selectedChauffeurId != null) {
      UserModel? chauffeur = await _getChauffeurById(_selectedChauffeurId!);
      if (chauffeur != null) {
        setState(() {
          _chauffeurController.text =
              '${chauffeur.prenom} ${chauffeur.nom}'; // Display chauffeur name
        });
      }
    }
  }

  Future<UserModel?> _getChauffeurById(String idChauffeur) async {
    try {
      return await _userService.getUserById(idChauffeur);
    } catch (e) {
      print('Erreur lors de la récupération du chauffeur: $e');
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(String carId) async {
    if (_imageFile != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw 'L\'utilisateur n\'est pas authentifié';
        }
        String fileName = '${carId}_car_image.png';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('car_images/$fileName')
            .putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        _imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Erreur lors du téléchargement de l\'image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors du téléchargement de l\'image.')),
        );
      }
    }
  }

  void _submitCar() async {
    setState(() {
      _isLoading = true;
    });

    final marque = _marqueController.text;
    final nombreDePlace = int.tryParse(_nombrePlaceController.text);

    if (marque.isEmpty ||
        nombreDePlace == null ||
        _selectedChauffeurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final isEditMode = widget.voiture != null;
    final carId = isEditMode
        ? widget.voiture!.idVoiture
        : FirebaseFirestore.instance.collection('Car').doc().id;

    if (!isEditMode || (_imageFile != null)) {
      await _uploadImage(carId);
    }

    final voiture = VoitureModel(
        idVoiture: carId,
        marque: marque,
        nombreDePlace: nombreDePlace,
        idChauffeur: _selectedChauffeurId ?? '',
        photo: _imageUrl ?? '',
        airConditioner: true);

    FirebaseFirestore.instance
        .collection('Car')
        .doc(carId)
        .set(voiture.toMap())
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEditMode
            ? 'Voiture mise à jour avec succès!'
            : 'Voiture ajoutée avec succès!'),
      ));
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Erreur lors de l\'ajout ou modification de la voiture: $error');
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
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
            'Ajouter ou Modifier une voiture',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Autocomplete<UserModel>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<UserModel>.empty();
              }
              return chauffeurs.where((UserModel option) {
                return '${option.prenom} ${option.nom}'
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            displayStringForOption: (UserModel option) =>
                '${option.prenom} ${option.nom}',
            onSelected: (UserModel selection) {
              setState(() {
                _selectedChauffeurId = selection.idUser;
                _chauffeurController.text =
                    '${selection.prenom} ${selection.nom}';
              });
            },
            initialValue: TextEditingValue(
              text: _chauffeurController
                  .text, // Pre-fill the input with chauffeur name
            ),
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              textEditingController.text =
                  _chauffeurController.text; // Ensure controller sync
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Chauffeur',
                  prefixIcon:
                      const Icon(Icons.person, color: Colors.black, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  hintText: 'Tapez pour rechercher...',
                ),
              );
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<UserModel> onSelected,
                Iterable<UserModel> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 80,
                    constraints: const BoxConstraints(
                      maxHeight: 200.0,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final UserModel option = options.elementAt(index);
                        return ListTile(
                          title: Text('${option.prenom} ${option.nom}'),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
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
                        : _imageUrl != null
                            ? NetworkImage(_imageUrl!)
                            : null,
                    child: _imageFile == null && _imageUrl == null
                        ? const Icon(Icons.car_rental,
                            size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
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
              prefixIcon: const Icon(Icons.directions_car,
                  color: Colors.black, size: 18),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              floatingLabelStyle:
                  const TextStyle(color: Colors.black, fontSize: 18.0),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
              prefixIcon:
                  const Icon(Icons.event_seat, color: Colors.black, size: 18),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              floatingLabelStyle:
                  const TextStyle(color: Colors.black, fontSize: 18.0),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
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
                      'Enregistrer la voiture',
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
