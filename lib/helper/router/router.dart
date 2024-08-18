import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/views/customer_home.dart';
import 'package:mfk_guinee_transport/views/login.dart';
import 'package:mfk_guinee_transport/views/onboarding.dart';
import 'package:mfk_guinee_transport/views/provider_home.dart';
import 'package:mfk_guinee_transport/views/no_network.dart';
import 'package:mfk_guinee_transport/views/register.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    '/customerHome': (BuildContext context) => CustomerHomePage(),
    '/login': (BuildContext context) => Login(),
    '/onboarding': (BuildContext context) => OnboardingPage(),
    '/providerHome': (BuildContext context) => ProviderHomePage(),
    '/noNetwork': (BuildContext context) => NoNetwork(pageToGo: '/login'),
    '/register': (BuildContext context) => RegisterPage(),
  };
}
