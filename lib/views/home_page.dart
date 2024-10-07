import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/gare_page.dart';
import 'package:mfk_guinee_transport/views/admin_views/trajet_management.dart';
import 'package:mfk_guinee_transport/views/customer_home.dart';
import 'package:mfk_guinee_transport/views/history.dart';
import 'package:mfk_guinee_transport/views/user_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    const CustomerHomePage(),
    const GarePage(),
    const HistoryPage(),
    const UserProfilePage(),
    const TrajetManagementPage()
  ];

  // Future<void> _onItemTapped(int index) async {
  //   if (index == 3) {
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const UserProfilePage()),
  //     );
  //     if (result == true) {
  //       setState(() {});
  //     } else {
  //       setState(() {
  //         _selectedIndex = 0;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _selectedIndex = index;
  //     });
  //   }
  // }

  Future<void> _onItemTapped(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _widgetOptions.elementAt(index)),
    );
    if (result == true) {
      setState(() {});
    } else {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Gares',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Plus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'gest',
          ),
        ],
      ),
    );
  }
}
