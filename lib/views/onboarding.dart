import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
      ),
      body: Center(
        child: Text(
          'Onboarding Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
