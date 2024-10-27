import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pour l'authentification
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/car.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';

class AdminCarManagementPage extends StatefulWidget {
  const AdminCarManagementPage({super.key});

  @override
  State<AdminCarManagementPage> createState() => _AdminCarManagementPageState();
}

class _AdminCarManagementPageState extends State<AdminCarManagementPage> {
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
        child: AddCarForm(voiture: voiture), // Pass the voiture for edit mode
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Car').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final voitures = snapshot.data!.docs.map((doc) {
            return VoitureModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

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
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    leading: Image.network(
                      voiture.photo ?? 'assets/images/default_car.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.car_rental,
                          size: 50,
                          color: Colors.grey),
                    ),
                    title: Text(
                      'Voiture ${voiture.marque}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${voiture.marque}, ${voiture.nombreDePlace} places',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            _openAddCarBottomSheet(voiture: voiture);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('Car')
                                .doc(voiture.idVoiture)
                                .delete();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
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
  final VoitureModel? voiture; // Nullable voiture object for edit mode

  const AddCarForm({super.key, this.voiture});

  @override
  State<AddCarForm> createState() => _AddCarFormState();
}

class _AddCarFormState extends State<AddCarForm> {
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _nombrePlaceController = TextEditingController();
  File? _imageFile;
  String? _selectedChauffeurId;
  String? _imageUrl;
  bool _isLoading = false;

  List<UserModel> chauffeurs = [];
  List<UserModel> filteredChauffeurs = [];

  @override
  void initState() {
    super.initState();
    _loadChauffeurs();
    if (widget.voiture != null) {
      _initializeForEdit(widget.voiture!);
    }
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

  void _initializeForEdit(VoitureModel voiture) {
    _marqueController.text = voiture.marque;
    _nombrePlaceController.text = voiture.nombreDePlace.toString();
    _selectedChauffeurId = voiture.idChauffeur;
    _imageUrl = voiture.photo;
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
        idChauffeur:
            _selectedChauffeurId ?? '', // Provide a default value if null
        photo: _imageUrl ?? '', // Use empty string if no image is uploaded
        airConditioner: true);

    FirebaseFirestore.instance
        .collection('Car')
        .doc(carId)
        .set(voiture.toMap())
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEditMode
                ? 'Voiture mise à jour avec succès!'
                : 'Voiture ajoutée avec succès!')),
      );
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
              });
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
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
