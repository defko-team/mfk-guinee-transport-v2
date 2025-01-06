import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/components/vtc/vtc_travel_form.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/views/available_cars.dart';

class CustomerHome extends StatefulWidget {
  final String? userId;
  final List<StationModel> locations;

  const CustomerHome(
      {super.key, required this.userId, required this.locations});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int selectedTransportTypeIndex = -1;
  StationModel? selectedDeparture;
  StationModel? selectedArrival;

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

  void _openModifyReservationBottomSheet(
      {required ReservationModel reservation}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20),
              child: const Text(''),
            ));
  }

  @override
  Widget build(BuildContext context) {
    bool formIsValid = selectedDeparture != null &&
        selectedArrival != null &&
        selectedTransportTypeIndex != -1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocationType(onTypeSelected: (type) {
          setState(() {
            selectedTransportTypeIndex = type;
          });
        }),
        if (selectedTransportTypeIndex == 0) ...[
          LocationForm(
            onDepartureChanged: (departure) {
              setState(() {
                var selectedDepartureFound = widget.locations.where(
                    (location) =>
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
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomElevatedButton(
                  onClick: formIsValid ? _onSearch : () {},
                  backgroundColor:
                      formIsValid ? AppColors.green : AppColors.grey,
                  text: "Rechercher",
                )),
          ],
          if (selectedTransportTypeIndex == 1)
            VTCTravelForm(userId: widget.userId!) 
      ],
    );
  }
}
