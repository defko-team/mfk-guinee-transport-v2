import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/base_app_bar.dart';
import '../components/selectable_car.dart';


class AvailableCarsPage extends StatefulWidget {
  const AvailableCarsPage({super.key});

  @override
  _AvailableCarsPageState createState() => _AvailableCarsPageState();
}

class _AvailableCarsPageState extends State<AvailableCarsPage> {
  int selectedCarIndex = -1;

  final List<Map<String, dynamic>> cars = [
    {
      'carName': 'Voiture 39XC',
      'driverName': 'Alpha Diallo',
      'departureTime': '09:00',
      'price': '2.000 CFA',
      'isClimatised': true,
      'seats': 4,
    },
    {
      'carName': 'Voiture 39XC',
      'driverName': 'Alpha Diallo',
      'departureTime': '09:00',
      'price': '2.000 CFA',
      'isClimatised': true,
      'seats': 4,
    },
    {
      'carName': 'Voiture 39XC',
      'driverName': 'Alpha Diakhaté',
      'departureTime': '09:00',
      'price': '2.000 CFA',
      'isClimatised': true,
      'seats': 4,
    },
    {
      'carName': 'Voiture 39XC',
      'driverName': 'Bamba Diallo',
      'departureTime': '09:00',
      'price': '2.000 CFA',
      'isClimatised': true,
      'seats': 4,
    },
    {
      'carName': 'Voiture 39XC',
      'driverName': 'Alpha Diop',
      'departureTime': '09:00',
      'price': '2.000 CFA',
      'isClimatised': true,
      'seats': 4,
    },
    // Ajoutez d'autres voitures ici
  ];

  void _onCarSelected(bool isSelected, int index) {
    setState(() {
      if (isSelected) {
        selectedCarIndex = index;
      } else {
        selectedCarIndex = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Voitures disponibles'),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return SelectableCarWidget(
            carName: cars[index]['carName'],
            driverName: cars[index]['driverName'],
            departureTime: cars[index]['departureTime'],
            price: cars[index]['price'],
            isClimatised: cars[index]['isClimatised'],
            seats: cars[index]['seats'],
            onSelected: (isSelected) {
              _onCarSelected(isSelected, index);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
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
        ],
      ),
    );
  }

  void _onSearch() {
    // Action lors de la recherche
  }
}
