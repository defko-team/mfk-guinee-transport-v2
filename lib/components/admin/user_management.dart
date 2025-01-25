import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminChauffeurManagementPage extends StatefulWidget {
  const AdminChauffeurManagementPage({super.key});

  @override
  State<AdminChauffeurManagementPage> createState() =>
      _AdminChauffeurManagementPageState();
}

class _AdminChauffeurManagementPageState
    extends State<AdminChauffeurManagementPage> {
  List<UserModel> chauffeurs = [];
  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _loadChauffeurs();
  }

  Future<void> _loadChauffeurs() async {
    final chauffeurRoleId = await _getChauffeurRoleId();
    if (chauffeurRoleId != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .where('id_role', isEqualTo: chauffeurRoleId)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          chauffeurs = snapshot.docs
              .map((doc) =>
                  UserModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
          _isExpanded = List<bool>.filled(chauffeurs.length, false);
        });
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

  void _openAddChauffeurBottomSheet({UserModel? chauffeur}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
        child: AddChauffeurForm(
          onSubmit: _loadChauffeurs,
          chauffeur: chauffeur,
        ),
      ),
    );
  }

  void _deleteChauffeur(String idUser) async {
    await FirebaseFirestore.instance.collection('Users').doc(idUser).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chauffeur supprimé avec succès')),
    );
    _loadChauffeurs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: BaseAppBar(
        title: 'Gestion des Chauffeurs',
        showBackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.white),
            onPressed: () {
              // Fonction pour filtrer ou effectuer une action
            },
          ),
        ],
      ),
      body: chauffeurs.isEmpty
          ? const Center(child: Text('Aucun chauffeur pour l\'instant'))
          : ListView.builder(
              itemCount: chauffeurs.length,
              itemBuilder: (context, index) {
                final chauffeur = chauffeurs[index];
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
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      chauffeur.photoProfil != null &&
                                              chauffeur.photoProfil!.isNotEmpty
                                          ? NetworkImage(chauffeur.photoProfil!)
                                          : null,
                                  child: chauffeur.photoProfil == null ||
                                          chauffeur.photoProfil!.isEmpty
                                      ? const Icon(Icons.person,
                                          size: 30, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${chauffeur.prenom} ${chauffeur.nom}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Téléphone: ${chauffeur.telephone}',
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
                                          _openAddChauffeurBottomSheet(
                                              chauffeur: chauffeur);
                                        },
                                        icon: const Icon(Icons.edit, size: 16),
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
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _deleteChauffeur(chauffeur.idUser);
                                        },
                                        icon:
                                            const Icon(Icons.delete, size: 16),
                                        label: const Text('Supprimer'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade100,
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddChauffeurBottomSheet,
        backgroundColor: AppColors.green,
        shape: const CircleBorder(),
        elevation: 6.0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class AddChauffeurForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final UserModel? chauffeur;

  const AddChauffeurForm({required this.onSubmit, this.chauffeur, Key? key})
      : super(key: key);

  @override
  State<AddChauffeurForm> createState() => _AddChauffeurFormState();
}

class _AddChauffeurFormState extends State<AddChauffeurForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  PhoneNumber _initialNumber = PhoneNumber(isoCode: 'GN');
  String? _fullPhoneNumber;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.chauffeur != null) {
      _initializeForEdit(widget.chauffeur!);
    }
  }

  Future<void> _initializeForEdit(UserModel chauffeur) async {
    _firstNameController.text = chauffeur.prenom;
    _lastNameController.text = chauffeur.nom;
    _phoneNumberController.text = chauffeur.telephone.replaceAll(' ', '');
    _fullPhoneNumber = chauffeur.telephone;

    PhoneNumber phoneNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
      chauffeur.telephone,
    );

    setState(() {
      _initialNumber = phoneNumber;
    });
  }

  void _registerChauffeur() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final chauffeurRoleId = await _getChauffeurRoleId();
      if (chauffeurRoleId != null && _fullPhoneNumber != null) {
        final isEditMode = widget.chauffeur != null;
        final idUser = isEditMode
            ? widget.chauffeur!.idUser
            : FirebaseFirestore.instance.collection('Users').doc().id;

        final newChauffeur = UserModel(
          idUser: idUser,
          prenom: _firstNameController.text,
          nom: _lastNameController.text,
          telephone: _fullPhoneNumber!.replaceAll(' ', ''),
          idRole: chauffeurRoleId,
        );

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(idUser)
            .set(newChauffeur.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEditMode
                  ? 'Chauffeur modifié avec succès'
                  : 'Chauffeur ajouté avec succès')),
        );

        widget.onSubmit();
        Navigator.of(context).pop();
      }

      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.chauffeur != null;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              isEditMode ? 'Modifier Chauffeur' : 'Ajouter Chauffeur',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _firstNameController,
              focusNode: _firstNameFocus,
              validator: (value) =>
                  value!.isEmpty ? "Veuillez entrer un prénom" : null,
              decoration: InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _lastNameController,
              focusNode: _lastNameFocus,
              validator: (value) =>
                  value!.isEmpty ? "Veuillez entrer un nom" : null,
              decoration: InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                setState(() =>
                    _fullPhoneNumber = number.phoneNumber?.replaceAll(' ', ''));
              },
              textFieldController: _phoneNumberController,
              focusNode: _phoneFocus,
              initialValue: _initialNumber,
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
              inputDecoration: InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerChauffeur,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isEditMode ? 'Modifier Chauffeur' : 'Ajouter Chauffeur',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
