import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/views/customer_home.dart';
import 'package:mfk_guinee_transport/views/login.dart';
import 'package:mfk_guinee_transport/views/provider_home.dart';
import 'package:mfk_guinee_transport/views/no_network.dart';
import 'package:mfk_guinee_transport/views/register.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    '/customerHome': (BuildContext context) => const CustomerHomePage(),
    '/login': (BuildContext context) => const Login(),
    '/providerHome': (BuildContext context) => const ProviderHomePage(),
    '/noNetwork': (BuildContext context) => const NoNetwork(pageToGo: '/login'),
    '/register': (BuildContext context) => const RegisterPage(),
  };
}
