import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BaseAppBar(title: 'Politique de confidentialité'),
      body: Center(
        child: Text('Page Politique de confidentialité'),
      ),
    );
  }
}
