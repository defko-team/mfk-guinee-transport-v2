import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Page Politique de confidentialité'),
      ),
    );
  }
}
