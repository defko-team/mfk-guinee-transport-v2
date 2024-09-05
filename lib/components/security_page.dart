import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Page Sécurité'),
      ),
    );
  }
}
