import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/components/vtc/vtc_form.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/views/available_cars.dart';

class CustomerHome extends StatefulWidget {

  final String? userId;
  final List<StationModel> locations;
  
  const CustomerHome({super.key, required this.userId, required this.locations});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  
  StationModel? selectedDeparture;
  StationModel? selectedArrival;

  int selectedTransportTypeIndex = -1;

  void _onSearch() {
    if (selectedDeparture != null &&
        selectedArrival != null &&
        selectedTransportTypeIndex != -1) {
      // Here you can handle the search logic
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (content) => AvailableCarsPage(
              travelSearchInfo: {
                'selectedDeparture': selectedDeparture?.docId,
                'selectedArrival': selectedArrival?.docId,
                'type': selectedTransportTypeIndex,
                'userId': widget.userId,
              },
            ),
          ));
      // You might want to navigate to another page or make a request with the gathered data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    bool formIsValid = selectedDeparture != null &&
        selectedArrival != null &&
        selectedTransportTypeIndex != -1;

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Où allez-vous aujourd'hui ?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          VtcForm(
            onDepartureChanged: (departure) {
              setState(() {
                var selectedDepartureFound = widget.locations.where((location) =>
                    location.name.toLowerCase() == departure.toLowerCase());

                selectedDeparture = selectedDepartureFound.isNotEmpty
                    ? selectedDepartureFound.first
                    : null;
              });
            },
            onArrivalChanged: (arrival) {
              setState(() {
                var selectedArrivalFound = widget.locations.where((location) =>
                    location.name.toLowerCase() == arrival.toLowerCase());

                selectedArrival = selectedArrivalFound.isNotEmpty
                    ? selectedArrivalFound.first
                    : null;
              });
            },
            locations: widget.locations,
          ),
          const SizedBox(height: 16),
          const Text(
            "Quel moyen de transport ?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LocationType(
            onTypeSelected: (type) {
              setState(() {
                selectedTransportTypeIndex = type;
              });
            },
          ),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomElevatedButton(
                onClick: formIsValid ? _onSearch : () {},
                backgroundColor: formIsValid ? AppColors.green : AppColors.grey,
                text: "Rechercher",
              )),
        ],
      ),
    );
  }
}
