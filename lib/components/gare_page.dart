import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';

class GarePage extends StatelessWidget {
  const GarePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: "Gares"),
      body: Container(
        child: Center(
          child: Text("Liste des gares"),
        ),
      ),
    );
  }
}