import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/custom_elevated_button.dart';
import 'package:mfk_guinee_transport/components/location_form.dart';
import 'package:mfk_guinee_transport/components/location_type.dart';
import 'package:mfk_guinee_transport/components/vtc/vtc_travel_form.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/views/available_cars.dart';

class CustomerHome extends StatefulWidget {
  final String? userId;
  final List<StationModel> locations;

  const CustomerHome({super.key, required this.userId, required this.locations});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> with SingleTickerProviderStateMixin {
  int selectedTransportTypeIndex = 0;
  StationModel? selectedDeparture;
  StationModel? selectedArrival;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (selectedDeparture != null && selectedArrival != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (content) => AvailableCarsPage(
            travelSearchInfo: {
              'selectedDeparture': selectedDeparture?.docId,
              'selectedArrival': selectedArrival?.docId,
              'type': selectedTransportTypeIndex,
              'userId': widget.userId,
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
    }
  }

  void _openModifyReservationBottomSheet({required ReservationModel reservation}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: const Text(''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool formIsValid = selectedDeparture != null && selectedArrival != null;
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Où souhaitez-vous aller ?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.green.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LocationType(
                        onTypeSelected: (type) {
                          setState(() {
                            selectedTransportTypeIndex = type;
                          });
                          _animationController.reset();
                          _animationController.forward();
                        },
                        selectedType: selectedTransportTypeIndex,
                      ),
                      const SizedBox(height: 16),
                      if (selectedTransportTypeIndex == 0) ...[
                        LocationForm(
                          onDepartureChanged: (departure) {
                            setState(() {
                              var selectedDepartureFound = widget.locations.where(
                                (location) => location.name.toLowerCase() == departure.toLowerCase(),
                              );
                              selectedDeparture = selectedDepartureFound.isNotEmpty
                                  ? selectedDepartureFound.first
                                  : null;
                            });
                          },
                          onArrivalChanged: (arrival) {
                            setState(() {
                              var selectedArrivalFound = widget.locations.where(
                                (location) => location.name.toLowerCase() == arrival.toLowerCase(),
                              );
                              selectedArrival = selectedArrivalFound.isNotEmpty
                                  ? selectedArrivalFound.first
                                  : null;
                            });
                          },
                          locations: widget.locations,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (selectedTransportTypeIndex == 0) ...[
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CustomElevatedButton(
                    onClick: formIsValid ? _onSearch : () {},
                    backgroundColor: formIsValid ? AppColors.green : AppColors.grey,
                    text: "Rechercher",
                  ),
                ),
              ],
              if (selectedTransportTypeIndex == 1)
                Expanded(
                  child: VTCTravelForm(
                    userId: widget.userId!,
                    refreshData: () {
                      setState(() {
                        selectedTransportTypeIndex = 0;
                      });
                      _animationController.reset();
                      _animationController.forward();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
