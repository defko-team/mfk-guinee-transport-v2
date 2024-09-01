import 'package:flutter/material.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'utilisateur'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Page Détails de l\'utilisateur'),
      ),
    );
  }
}
