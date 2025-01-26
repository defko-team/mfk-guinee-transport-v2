import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:animate_do/animate_do.dart';

class AdminCarManagementPage extends StatefulWidget {
  const AdminCarManagementPage({super.key});

  @override
  State<AdminCarManagementPage> createState() => _AdminCarManagementPageState();
}

class _AdminCarManagementPageState extends State<AdminCarManagementPage> {
  List<bool> _isExpanded = [];

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
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(idChauffeur)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Erreur lors de la récupération du chauffeur: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: 'Voitures',
        showBackArrow: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Car').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final voitures = snapshot.data!.docs.map((doc) {
            return VoitureModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          if (_isExpanded.length != voitures.length) {
            _isExpanded = List<bool>.filled(voitures.length, false);
          }

          if (voitures.isEmpty) {
            return const Center(
              child: Text(
                'Aucune voiture pour l’instant',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: voitures.length,
            itemBuilder: (context, index) {
              final voiture = voitures[index];

              return FutureBuilder<UserModel?>(
                future: _getChauffeur(voiture.idChauffeur),
                builder: (context, chauffeurSnapshot) {
                  if (!chauffeurSnapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final chauffeur = chauffeurSnapshot.data;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        for (int i = 0; i < _isExpanded.length; i++) {
                          if (i != index) {
                            _isExpanded[i] = false;
                          }
                        }
                        _isExpanded[index] = !_isExpanded[index];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      voiture.photo ??
                                          'assets/images/default_car.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.car_rental,
                                                  size: 50, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Voiture ${voiture.marque}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${voiture.marque}, ${voiture.nombreDePlace} places',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          chauffeur != null
                                              ? 'Chauffeur: ${chauffeur.prenom} ${chauffeur.nom}'
                                              : 'Chauffeur non assigné',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_isExpanded[index])
                                FadeIn(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _openAddCarBottomSheet(
                                                voiture: voiture);
                                          },
                                          icon:
                                              const Icon(Icons.edit, size: 16),
                                          label: const Text('Modifier'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            side: const BorderSide(
                                                color: Colors.black),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 8), // Space between buttons
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('Car')
                                                .doc(voiture.idVoiture)
                                                .delete();
                                          },
                                          icon: const Icon(Icons.delete,
                                              size: 16),
                                          label: const Text('Supprimer'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade100,
                                            foregroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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
    final chauffeurRoleId = await _getChauffeurRoleId();
    if (chauffeurRoleId != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id_role', isEqualTo: chauffeurRoleId)
          .get();

      setState(() {
        chauffeurs = querySnapshot.docs.map((doc) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
        filteredChauffeurs = chauffeurs;
      });
    }
  }

  Future<String?> _getChauffeurRoleId() async {
    try {
      QuerySnapshot roleSnapshot = await FirebaseFirestore.instance
          .collection('roles')
          .where('nom', isEqualTo: 'Chauffeur')
          .limit(1)
          .get();
      if (roleSnapshot.docs.isNotEmpty) {
        return roleSnapshot.docs.first.id;
      }
    } catch (e) {
      print('Erreur lors de la récupération du rôle Chauffeur: $e');
    }
    return null;
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
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(idChauffeur)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
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
