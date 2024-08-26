import 'package:flutter/material.dart';

class LocationForm extends StatefulWidget {
  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final List<String> locations = [
    'Dakar, Ville',
    'Keur Massar',
    'Pikine',
    'Guediawaye',
    'Rufisque',
  ];

  String? selectedDeparture;
  String? selectedArrival;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Où allez-vous aujourd'hui ?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Departure Dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.black),
              title: DropdownButtonFormField<String>(
                value: selectedDeparture,
                hint: Text('Départ'),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                items: locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDeparture = value;
                  });
                },
                isExpanded: true,
                icon: selectedDeparture != null
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedDeparture = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Arrival Dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.black),
              title: DropdownButtonFormField<String>(
                value: selectedArrival,
                hint: Text('Arrivée'),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                items: locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedArrival = value;
                  });
                },
                isExpanded: true,
                icon: selectedArrival != null
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedArrival = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
