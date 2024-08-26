import 'package:flutter/material.dart';

class ProviderHomePage extends StatelessWidget {

  const ProviderHomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(

      body: Center(
        child: Text(
          'Implémentation Home Page Fournisseur',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
