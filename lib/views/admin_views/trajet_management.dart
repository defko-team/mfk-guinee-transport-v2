import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/models/travel.dart';
import 'package:mfk_guinee_transport/services/travel_service.dart';

class TrajetManagementPage extends StatefulWidget {
  const TrajetManagementPage({super.key});

  @override
  State<TrajetManagementPage> createState() => _TrajetManagementPageState();
}

class _TrajetManagementPageState extends State<TrajetManagementPage> {
  static const Color lightGrey = Color(0xFFF2F2F2);

  late final TravelModel travelModel;

  late final Future<List<TravelModel>> futuretravelModels;
  @override
  void initState() {
    super.initState();
    futuretravelModels = TravelService().getAllTravels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const BaseAppBar(title: "Gestion des Trajets"),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<List<TravelModel>>(
                  future: futuretravelModels,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 2.5,
                              top: MediaQuery.of(context).size.height / 2.5),
                          child: const CircularProgressIndicator());
                    } else {
                      return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: 2, //snapshot.data!.length,
                          itemBuilder: (context, int index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              color: Colors.white,
                              semanticContainer: true,
                              shadowColor: Colors.teal,
                              elevation: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // First Column
                                        const Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 7),
                                                child: Icon(
                                                  Icons.my_location_rounded,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Dash(
                                                  direction: Axis.vertical,
                                                  length: 28,
                                                  dashLength: 4,
                                                  dashGap: 3,
                                                  dashColor: Colors.grey,
                                                  dashThickness: 2,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Icon(
                                                  Icons.place,
                                                  color: Colors.black,
                                                  size: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 1),
                                                  child: Text(
                                                    "Dakar, Ville",
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                                Container(height: 26),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 1, bottom: 4),
                                                  child: Text(
                                                    "Dakar, Patte d'Oie",
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        const Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 140),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 17, bottom: 11),
                                                  child: Icon(
                                                    Icons.social_distance,
                                                    color: Colors.black,
                                                    size: 12,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 17, bottom: 9),
                                                  child: Icon(
                                                    Icons.access_time_filled,
                                                    color: Colors.grey,
                                                    size: 12,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 17),
                                                  child: Text(
                                                    "XOF",
                                                    style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        const Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 16),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 0, right: 0),
                                                  child: Text(
                                                    "0.2km",
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 0, right: 0),
                                                  child: Text(
                                                    "20 min",
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 0),
                                                  child: Text(
                                                    "2000",
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                // Action à effectuer lors de l'appui sur le bouton
                                              },
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
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ), // Texte à afficher
                                              style: OutlinedButton.styleFrom(
                                                minimumSize:
                                                    const Size(132, 33),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40), // Bords arrondis
                                                ),
                                                side: const BorderSide(
                                                    width: 1.0,
                                                    color: Colors
                                                        .black), // Bordure avec couleur
                                              ),
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                // Action à effectuer lors de l'appui sur le bouton
                                              },
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
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ), // Texte à afficher
                                              style: OutlinedButton.styleFrom(
                                                minimumSize:
                                                    const Size(132, 33),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40), // Bords arrondis
                                                ),
                                                side: const BorderSide(
                                                    width: 1.0,
                                                    color: Colors
                                                        .red), // Bordure avec couleur
                                              ),
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}
