import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/components/simple_app_bar.dart';
import 'package:mfk_guinee_transport/components/trip_card.dart';
import 'package:mfk_guinee_transport/components/trip_card_detail.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: "Historique"),
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
                      shape: const RoundedRectangleBorder(
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
                      shape: const RoundedRectangleBorder(
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
                      shape: const RoundedRectangleBorder(
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

class FilterBar extends StatefulWidget {
  const FilterBar({super.key});

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  // For storing the selected date, status, and vehicle
  DateTime? selectedDate;
  String? selectedStatus;
  String? selectedVehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDatePicker(context),
          _buildStatusDropdown(),
          _buildVehicleDropdown(),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
              : 'Date',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      hint: const Text('Status'),
      value: selectedStatus,
      items: ['Confirmé', 'Completé', 'Annulé'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedStatus = newValue;
        });
      },
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButton<String>(
      hint: const Text('Véhicule'),
      value: selectedVehicle,
      items: ['Voiture X1', 'Voiture X2'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedVehicle = newValue;
        });
      },
    );
  }
}
