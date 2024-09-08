import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/simple_app_bar.dart';
import 'package:mfk_guinee_transport/components/trip_card.dart';
import 'package:mfk_guinee_transport/components/trip_card_detail.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomSimpleAppBar(title: "Historique"),
      body: Column(
        children: [
          FilterBar(),
          Expanded(
            child: ListView(
              children: [
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Keur Massar",
                  vehicleName: "Voiture 39XC",
                  status: "Confirmé",
                  statusColor: Colors.blue,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // to allow full-screen height
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return DraggableScrollableSheet(
                          expand:
                              false, // Allow the bottom sheet to grow based on content
                          builder: (context, scrollController) {
                            return TripDetailCard(
                              userName: "Abdallah K.",
                              userAvatarUrl:
                                  "https://st3.depositphotos.com/15648834/17930/v/1600/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg",
                              rating: 4.9,
                              origin: "7958 RWP Village",
                              destination: "Islamabad high way, Pakistan",
                              distance: "0.2 km",
                              time: "25 min",
                              price: "2.000 CFA",
                              onCancel: () {
                                Navigator.of(context)
                                    .pop(); // Close the bottom sheet
                              },
                              // scrollController:
                              //     scrollController, // Allow for scrollable content
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Keur Massar",
                  vehicleName: "Voiture 39XC",
                  status: "Confirmé",
                  statusColor: Colors.blue,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // to allow full-screen height
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return DraggableScrollableSheet(
                          expand:
                              false, // Allow the bottom sheet to grow based on content
                          builder: (context, scrollController) {
                            return TripDetailCard(
                              userName: "Abdallah K.",
                              userAvatarUrl:
                                  "https://st3.depositphotos.com/15648834/17930/v/1600/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg",
                              rating: 4.9,
                              origin: "7958 RWP Village",
                              destination: "Islamabad high way, Pakistan",
                              distance: "0.2 km",
                              time: "25 min",
                              price: "2.000 CFA",
                              onCancel: () {
                                Navigator.of(context)
                                    .pop(); // Close the bottom sheet
                              },
                              // scrollController:
                              //     scrollController, // Allow for scrollable content
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                TripCard(
                  origin: "Dakar, Ville",
                  destination: "Dakar, Keur Massar",
                  vehicleName: "Voiture 39XC",
                  status: "Confirmé",
                  statusColor: Colors.blue,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // to allow full-screen height
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return DraggableScrollableSheet(
                          expand:
                              false, // Allow the bottom sheet to grow based on content
                          builder: (context, scrollController) {
                            return TripDetailCard(
                              userName: "Abdallah K.",
                              userAvatarUrl:
                                  "https://st3.depositphotos.com/15648834/17930/v/1600/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg",
                              rating: 4.9,
                              origin: "7958 RWP Village",
                              destination: "Islamabad high way, Pakistan",
                              distance: "0.2 km",
                              time: "25 min",
                              price: "2.000 CFA",
                              onCancel: () {
                                Navigator.of(context)
                                    .pop(); // Close the bottom sheet
                              },
                              // scrollController:
                              //     scrollController, // Allow for scrollable content
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FilterDropdown(label: 'Date'),
          FilterDropdown(label: 'Status'),
          FilterDropdown(label: 'Vehicule'),
        ],
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;

  FilterDropdown({required this.label});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text(label),
      items: <String>['Option 1', 'Option 2', 'Option 3'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (_) {},
    );
  }
}
