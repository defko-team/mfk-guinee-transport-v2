import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BaseAppBar(title: 'Sécurité'),
      body: Center(
        child: Text('Page Sécurité'),
      ),
    );
  }
}
