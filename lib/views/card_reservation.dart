import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:flutter/cupertino.dart'; // Make sure to import this

class CardReservation extends StatelessWidget {
  final ReservationModel reservationModel;
  final void Function({required ReservationModel reservation})
      onOpenModifyReservationBottonSheet;
  const CardReservation(
      {super.key,
      required this.reservationModel,
      required this.onOpenModifyReservationBottonSheet});

  @override
  Widget build(BuildContext context) {
    if (reservationModel.status == ReservationStatus.pending) {
      return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: const Color.fromARGB(255, 245, 245, 245),
          semanticContainer: true,
          shadowColor: Colors.teal,
          elevation: 1,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 2,
                        ),
                        const Icon(
                          Icons.my_location_rounded,
                          color: Colors.green,
                          size: 21,
                        ),
                        Container(
                          width: 4,
                        ),
                        Text(
                          reservationModel.departureLocation!,
                          style: const TextStyle(fontSize: 13),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                        ),
                        Chip(
                          shape: const StadiumBorder(
                              side: BorderSide(color: Colors.green, width: 1)),
                          backgroundColor: AppColors.white,
                          elevation: 10,
                          visualDensity:
                              const VisualDensity(horizontal: -1, vertical: -4),
                          labelPadding: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 1),
                          label: Text(DateFormat('dd/MM/yyyy HH:mm')
                              .format(reservationModel.startTime)),
                          avatar: const Icon(Icons.calendar_today, size: 16),
                        ),
                        Container(
                          width: 4,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 11,
                        ),
                        const Dash(
                          direction: Axis.vertical,
                          length: 28,
                          dashLength: 4,
                          dashGap: 3,
                          dashColor: Colors.grey,
                          dashThickness: 2,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              color: Colors.grey,
                              size: 25,
                            ),
                            Container(
                              width: 4,
                            ),
                            Text(
                              reservationModel.arrivalLocation!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 4,
                        ),
                        Chip(
                          shape: const StadiumBorder(
                              side: BorderSide(color: Colors.red, width: 1)),
                          backgroundColor: AppColors.white,
                          elevation: 10,
                          visualDensity:
                              const VisualDensity(horizontal: -1, vertical: -4),
                          labelPadding: const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 1),
                          label: Text(reservationModel.status.name),
                          avatar: const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                        Container(
                          width: 4,
                        ),
                      ],
                    )
                  ],
                ),
                Divider(
                  thickness: 0.7,
                  color: Colors.grey.shade500,
                ),
                Container(
                  height: 9,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                        ),
                        OutlinedButton.icon(
                          onPressed: () => onOpenModifyReservationBottonSheet(
                              reservation: reservationModel),
                          icon: const Icon(
                            Icons.edit_square,
                            size: 14,
                            color: Colors.black,
                          ), // Icône à afficher
                          label: const Text(
                            "Modifier",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ), // Texte à afficher
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(132, 33),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(40), // Bords arrondis
                            ),
                            side: const BorderSide(
                                width: 1.0,
                                color: Colors.black), // Bordure avec couleur
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.delete_forever_outlined,
                            size: 14,
                            color: Colors.red,
                          ), // Icône à afficher
                          label: const Text(
                            "Supprimer",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ), // Texte à afficher
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(132, 33),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(40), // Bords arrondis
                            ),
                            side: const BorderSide(
                                width: 1.0,
                                color: Colors.red), // Bordure avec couleur
                          ),
                        ),
                        Container(width: 4)
                      ],
                    )
                  ],
                )
              ],
            ),
          ));
    }
    if ((reservationModel.status == ReservationStatus.completed) ||
        (reservationModel.status == ReservationStatus.confirmed)) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Colors.white,
        semanticContainer: true,
        shadowColor: Colors.teal,
        elevation: 1,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 2,
                      ),
                      const Icon(
                        Icons.my_location_rounded,
                        color: Colors.green,
                        size: 21,
                      ),
                      Container(
                        width: 4,
                      ),
                      Text(
                        reservationModel.departureLocation ?? 'test',
                        style: const TextStyle(fontSize: 13),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.social_distance,
                        color: Colors.grey,
                        size: 12,
                      ),
                      Container(
                        width: 4,
                      ),
                      const Text('To be define'),
                      Container(
                        width: 4,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 11,
                      ),
                      const Dash(
                        direction: Axis.vertical,
                        length: 28,
                        dashLength: 4,
                        dashGap: 3,
                        dashColor: Colors.grey,
                        dashThickness: 2,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: Colors.grey,
                        size: 12,
                      ),
                      Container(
                        width: 4,
                      ),
                      (reservationModel.arrivalTime != null)
                          ? const Text(
                              "to be define",
                              style: TextStyle(fontSize: 13),
                            )
                          : const Text("To Be Define"),
                      Container(
                        width: 4,
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        color: Colors.grey,
                        size: 25,
                      ),
                      Container(
                        width: 4,
                      ),
                      Text(
                        reservationModel.arrivalLocation!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  Row(children: [
                    const Text(
                      "XOF",
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Container(
                      width: 4,
                    ),
                    Text(
                      '${reservationModel.ticketPrice}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Container(
                      width: 4,
                    ),
                  ])
                ],
              ),
              Divider(
                thickness: 0.7,
                color: Colors.grey.shade300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(1),
                        child: const Icon(
                          CupertinoIcons.person_alt_circle_fill,
                          color: Colors.white,
                        ),
                      ),
                      Container(width: 8),
                      Text(reservationModel.driverName ?? '')
                    ],
                  ),
                  Row(
                    children: [
                      Chip(
                        shape: const StadiumBorder(
                            side: BorderSide(color: Colors.green, width: 1)),
                        backgroundColor: AppColors.white,
                        elevation: 10,
                        visualDensity:
                            const VisualDensity(horizontal: -1, vertical: -4),
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 1, vertical: 1),
                        label: Text(DateFormat('dd/MM/yyyy')
                            .format(reservationModel.startTime)),
                        avatar: const Icon(Icons.calendar_today, size: 16),
                      ),
                      const SizedBox(
                          width: 8), // Add some spacing between chips
                      // Time Chip
                      Chip(
                        backgroundColor: AppColors.white,
                        shape: const StadiumBorder(
                            side: BorderSide(color: Colors.green, width: 1)),
                        elevation: 10,
                        visualDensity:
                            const VisualDensity(horizontal: -2, vertical: -4),
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 1, vertical: 1),
                        label: Text(DateFormat('HH:mm')
                            .format(reservationModel.startTime)),
                        avatar: const Icon(Icons.access_time, size: 16),
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 9,
                      ),
                      const Icon(
                        CupertinoIcons.car_detailed,
                        color: Colors.grey, // icon color
                      ),
                      Container(width: 8),
                      Text(reservationModel.carName ?? 'TBF')
                    ],
                  ),
                  reservationModel.airConditioned != null
                      ? Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white, // background color
                                  borderRadius: BorderRadius.circular(23),
                                  border: Border.all(
                                    color: Colors.green.shade700,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(1),
                                child: Icon(
                                  color: Colors.green.shade900,
                                  Icons.ac_unit_sharp,
                                )),
                            Container(
                              width: 9,
                            ),
                            const Text('Climatisé'),
                            Container(
                              width: 5,
                            )
                          ],
                        )
                      : Row(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          color: AppColors
                                              .white, // background color
                                          borderRadius:
                                              BorderRadius.circular(23),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(
                                            1), // adjust padding as needed
                                        child: const Icon(
                                          color: Colors.grey,
                                          Icons.ac_unit_sharp,
                                          size: 12,
                                        )),
                                    Transform.rotate(
                                      angle: -0.785398, // 45 degrees in radians
                                      child: Container(
                                        width: 20,
                                        height: 2,
                                        color:
                                            Colors.grey, // Diagonal line color
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              width: 10,
                              height: 12,
                            ),
                            const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text('Non climatisé')),
                            Container(
                              width: 5,
                            ),
                          ],
                        )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.edit_square,
                          size: 14,
                          color: Colors.black,
                        ), // Icône à afficher
                        label: const Text(
                          "Modifier",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ), // Texte à afficher
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(132, 33),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(40), // Bords arrondis
                          ),
                          side: const BorderSide(
                              width: 1.0,
                              color: Colors.black), // Bordure avec couleur
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 14,
                          color: Colors.red,
                        ), // Icône à afficher
                        label: const Text(
                          "Supprimer",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ), // Texte à afficher
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(132, 33),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(40), // Bords arrondis
                          ),
                          side: const BorderSide(
                              width: 1.0,
                              color: Colors.red), // Bordure avec couleur
                        ),
                      ),
                      Container(width: 4)
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      );
    }
    if (reservationModel.status == ReservationStatus.canceled) {
      return Card();
    }
    return Card();
  }
}
