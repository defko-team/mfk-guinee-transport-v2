import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/other.dart';

class LocationForm extends StatefulWidget {
  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final List<String> locations = [
    'Dakar, Ville',
    'Keur Massar',
    'Pikine',
    'Guediawaye',
    'Rufisque',
  ];

  String? selectedDeparture;
  String? selectedArrival;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Où allez-vous aujourd'hui ?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ), // Departure Dropdown

          SizedBox(height: 16),
          // Arrival Dropdown
          Row(
            children: [
              // First Column: My Location Icon and Departure Field
              Column(
                children: [
                  Icon(Icons.my_location, color: Colors.green),
                  CustomPaint(
                    size:
                        Size(2.0, 40.0), // Adjust the height of the dotted line
                    painter: DottedLinePainter(),
                  ),
                  Icon(Icons.location_on, color: Colors.green),
                ],
              ),
              SizedBox(width: 10.0),
              // Second Column: Departure and Arrival Fields
              Expanded(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDeparture, // Initial value
                      decoration: const InputDecoration(
                        hintText: 'Départ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Colors.black, // Border color
                            width: 1.0, // Border width
                          ),
                        ),
                      ),
                      items: locations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDeparture = newValue;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedArrival, // Initial value
                      decoration: InputDecoration(
                        hintText: 'Arrivée',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Colors.black, // Border color
                            width: 1.0, // Border width
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              selectedArrival = null;
                            });
                          },
                        ),
                      ),
                      items: locations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedArrival = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Spacer(),

        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    var max = size.height;
    var dashWidth = 4.0;
    var dashSpace = 4.0;
    double startY = 0;
    while (startY < max) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
