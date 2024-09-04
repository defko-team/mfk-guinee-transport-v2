import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/simple_app_bar.dart';
import 'package:mfk_guinee_transport/components/trip_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomSimpleAppBar(title: "Historique"),
      body: Column(
        children: [
          FilterBar(),
          Expanded(
            child: ListView(
              children: [
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Keur Massar",
                  vehicle: "Voiture 39XC",
                  status: "Confirmé",
                  statusColor: Colors.blueAccent,
                ),
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Sicap Mbao",
                  vehicle: "Voiture 39XC",
                  status: "Complété",
                  statusColor: Colors.greenAccent,
                ),
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Patte d'Oie",
                  vehicle: "Voiture 39XC",
                  status: "Annulé",
                  statusColor: Colors.redAccent,
                ),
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Patte d'Oie",
                  vehicle: "Voiture 39XC",
                  status: "Annulé",
                  statusColor: Colors.redAccent,
                ),
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Patte d'Oie",
                  vehicle: "Voiture 39XC",
                  status: "Annulé",
                  statusColor: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FilterDropdown(label: 'Date'),
          FilterDropdown(label: 'Status'),
          FilterDropdown(label: 'Vehicule'),
        ],
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;

  FilterDropdown({required this.label});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text(label),
      items: <String>['Option 1', 'Option 2', 'Option 3'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (_) {},
    );
  }
}
