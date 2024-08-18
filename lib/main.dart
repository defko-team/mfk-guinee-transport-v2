import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/views/onboarding.dart';
import 'package:mfk_guinee_transport/views/customer_home.dart';
import 'package:mfk_guinee_transport/views/provider_home.dart';
import 'package:mfk_guinee_transport/views/no_network.dart';
import 'package:mfk_guinee_transport/views/login.dart';
import 'dart:io';
import 'package:mfk_guinee_transport/helper/firebase/firebase_init.dart';

Future<void> main() async {
  // Assurez-vous que les widgets sont correctement liés au moteur Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await initFirebase();

  // Vérification de la connectivité
  var isConnected = false;
  try {
    final result = await InternetAddress.lookup('www.google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isConnected = true;
    }
  } on SocketException catch (_) {
    isConnected = false;
  }

  // Configuration de l'orientation de l'écran
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Accès aux préférences partagées
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var isFirstTime = preferences.getBool("isFirstTime");
  var isProviderAuthenticated = preferences.getBool("isProviderAuthenticated");

  // Définition de la page de démarrage en fonction de la connectivité et des préférences
  Widget homePage;
  if (!isConnected) {
    homePage = NoNetwork(pageToGo: "/"); // Redirection vers la page sans connexion
  } else if (isFirstTime == null) {
    homePage = OnboardingPage(); // Redirection vers la page d'onboarding
  } else if (isFirstTime == false && isProviderAuthenticated == true) {
    homePage = ProviderHomePage(); // Redirection vers la page d'accueil du fournisseur
  } else if (isFirstTime == false && isProviderAuthenticated == null) {
    homePage = CustomerHomePage(); // Redirection vers la page d'accueil du client
  } else {
    homePage = Login(); // Redirection vers la page de login si aucune autre condition n'est remplie
  }

  runApp(MyApp(homePage: homePage));
}

class MyApp extends StatelessWidget {
  final Widget homePage;

  const MyApp({Key key, @required this.homePage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guinness Transport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: homePage,
    );
  }
}
