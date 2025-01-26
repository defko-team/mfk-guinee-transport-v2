import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';
import 'package:mfk_guinee_transport/components/user_details.dart';
import 'package:mfk_guinee_transport/components/notifications_page.dart';
import 'package:mfk_guinee_transport/components/security_page.dart';
import 'package:mfk_guinee_transport/components/clear_cache_page.dart';
import 'package:mfk_guinee_transport/components/privacy_policy_page.dart';
import 'package:mfk_guinee_transport/components/contact_us_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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

  Future<void> _navigateToUserDetails() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserDetailsPage()),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: "Profil"),
      backgroundColor: Colors.white, // Set page background color to white
      body: _userId == null
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
                String role = userData['role'] ?? 'Utilisateur';
                String profileImageUrl = userData['photo_profil'] ??
                    'assets/images/default_avatar.png';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap:
                          _navigateToUserDetails, // Navigate to UserDetailsPage
                      child: ProfileHeader(
                        firstName: firstName,
                        lastName: lastName,
                        role: role,
                        profileImageUrl: profileImageUrl,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const ProfileOptions(),
                    const SizedBox(height: 20),
                    const LogoutButton(),
                  ],
                );
              },
            ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String role;
  final String profileImageUrl;

  const ProfileHeader({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: profileImageUrl.startsWith('assets/')
                  ? AssetImage(profileImageUrl) as ImageProvider
                  : NetworkImage(profileImageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$firstName ${lastName[0].toUpperCase()}.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOptionGroup([
          const ProfileOptionTile(title: 'Notifications'),
          // const ProfileOptionTile(title: 'Sécurité'),
        ]),
        const SizedBox(height: 20),
        _buildOptionGroup([
          const ProfileOptionTile(title: 'Effacer cache'),
          const ProfileOptionTile(title: 'Politique de confidentialité'),
          const ProfileOptionTile(title: 'Contactez-nous'),
        ]),
      ],
    );
  }

  Widget _buildOptionGroup(List<ProfileOptionTile> tiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: tiles,
        ),
      ),
    );
  }
}

class ProfileOptionTile extends StatefulWidget {
  final String title;

  const ProfileOptionTile({super.key, required this.title});

  @override
  State<ProfileOptionTile> createState() => _ProfileOptionTileState();
}

class _ProfileOptionTileState extends State<ProfileOptionTile> {
  bool _isPressed = false;

  void _navigateToPage(BuildContext context) {
    switch (widget.title) {
      case 'Notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
        break;
      // case 'Sécurité':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const SecurityPage()),
      //   );
      //   break;
      case 'Effacer cache':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClearCachePage()),
        );
        break;
      case 'Politique de confidentialité':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
        );
        break;
      case 'Contactez-nous':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactUsPage()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        if (mounted) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (mounted) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      onTap: () {
        _navigateToPage(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _isPressed ? Colors.grey.shade200 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      AuthService authService = AuthService();
      await authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la déconnexion : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () => _signOut(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D4D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Déconnexion',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
