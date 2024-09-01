import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _firstName;
  String? _lastName;
  String? _role;
  String? _phoneNumber;

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
      DocumentSnapshot roleDoc = await FirebaseFirestore.instance.collection('roles').doc(userDoc['id_role']).get();

      setState(() {
        _firstName = userDoc['prenom'];
        _lastName = userDoc['nom'];
        _phoneNumber = userDoc['telephone'];
        _role = roleDoc['nom'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non trouvé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: FadeInDown(
          child: const Text(
            'Profil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 16,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          ProfileHeader(
            firstName: _firstName,
            lastName: _lastName,
            role: _role,
            phoneNumber: _phoneNumber,
          ),
          const SizedBox(height: 20),
          const ProfileOptions(),
          const SizedBox(height: 20),
          const LogoutButton(),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? phoneNumber;

  const ProfileHeader({
    super.key,
    this.firstName,
    this.lastName,
    this.role,
    this.phoneNumber,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserDetailsPage()),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isPressed ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                child: CircleAvatar(
                  radius: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.firstName ?? ''} ${widget.lastName?.substring(0, 1).toUpperCase() ?? ''}.',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.role  ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.phoneNumber ?? '',
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
          const ProfileOptionTile(title: 'Sécurité'),
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
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        );
        break;
      case 'Sécurité':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SecurityPage()),
        );
        break;
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
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion : ${e.toString()}')),
      );
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
