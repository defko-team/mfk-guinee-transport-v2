import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/services/reservation_service.dart';
import 'package:mfk_guinee_transport/views/card_reservation.dart';

class AdminReservationsManagementPage extends StatefulWidget {
  const AdminReservationsManagementPage({super.key});

  @override
  State<StatefulWidget> createState() =>
      _AdminReservationsManagementPageState();
}

class _AdminReservationsManagementPageState
    extends State<AdminReservationsManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        backgroundColor: AppColors.green,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: StreamBuilder<List<ReservationModel>>(
          stream: ReservationService().reservationStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 2.5,
                      top: MediaQuery.of(context).size.height / 2.5),
                  child: const CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Reservations found'));
            }

            return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, int index) {
                  return CardReservation(
                      reservationModel: snapshot.data![index]);
                });
          }),
    );
  }
}
