import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
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
    //futuretravelModels = TravelService().getAllTravels();
    _loadTravels();
  }

  void _loadTravels() {
    print("Loading travels");
    setState(() {
      futuretravelModels =
          TravelService().getAllTravels(); // Récupérer la liste des voyages
    });
    print("Travels loaded");
  }

  Future<void> _showDeleteConfirmationDialog(String travelId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this travel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Annuler
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmer
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    // Si l'utilisateur a confirmé, supprimer le voyage
    if (confirm == true) {
      _deleteTravel(travelId);
    }
  }

  Future<void> _deleteTravel(String travelId) async {
    bool success = await TravelService()
        .deleteTravel(travelId); // Appelle la méthode de suppression

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Travel successfully deleted')));
      _loadTravels(); // Recharger les voyages après suppression
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error deleting travel')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const BaseAppBar(title: "Gestion des Trajets"),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<List<TravelModel>>(
                        future: futuretravelModels,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        MediaQuery.of(context).size.width / 2.5,
                                    top: MediaQuery.of(context).size.height /
                                        2.5),
                                child: const CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No travels found'));
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: snapshot.data!.length,
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              // First Column
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 7),
                                                      child: Icon(
                                                        Icons
                                                            .my_location_rounded,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15),
                                                      child: Dash(
                                                        direction:
                                                            Axis.vertical,
                                                        length: 28,
                                                        dashLength: 4,
                                                        dashGap: 3,
                                                        dashColor: Colors.grey,
                                                        dashThickness: 2,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5),
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
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 1),
                                                        child: Text(
                                                          '${snapshot.data![index].departureStation?.name}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ),
                                                      Container(height: 26),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 1,
                                                                bottom: 4),
                                                        child: Text(
                                                          '${snapshot.data![index].destinationStation?.name}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10, left: 170),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 17,
                                                                bottom: 11),
                                                        child: Icon(
                                                          Icons.social_distance,
                                                          color: Colors.black,
                                                          size: 12,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 17,
                                                                bottom: 9),
                                                        child: Icon(
                                                          Icons
                                                              .access_time_filled,
                                                          color: Colors.grey,
                                                          size: 12,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 17),
                                                        child: Text(
                                                          "XOF",
                                                          style: TextStyle(
                                                              fontSize: 8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10, left: 16),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 0,
                                                                right: 0),
                                                        child: Text(
                                                          "0.2km",
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 0,
                                                                right: 0),
                                                        child: Text(
                                                          "20 min",
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 0),
                                                        child: Text(
                                                          '${snapshot.data![index].ticketPrice}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
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
                                                      const EdgeInsets.only(
                                                          left: 15),
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
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      minimumSize:
                                                          const Size(132, 33),
                                                      shape:
                                                          RoundedRectangleBorder(
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 15),
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      _showDeleteConfirmationDialog(
                                                          snapshot
                                                              .data![index]
                                                              .travelReference!
                                                              .id);
                                                    },
                                                    icon: const Icon(
                                                      Icons
                                                          .delete_forever_outlined,
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
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      minimumSize:
                                                          const Size(132, 33),
                                                      shape:
                                                          RoundedRectangleBorder(
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
                    ),
                  ],
                ),
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height / 1.21,
                  left: 10,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.green,
                      minimumSize:
                          Size(MediaQuery.of(context).size.width / 1.05, 46),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Ajouter nouveau Trajet'),
                  ))
            ],
          ),
        ));
  }
}
