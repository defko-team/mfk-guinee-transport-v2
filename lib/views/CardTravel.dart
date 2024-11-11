import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:flutter/cupertino.dart'; // Make sure to import this

class CardTravel extends StatelessWidget {
  final TravelModel travelModel;
  final Future<void> Function(String) onShowDeleteDialog;
  final Function(TravelModel) onDuration;
  final Function(StationModel, StationModel) onDistance;
  final void Function({TravelModel? travel}) onOpenAddTravelBottomSheet;
  const CardTravel(
      {super.key,
      required this.travelModel,
      required this.onShowDeleteDialog,
      required this.onDuration,
      required this.onDistance,
      required this.onOpenAddTravelBottomSheet});

  @override
  Widget build(BuildContext context) {
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
                      '${travelModel.departureStation?.name}',
                      style: const TextStyle(fontSize: 13),
                    ),
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
                    Text(
                      '${onDistance(travelModel.departureStation!, travelModel.destinationStation!)} km',
                      style: const TextStyle(fontSize: 13),
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
                    Text(
                      onDuration(travelModel),
                      style: const TextStyle(fontSize: 13),
                    ),
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
                      '${travelModel.destinationStation?.name}',
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
                    '${travelModel.ticketPrice}',
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
                    Text(travelModel.driverName)
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.event_seat,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 9,
                    ),
                    const Text('3/4 places'),
                    Container(
                      width: 9,
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
                      width: 9,
                    ),
                    const Icon(
                      CupertinoIcons.car_detailed,
                      color: Colors.grey, // icon color
                    ),
                    Container(width: 8),
                    Text(travelModel.carName)
                  ],
                ),
                travelModel.airConditioned
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
                              padding: const EdgeInsets.all(
                                  1), // adjust padding as needed
                              child: Icon(
                                color: Colors.green.shade900,
                                Icons.ac_unit_sharp,
                              )),
                          Container(width: 9),
                          const Text('Climatisé'),
                          Container(
                            width: 5,
                          )
                        ],
                      )
                    : Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white, // background color
                                    borderRadius: BorderRadius.circular(23),
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
                                  )),
                              Transform.rotate(
                                angle: -0.785398, // 45 degrees in radians
                                child: Container(
                                  width: 30,
                                  height: 2,
                                  color: Colors.grey, // Diagonal line color
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 5,
                          ),
                          const Text('Non climatisé'),
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
                      onPressed: () =>
                          onOpenAddTravelBottomSheet(travel: travelModel),
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
                      onPressed: () =>
                          onShowDeleteDialog(travelModel.travelReference!.id),
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
}
