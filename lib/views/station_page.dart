import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/components/station/station_list.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/station.dart';
import 'package:mfk_guinee_transport/services/station_service.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key});

  @override
  _StationPageState createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  StationService stationService = StationService();
  List<StationModel> stations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    List<StationModel> stationList = await stationService.getAllStations();
    setState(() {
      stations = stationList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: 'Gares',
      ),
      backgroundColor: AppColors.lightGrey,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : StationListWidget(stations: stations),
    );
  }
}
