import 'package:flutter/material.dart';

class CustomerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Home'),
      ),
      body: Center(
        child: Text(
          'Implémentation Home Page Client en cours',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
