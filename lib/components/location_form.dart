import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/utils/line_painter.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class LocationForm extends StatefulWidget {
  final ValueChanged<String> onDepartureChanged;
  final ValueChanged<String> onArrivalChanged;
  final List<StationModel> locations;

  const LocationForm({
    super.key,
    required this.onDepartureChanged,
    required this.onArrivalChanged,
    required this.locations,
  });

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  TextEditingController departureController = TextEditingController();
  TextEditingController arrivalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.01,
        screenHeight * 0.01,
        screenWidth * 0.01,
        screenHeight * 0.02,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015,
          horizontal: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.my_location,
                        color: Colors.green, size: 24),
                    SizedBox(
                      height: 40,
                      child: CustomPaint(
                        painter: DottedLinePainter(),
                      ),
                    ),
                    const Icon(Icons.location_on,
                        color: Colors.green, size: 24),
                  ],
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    children: [
                      _buildAutocompleteField(
                        controller: departureController,
                        hintText: 'Départ',
                        onChanged: widget.onDepartureChanged,
                        isArrival: false,
                      ),
                      _buildAutocompleteField(
                        controller: arrivalController,
                        hintText: 'Arrivée',
                        onChanged: widget.onArrivalChanged,
                        isArrival: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    bool isArrival = false,
  }) {
    return Stack(
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            final suggestions = widget.locations.where((StationModel option) {
              return option.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).toList();
            return suggestions.map((station) => station.name);
          },
          onSelected: (String selection) {
            setState(() {
              controller.text = selection;
            });
            onChanged(selection);
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              autofocus: false,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: isArrival
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: isArrival
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: const Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            controller.clear();
                            textEditingController.clear();
                          });
                          onChanged(''); // Clear the corresponding value
                        },
                      )
                    : null,
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                setState(() {});
                onChanged(value);
              },
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.white, // Set background color to white
                elevation: 4.0,
                child: Container(
                  width: MediaQuery.of(context).size.width - 80,
                  constraints: const BoxConstraints(
                    maxHeight:
                        200.0, // Limit the height to make it scrollable if more than 5 items
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
