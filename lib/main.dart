import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mfk_guinee_transport/helper/firebase/firebase_options.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/firebase_messaging_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:mfk_guinee_transport/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/views/admin_home_page.dart';
import 'package:mfk_guinee_transport/views/driver_home_page.dart';
import 'package:mfk_guinee_transport/views/home_page.dart';
import 'package:mfk_guinee_transport/views/no_network.dart';
import 'package:mfk_guinee_transport/views/login.dart';
import 'package:mfk_guinee_transport/helper/router/router.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();

  bool isConnected = await isConnectedToInternet();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences preferences = await SharedPreferences.getInstance();

  // preferences.clear();
  var isProviderAuthenticated = preferences.getBool("isProviderAuthenticated");
  var isCustomerAuthenticated = preferences.getBool("isCustomerAuthenticated");
  var isDriverAuthenticated = preferences.getBool("isDriverAuthenticated");
  var fcmToken = preferences.getString('fcmToken');
  var userId = preferences.getString('userId');
  print('userId ${userId}');
  print('FCM TOKEN ${fcmToken}');

  Widget homePage;

  if (!isConnected) {
    if (isProviderAuthenticated == true) {
      homePage = const NoNetwork(pageToGo: "/providerHome");
    } else if (isCustomerAuthenticated == true) {
      homePage = const NoNetwork(pageToGo: "/customerHome");
    } else if (isDriverAuthenticated == true) {
      homePage = const NoNetwork(pageToGo: "/driverHome");
    } else {
      homePage = const NoNetwork(pageToGo: "/login");
    }
  } else if (isProviderAuthenticated == true) {
    homePage = const AdminHomePage();
  } else if (isCustomerAuthenticated == true) {
    homePage = HomePage();
  } else if (isDriverAuthenticated == true) {
    homePage = const DriverHomePage();
  } else {
    // homePage = const Login();
    homePage = const SplashScreen();
  }

  runApp(MyApp(homePage: homePage));
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set the background message handler first
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize Firebase Messaging Service
  // final messagingService = FirebaseMessagingService();
  // await messagingService.initialize();
  
  // Setup foreground notification listener
  // await _setupForegroundNotificationListener();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to initialize Firebase here as well
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling background message: ${message.messageId}');
}

Future<void> _setupForegroundNotificationListener() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showTopSnackbar(message.notification?.title, message.notification?.body);
    }
  });
}

void _showTopSnackbar(String? title, String? body) {
  if (title != null && body != null) {
    OverlayState? overlayState = navigatorKey.currentState!.overlay;
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: 50.0,
        left: 50.0,
        right: 50.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        body,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    overlayEntry?.remove();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlayState?.insert(overlayEntry);

    // Remove the Snackbar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry?.remove();
    });
  }
}

Future<bool> isConnectedToInternet() async {
  // Implémentez la logique pour vérifier la connexion Internet
  // Par exemple, vous pouvez utiliser le package 'connectivity_plus'
  // pour vérifier l'état de la connexion.
  return true; // Remplacez par la logique réelle
}

class MyApp extends StatelessWidget {
  final Widget homePage;

  const MyApp({super.key, required this.homePage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guinea Transport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        iconTheme: const IconThemeData(size: 18.0),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: homePage,
      routes: getAppRoutes(),
    );
  }
}
