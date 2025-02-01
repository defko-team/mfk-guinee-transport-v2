import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/views/home_page.dart';
import 'package:mfk_guinee_transport/views/login.dart';
import 'package:mfk_guinee_transport/views/admin_home_page.dart';
import 'package:mfk_guinee_transport/views/driver_home_page.dart';
import 'package:mfk_guinee_transport/views/no_network.dart';
import 'package:mfk_guinee_transport/views/register.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    '/customerHome': (BuildContext context) => const HomePage(),
    '/login': (BuildContext context) => const Login(),
    '/providerHome': (BuildContext context) => const AdminHomePage(),
    '/driverHome': (BuildContext context) => const DriverHomePage(),
    '/noNetwork': (BuildContext context) => const NoNetwork(pageToGo: '/login'),
    '/register': (BuildContext context) => const RegisterPage(),
    // '/availableCars': (BuildContext context) => const AvailableCarsPage(),
  };
}
