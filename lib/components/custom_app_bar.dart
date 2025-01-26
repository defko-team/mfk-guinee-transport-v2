import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/services/notifications_service.dart';
import 'package:mfk_guinee_transport/views/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_bell.dart';

class CurrentUserAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget actions;

  const CurrentUserAppBar({super.key, required this.actions});

  @override
  State<CurrentUserAppBar> createState() => _CurrentUserAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(135);
}

class _CurrentUserAppBarState extends State<CurrentUserAppBar> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("userId");
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
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
                String firstName = userData['prenom'] ?? 'Prénom';
                String lastName = userData['nom'] ?? 'Nom';
                String profileImageUrl = userData['photo_profil'] ??
                    'assets/images/default_avatar.png';

                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                    ),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 55,
                      bottom: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UserProfilePage()),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    profileImageUrl.startsWith('assets/')
                                        ? AssetImage(profileImageUrl)
                                            as ImageProvider
                                        : NetworkImage(profileImageUrl),
                                radius: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Bonjour 👋",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Khadim D.",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        widget.actions,
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
