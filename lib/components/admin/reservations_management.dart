import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class AdminReservationsManagementPage extends StatefulWidget {
  const AdminReservationsManagementPage({super.key});

  @override
  State<StatefulWidget> createState() =>
      _AdminReservationsManagementPageState();
}

class _AdminReservationsManagementPageState
    extends State<AdminReservationsManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        backgroundColor: AppColors.green,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }
}
