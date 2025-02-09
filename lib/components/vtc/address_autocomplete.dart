import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/services/location_service.dart';

class AddressAutocomplete extends StatefulWidget {
  final ValueChanged<String> onLocationChanged;
  final String hintText;
  final String? currentLocation;
  final String labelText;
  final bool isDeparture;

  const AddressAutocomplete(
      {super.key,
      required this.onLocationChanged,
      required this.hintText,
      this.currentLocation,
      required this.labelText,
      this.isDeparture = true});

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> _fetchAddressSuggestions(String query) async {
    var suggestions = await locationService.fetchAddressSuggestions(query);

    if (widget.currentLocation != null) {
      suggestions.insert(0, widget.currentLocation!);
    }

    for (var add in suggestions) {
      print("Address: $add\n");
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _fetchAddressSuggestions(textEditingValue.text);
      },
      onSelected: (String selection) {
        widget.onLocationChanged(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        if (widget.currentLocation != null) {
          textEditingController.text = widget.currentLocation!;
        }
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              labelText: widget.labelText,
              hintText: widget.hintText,
              labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
              prefixIcon: widget.isDeparture
                  ? const Icon(Icons.my_location_rounded,
                      color: AppColors.green, size: 18)
                  : const Icon(Icons.place, color: Colors.black, size: 18),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10.0)),
              floatingLabelStyle:
                  const TextStyle(color: Colors.black, fontSize: 18.0),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0))),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        // Build the options view (dropdown) that displays suggestions
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Container(
              width: MediaQuery.of(context).size.width - 80,
              constraints: const BoxConstraints(
                maxHeight: 200.0,
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
