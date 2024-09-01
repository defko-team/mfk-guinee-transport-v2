import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactez-nous'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Page Contactez-nous'),
      ),
    );
  }
}
