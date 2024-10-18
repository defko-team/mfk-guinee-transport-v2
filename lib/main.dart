import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/views/admin_home_page.dart';
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

  // Set the preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences preferences = await SharedPreferences.getInstance();

  // preferences.clear();

  var isProviderAuthenticated = preferences.getBool("isProviderAuthenticated");
  var isCustomerAuthenticated = preferences.getBool("isCustomerAuthenticated");

  Widget homePage;

  if (!isConnected && isProviderAuthenticated == true) {
    homePage = const NoNetwork(pageToGo: "/providerHome");
  } else if (!isConnected && isCustomerAuthenticated == true) {
    homePage = const NoNetwork(pageToGo: "/customerHome");
  } else if (!isConnected) {
    homePage = const NoNetwork(pageToGo: "/login");
  } else if (isProviderAuthenticated == true) {
    homePage = const AdminHomePage();
  } else if (isCustomerAuthenticated == true) {
    homePage = HomePage();
  } else {
    homePage = const Login();
  }

  runApp(MyApp(homePage: homePage));
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission for notifications
  await _requestNotificationPermission();
  _setupForegroundNotificationListener();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

Future<void> _requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();
    print("FCM Token: $token");
  }
}

void _setupForegroundNotificationListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received in foreground: ${message.notification?.title}');
    if (message.notification != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showTopSnackbar(
            message.notification!.title, message.notification!.body);
      });
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
        left: 0.0,
        right: 0.0,
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
      ),
      home: homePage,
      routes: getAppRoutes(),
    );
  }
}
