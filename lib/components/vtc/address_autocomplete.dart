import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mfk_guinee_transport/services/location_service.dart';

class AddressAutocomplete extends StatefulWidget {
  final ValueChanged<String> onLocationChanged;
  final String? hintText;
  final bool showCurrentLocation;

  const AddressAutocomplete(
      {super.key,
      required this.onLocationChanged,
      this.hintText,
      required this.showCurrentLocation});

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  LocationService locationService = LocationService();
  String? currentLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      currentLocation =
          await locationService.getCurrentAddress();
    } catch (e) {
      // Handle errors (e.g., show an error message)
      print('Error getting current location: $e');
    }
  }

  Future<List<String>> _fetchAddressSuggestions(String query) async {
    var suggestions = await locationService.fetchAddressSuggestions(query);

    if (widget.showCurrentLocation && currentLocation != null) {
      suggestions.insert(0, currentLocation!);
    }

    suggestions.forEach((add) {
      print("Address: " + add + "\n");
    });

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // Fetch suggestions based on the input query
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        print("Searching for " + textEditingValue.text);
        // Fetch suggestions asynchronously
        return _fetchAddressSuggestions(textEditingValue.text);
      },
      onSelected: (String selection) {
        print("Value selected: " + selection);
        widget.onLocationChanged(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller:
              textEditingController, // Use provided controller or default one
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.hintText,
            border: OutlineInputBorder(),
            suffixIcon: _isLoading ? const CircularProgressIndicator() : null,
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        // Build the options view (dropdown) that displays suggestions
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
                      onSelected(option); // Select suggestion on tap
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
