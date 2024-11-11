import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/station/station_widget.dart';
import 'package:mfk_guinee_transport/models/station.dart';

class StationListWidget extends StatelessWidget {
  final List<StationModel> stations;

  StationListWidget({required this.stations});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stations.length,
      itemBuilder: (context, index) {
        return StationItemWidget(station: stations[index]);
      },
    );
  }
}
