import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BaseAppBar(title: "Contactez-nous"),
      body: Center(
        child: Text('Page Contactez-nous'),
      ),
    );
  }
}
