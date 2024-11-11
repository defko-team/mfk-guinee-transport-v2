import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/booking_confirmation.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/reservation_info.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
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
  ReservationModel? reservationModel;

  List<TravelModel> travels = [];

  TravelService travelService = TravelService();
  ReservationService reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    _loadTravels();
  }

  Future<void> _loadTravels() async {
    var travelData = await travelService.getTravelsByStations(
        widget.travelSearchInfo['selectedDeparture'],
        widget.travelSearchInfo['selectedArrival']);

    setState(() {
      travels = travelData;
    });
  }

  void _setOnSelectedCarState(int index) {
    setState(() {
      if (selectedCarIndex == index) {
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
                onClick: OnCarSelection,
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

  void OnCarSelection() {
    // Action lors de la recherche
    if (selectedCarIndex != -1) {
      TravelModel selectedTravel = travels[selectedCarIndex];

      this.reservationModel = ReservationModel(
          departureStation: selectedTravel.departureStation?.address,
          destinationStation: selectedTravel.destinationStation?.address,
          departureLocation: selectedTravel.departureStation?.address,
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
          distance: '2',
          travelId: selectedTravel.id!
          );

      showReservationDialog(context, reservationModel!, onBooking);
    }
  }

  void onBooking() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingConfirmationDialog(book: _saveReservation);
      },
    );
  }

  Future<void> _saveReservation() async {
    if (reservationModel != null) {
      await reservationService.saveReservation(reservationModel!);
    }
  }
}
