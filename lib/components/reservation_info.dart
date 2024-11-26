import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/custom_outlined_button.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';

void showReservationDialog(BuildContext context, ReservationModel reservation,
    VoidCallback onBooking) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.91, // 90% de la largeur de l'écran
          height: MediaQuery.of(context).size.height *
              0.50, // 50% de la hauteur de l'écran
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: AppColors.veryLightGrey,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reservation.driverName!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 16),
                            Text('4.9'),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.my_location, color: Colors.green),
                        title: Text(reservation.departureStation ?? ''),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(reservation.destinationStation ?? ''),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Image.asset("assets/images/taxi.jpeg",
                                  width: 60, height: 60),
                            ],
                          ),
                          Column(
                            children: [
                              const reservationTitle(title: 'DISTANCE'),
                              Text(
                                '${reservation.distance} km',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              const reservationTitle(title: 'TEMPS'),
                              Text(
                                getTimeDifference(reservation.startTime,
                                    reservation.arrivalTime!),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              const reservationTitle(title: 'PRIX'),
                              Text(
                                '${reservation.ticketPrice} CFA',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      CustomElevatedButton(
                          onClick: onBooking,
                          backgroundColor: AppColors.green,
                          text: 'Réserver'),
                      const SizedBox(height: 10),
                      CustomOutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: AppColors.green,
                          text: 'Quitter')
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class reservationTitle extends StatelessWidget {
  final String title;
  const reservationTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ));
  }
}

String getTimeDifference(DateTime startTime, DateTime arrivalTime) {
  Duration difference = arrivalTime.difference(startTime);

  int hours = difference.inHours;
  int minutes = difference.inMinutes
      .remainder(60); // Remaining minutes after calculating hours

  return "${hours}h ${minutes}m";
}
