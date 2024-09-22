import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';

class ClearCachePage extends StatelessWidget {
  const ClearCachePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BaseAppBar(title: "Effacer Cache"),
      body: Center(
        child: Text('Page Effacer Cache'),
      ),
    );
  }
}
