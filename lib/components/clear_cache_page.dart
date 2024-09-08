import 'package:flutter/material.dart';

class ClearCachePage extends StatelessWidget {
  const ClearCachePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effacer Cache'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Page Effacer Cache'),
      ),
    );
  }
}
