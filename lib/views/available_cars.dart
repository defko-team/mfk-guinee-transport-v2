import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/reservation_info.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/travel_service.dart';

import '../components/base_app_bar.dart';
import '../components/selectable_car.dart';

class AvailableCarsPage extends StatefulWidget {
  final Map<String, dynamic> travelSearchInfo;

  const AvailableCarsPage({
    super.key,
    required this.travelSearchInfo,
  });

  @override
  _AvailableCarsPageState createState() => _AvailableCarsPageState();
}

class _AvailableCarsPageState extends State<AvailableCarsPage> {
  int selectedCarIndex = -1;

  List<TravelModel> travels = [];

  TravelService travelService = TravelService();

  @override
  void initState() {
    super.initState();
    _loadTravels();
  }

  Future<void> _loadTravels() async {
    var travels_data =  await travelService
    .getTravelsByStations(widget.travelSearchInfo['selectedDeparture'], widget.travelSearchInfo['selectedArrival']);

    setState(() {
      travels = travels_data;
    });
  }
  void _setOnSelectedCarState(int index) {
    setState(() {
      if(selectedCarIndex == index) {
        selectedCarIndex = -1;
      } else {
        selectedCarIndex = index;
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
                itemCount: travels.length,
                itemBuilder: (context, index) {
                  return SelectableCarWidget(
                    travel: travels[index],
                    isSelected: selectedCarIndex == index,
                    index: index,
                    onToggled: _setOnSelectedCarState,
                  );
                },
              ),
            ),

            // Bouton en bas de la page, en dehors de la zone de scroll
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
              child: CustomElevatedButton(
                onSearch: _onSearch,
                backgroundColor:
                    selectedCarIndex != -1 ? AppColors.green : AppColors.grey,
                text: "Continuer",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearch() {
    // Action lors de la recherche
    if (selectedCarIndex != -1) {
      TravelModel selectedTravel = travels[selectedCarIndex];

      ReservationModel reservation = ReservationModel(
        departureStation: selectedTravel.departureStation?.address, 
        destinationStation: selectedTravel.destinationStation?.address, 
        departureLocation: selectedTravel.departureLocation, 
        arrivalLocation: selectedTravel.arrivalLocation, 
        startTime: selectedTravel.startTime, 
        arrivalTime: selectedTravel.arrivalTime, 
        remainingSeats: selectedTravel.remainingSeats, 
        ticketPrice: selectedTravel.ticketPrice, 
        airConditioned: selectedTravel.airConditioned, 
        driverName: selectedTravel.driverName, 
        carName: selectedTravel.carName, 
        status: ReservationStatus.completed, 
        userId: widget.travelSearchInfo['userId'], 
        distance: '2'
        );

        showReservationDialog(context, reservation);
    }
  }
}
