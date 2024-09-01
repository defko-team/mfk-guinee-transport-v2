import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/helper/constants/mock_data.dart';

import '../components/base_app_bar.dart';
import '../components/selectable_car.dart';

class AvailableCarsPage extends StatefulWidget {
  const AvailableCarsPage({super.key});

  @override
  _AvailableCarsPageState createState() => _AvailableCarsPageState();
}

class _AvailableCarsPageState extends State<AvailableCarsPage> {
  int selectedCarIndex = -1;

  final List<Map<String, dynamic>> cars = mock_cars;

  void _onCarSelected(bool isSelected, int index) {
    setState(() {
      if (isSelected) {
        // Si une voiture est sélectionnée, mettez à jour l'index sélectionné
        selectedCarIndex = index;
      } else if (selectedCarIndex == index) {
        // Si la voiture sélectionnée est cliquée à nouveau, désélectionnez-la
        selectedCarIndex = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Voitures disponibles'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Liste scrollable qui occupe tout l'espace disponible
            Expanded(
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  return SelectableCarWidget(
                    carName: cars[index]['carName'],
                    driverName: cars[index]['driverName'],
                    departureTime: cars[index]['departureTime'],
                    price: cars[index]['price'],
                    isClimatised: cars[index]['isClimatised'],
                    seats: cars[index]['seats'],
                    isSelected: selectedCarIndex == index,
                    onSelected: (isSelected) {
                      _onCarSelected(isSelected, index);
                    },
                  );
                },
              ),
            ),

            // Bouton en bas de la page, en dehors de la zone de scroll
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomElevatedButton(
                onSearch: _onSearch,
                backgroundColor: selectedCarIndex != -1
                    ? AppColors.green
                    : AppColors.grey,
                text: "Rechercher",
              ),
            ),
          ],
        ),
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