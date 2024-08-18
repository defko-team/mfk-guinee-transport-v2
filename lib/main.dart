import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/views/onboarding.dart';
import 'package:mfk_guinee_transport/views/customer_home.dart';
import 'package:mfk_guinee_transport/views/provider_home.dart';
import 'package:mfk_guinee_transport/views/no_network.dart';
import 'package:mfk_guinee_transport/views/login.dart';
import 'package:mfk_guinee_transport/helper/firebase/firebase_init.dart';
import 'package:mfk_guinee_transport/helper/router/router.dart';
import 'package:mfk_guinee_transport/helper/utils/utils.dart';  // Import the utils.dart file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initFirebase();

  bool isConnected = await isConnectedToInternet();  // Use the connectivity check utility function

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SharedPreferences preferences = await SharedPreferences.getInstance();
  var isFirstTimeInApp = preferences.getBool("isFirstTimeInApp");
  var isProviderAuthenticated = preferences.getBool("isProviderAuthenticated");
  var isCustomerAuthenticated = preferences.getBool("isCustomerAuthenticated");


  Widget homePage;

  // if (!isConnected) {
  //   homePage = NoNetwork(pageToGo: "/");
  // } else if (isFirstTime == null) {
  //   homePage = OnboardingPage();
  // } else if (isFirstTime == false && isProviderAuthenticated == true) {
  //   homePage = ProviderHomePage();
  // } else if (isFirstTime == false && isProviderAuthenticated == null) {
  //   homePage = CustomerHomePage();
  // } else {
  //   homePage = Login();
  // }
  
  if (!isConnected) {
    homePage = NoNetwork(pageToGo: "/login");
  } else{
    homePage = Login();
  }

  runApp(MyApp(homePage: homePage));
}

class MyApp extends StatelessWidget {
  final Widget homePage;

  const MyApp({Key? key, required this.homePage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guinea Transport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: homePage,
      routes: getAppRoutes(),
    );
  }
}
