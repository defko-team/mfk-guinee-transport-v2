import 'package:flutter/material.dart';

class SelectableCarWidget extends StatefulWidget {
  final String carName;
  final String driverName;
  final String departureTime;
  final String price;
  final bool isClimatised;
  final int seats;
  final Function(bool) onSelected;

  const SelectableCarWidget({
    super.key,
    required this.carName,
    required this.driverName,
    required this.departureTime,
    required this.price,
    required this.isClimatised,
    required this.seats,
    required this.onSelected,
  });

  @override
  _SelectableCarWidgetState createState() => _SelectableCarWidgetState();
}

class _SelectableCarWidgetState extends State<SelectableCarWidget> {
  bool _isSelected = false;

  void _toggleSelection() {
    setState(() {
      _isSelected = !_isSelected;
      widget.onSelected(_isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSelection,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.local_taxi, color: Colors.yellow, size: 40),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.carName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.driverName),
                    const SizedBox(height: 4),
                    Text('${widget.seats} places'),
                    Text(widget.isClimatised ? 'Climatisé' : 'Non Climatisé'),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  widget.departureTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
