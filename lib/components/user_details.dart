import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isInfoLoading = true;
  bool _isEditing = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      setState(() {
        _userId = userId;
        _firstName = userDoc['prenom'];
        _lastName = userDoc['nom'];
        _phoneNumber = userDoc['telephone'];
        _profileImageUrl = userDoc['photo_profil'];

        _firstNameController.text = _firstName ?? '';
        _lastNameController.text = _lastName ?? '';
        _phoneNumberController.text = _phoneNumber ?? '';
        _isInfoLoading = false;
      });
    }
  }

void _updateProfile() async {
  if (_userId != null) {
    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance.collection('Users').doc(_userId).update({
      'prenom': _firstNameController.text,
      'nom': _lastNameController.text,
      'telephone': _phoneNumberController.text,
      'photo_profil': _profileImageUrl,
    });

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès!')),
    );

    Navigator.of(context).pop(true);
  }
}

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        _isLoading = true;
      });

      try {
        String fileName = '${_userId}_profile_pic.png';
        UploadTask uploadTask = FirebaseStorage.instance.ref('profile_pics/$_userId/$fileName').putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        await FirebaseFirestore.instance.collection('Users').doc(_userId).update({
          'photo_profil': _profileImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo de profil mise à jour!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement de l\'image: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Détails de l\'utilisateur'),
      body: _isLoading || _isInfoLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: buildEditIcon(Colors.green),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Prénom',
                  controller: _firstNameController,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Nom',
                  controller: _lastNameController,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Téléphone',
                  controller: _phoneNumberController,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 24),
                if (_isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _toggleEditing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: _toggleEditing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Modifier',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}

class TextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
}
