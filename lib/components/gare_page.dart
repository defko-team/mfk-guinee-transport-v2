import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';

class GarePage extends StatelessWidget {
  const GarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: "Gares"),
      body: Container(
        child: const Center(
          child: Text("Liste des gares"),
        ),
      ),
    );
  }
}
