import 'package:flutter/material.dart';

class ProviderHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Home'),
      ),
      body: Center(
        child: Text(
          'Implémentation Home Page Fournisseur en cours',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
